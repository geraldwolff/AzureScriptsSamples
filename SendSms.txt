
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

    if (-not $Subscriptionid) { throw "Subscription ID is required." }
    if (-not $ResourceGroupName) { throw "Resource group name is required." }
    if (-not $AcsResourceName) { throw "ACS resource name is required." }

    Set-AzContext -Subscription $Subscriptionid

    $acsresource = Get-AzCommunicationService -ResourceGroupName $ResourceGroupName -CommunicationServiceName $AcsResourceName -SubscriptionId $Subscriptionid
    $acsEndpoint = "https://$($acsresource.HostName)"
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

    $validFromNumbers = ($phoneNumbers.phoneNumbers) | Where-Object {
        $_.capabilities.sms -eq "inbound+outbound"
    } | Select-Object -ExpandProperty phoneNumber

    if (-not $validFromNumbers) {
        Write-Warning "No valid 'from' numbers found that support both inbound and outbound SMS."
        return
    }

    $keys = Get-AzCommunicationServiceKey -ResourceGroupName $ResourceGroupName -CommunicationServiceName $AcsResourceName
    $connectionString = "endpoint=https://$($AcsResourceName).communication.azure.com/;accesskey=$($keys.PrimaryKey)"

    $ToNumber = $ToNumber.Trim()
    $Message = $Message.Trim()

    $logPath = "C:\temp\smslog.txt"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $smsSent = $false

    foreach ($fromNumber in $validFromNumbers) {
        $fromNumber = $fromNumber.Trim()
        Write-Host "Trying to send SMS from: $fromNumber"

        try {
            $jsonResult = az communication sms send `
                --connection-string "$connectionString" `
                --sender "$fromNumber" `
                --recipient "$ToNumber" `
                --message "$Message" `
                --output json | ConvertFrom-Json

            $sendResult = $jsonResult[0].sendResult
            $deliveryStatus = $sendResult.deliveryStatus

            Add-Content -Path $logPath -Value "$timestamp - Attempt from $fromNumber - Status: $deliveryStatus"

            if ($deliveryStatus -eq "Delivered" -or ($sendResult.to -and $sendResult.messageId)) {
                Write-Host "`n--- SMS Sent Successfully from $fromNumber ---"
                $smsSent = $true
                break
            } else {
                Write-Warning "Attempt from $fromNumber returned status: $deliveryStatus"
            }
        } catch {
            Write-Warning "Exception sending SMS from $fromNumber : ${_}"
            Add-Content -Path $logPath -Value "$timestamp - Exception from $fromNumber - ${_}"
        }
    }

    if (-not $smsSent) {
        Write-Warning "All attempts to send SMS failed. Check the log at $logPath for details."
    }
}

Export-ModuleMember -Function Send-SmsTo
