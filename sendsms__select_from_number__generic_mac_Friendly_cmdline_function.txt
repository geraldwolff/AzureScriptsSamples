
param (
    [Parameter(Mandatory = $true)]
    [string]$ToNumber,

    [Parameter(Mandatory = $true)]
    [string]$Message
)

function send_sms_to ([string]$tonumber, [string]$message)
{


# Import Azure PowerShell module



Import-Module Az.Communication

connect-azaccount -identity

$subscriptionname = 'wolffentpsub'

    $subscription = get-azsubscription -subscriptionname $subscriptionname 
    set-azcontext -subscription $subscriptionname 
    # $validfromnumber  = '+18667477211'  ##### need to hardcode due to the inability to get th verification status for "subscribe to events" 

    # Define resource group and ACS resource name
    $resourceGroupName = "wolffcommsvcsrg"
    $acsResourceName = "wolffacs"

    # Retrieve all phone numbers in the ACS resource
    $acsresource  = Get-AzCommunicationService  -ResourceGroupName $resourceGroupName -CommunicationServiceName $acsResourceName -subscriptionid $($subscription.id)
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

    # Filter phone numbers that support both outbound and inbound SMS and are subscribed to events
    $validFromNumber = ($phoneNumbers.phoneNumbers) | Where-Object {
        $($_.capabilities.sms) -eq "inbound+outbound" 
    } | Select-Object -skip 1 Phonenumber

    if (-not $validFromNumber) {
        Write-Warning "No valid 'from' number found that supports both outbound SMS and event subscription."
    } else {
        $fromNumber = $validFromNumber.PhoneNumber
        Write-Host "Using validated sender number: $fromNumber"

        # Retrieve connection string
        $keys = Get-AzCommunicationServiceKey -ResourceGroupName $resourceGroupName -CommunicationServiceName $acsResourceName
        $connectionString = "endpoint=https://$($acsResourceName).communication.azure.com/;accesskey=$($keys.PrimaryKey)"

        # Send SMS using Azure CLI
        $erroractionpreference = 'continue'
        $result = az communication sms send `
            --connection-string "$connectionString" `
            --sender "$fromNumber" `
            --recipient "$ToNumber" `
            --message "$Message"

        # Log result
        $logPath = "C:\temp\smslog.txt"
        $result | Out-File -FilePath $logPath -Append

        # Display result
        Write-Host "`n--- SMS Sent ---`n$result"
        # If log is needed to be viewed
     #   Start-Process notepad.exe $logPath
    }
    

 
return $tonumber , $message 
}

$status =  send_sms_to -ToNumber "$Tonumber" -Message "$message" 
        Write-Host "`n--- SMS Sent  to $($status)  `n$result"

