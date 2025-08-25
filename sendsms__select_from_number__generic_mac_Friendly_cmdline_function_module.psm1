
function Send-SmsTo {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ToNumber,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    # Import Azure PowerShell module
    Import-Module Az.Communication

    Connect-AzAccount -Identity

    $subscriptionName = 'wolffentpsub'
    $subscription = Get-AzSubscription -SubscriptionName $subscriptionName 
    Set-AzContext -Subscription $subscriptionName 

    $resourceGroupName = "wolffcommsvcsrg"
    $acsResourceName = "wolffacs"

    $acsResource = Get-AzCommunicationService -ResourceGroupName $resourceGroupName -CommunicationServiceName $acsResourceName -SubscriptionId $($subscription.Id)
    $acsEndpoint = "https://$($acsResource.HostName)"

    $apiVersion = "2021-03-07"
    $uri = "$acsEndpoint/phoneNumbers?api-version=$apiVersion"

    $secureToken = (Get-AzAccessToken -ResourceUrl "https://communication.azure.com" -AsSecureString).Token
    $token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
    )

    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type"  = "application/json"
    }

    $phoneNumbers = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers

    $validFromNumber = ($phoneNumbers.phoneNumbers) | Where-Object {
        $_.capabilities.sms -eq "inbound+outbound"
    } | Select-Object -First 1 -ExpandProperty phoneNumber

    if (-not $validFromNumber) {
        Write-Warning "No valid 'from' number found that supports both outbound SMS and event subscription."
        return
    }

    Write-Host "Using validated sender number: $validFromNumber"

    $keys = Get-AzCommunicationServiceKey -ResourceGroupName $resourceGroupName -CommunicationServiceName $acsResourceName
    $connectionString = "endpoint=https://$($acsResourceName).communication.azure.com/;accesskey=$($keys.PrimaryKey)"

    $errorActionPreference = 'Continue'
    $result = az communication sms send `
        --connection-string "$connectionString" `
        --sender "$validFromNumber" `
        --recipient "$ToNumber" `
        --message "$Message"

    $logPath = "C:\temp\smslog.txt"
    $result | Out-File -FilePath $logPath -Append

    Write-Host "`n--- SMS Sent ---`n$result"
}







