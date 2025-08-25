
function Send-SmsTo {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ToNumber,

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $true)]
        [string]$Subscriptionid,

        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string]$AcsResourceName
    )

    Import-Module Az.Communication

    if (-not $Subscriptionid) {
        throw "Subscription ID is required."
    }

    if (-not $ResourceGroupName) {
        throw "Resource group name is required."
    }

    if (-not $AcsResourceName) {
        throw "ACS resource name is required."
    }

    Set-AzContext -Subscription $Subscriptionid

    $acsResource = Get-AzCommunicationService -ResourceGroupName $ResourceGroupName -CommunicationServiceName $AcsResourceName
    if (-not $acsResource.HostName) {
        throw "Failed to retrieve ACS resource hostname."
    }

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

    try {
        $phoneNumbers = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
    } catch {
        throw "Failed to retrieve phone numbers: $_"
    }

    $validFromNumber = ($phoneNumbers.phoneNumbers) | Where-Object {
        $_.capabilities.sms -eq "inbound+outbound"
    } | Select-Object -First 1 -ExpandProperty phoneNumber

    if (-not $validFromNumber) {
        Write-Warning "No valid 'from' number found that supports both outbound SMS and event subscription."
        return
    }

    Write-Host "Using validated sender number: $validFromNumber"

    $keys = Get-AzCommunicationServiceKey -ResourceGroupName $ResourceGroupName -CommunicationServiceName $AcsResourceName
    $connectionString = "endpoint=https://$($AcsResourceName).communication.azure.com/;accesskey=$($keys.PrimaryKey)"

    $ToNumber = $ToNumber.Trim()
    $Message = $Message.Trim()
    $validFromNumber = $validFromNumber.Trim()

    Write-Host "DEBUG: From=$validFromNumber To=$ToNumber Message=$Message"
    Write-Host "DEBUG: ConnectionString=$connectionString"

    $errorActionPreference = 'Continue'
    $result = az communication sms send `
        --connection-string "$connectionString" `
        --sender "$validFromNumber" `
        --recipient "$ToNumber" `
        --message "$Message" 2>&1 | Out-String

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logPath = "C:\temp\smslog.txt"
    Add-Content -Path $logPath -Value "$timestamp - $result"

    Write-Host "`n--- SMS Sent ---`n$result"
}

Export-ModuleMember -Function Send-SmsTo
