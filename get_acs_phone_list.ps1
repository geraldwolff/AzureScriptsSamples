# Connect using managed identity
Connect-AzAccount -Identity
Set-AzContext -SubscriptionName "wolffentpsub"

# Define variables
$acsResourceName = "wolffacs"
$resourceGroupName = "wolffcommsvcsrg"
$acsResource = Get-AzCommunicationService -ResourceGroupName $resourceGroupName -Name $acsResourceName
$acsEndpoint = "https://$($acsResource.HostName)"
$apiVersion = "2021-03-07"
$uri = "$acsEndpoint/phoneNumbers?api-version=$apiVersion"

$secureToken = (Get-AzAccessToken -ResourceUrl "https://communication.azure.com" -AsSecureString).Token
$token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
)

# Set headers
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

# Make the request
$response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers

# Output the list of phone numbers
$response.phonenumbers | ForEach-Object {

$phoneobj = new-object PSObject

$phoneobj | add-member -MemberType NoteProperty -Name  phoneNumber   -value  $($_.phoneNumber)
$phoneobj | add-member -MemberType NoteProperty -Name   phoneNumberType  -value $($_.phoneNumberType)
$phoneobj | add-member -MemberType NoteProperty -Name   Capabilities  -value $($_.capabilities)

[array]$phonelist += $phoneobj


    Write-Output "Phone Number: $($_.phoneNumber), Type: $($_.phoneNumberType), Capabilities: $($_.capabilities)"
}



$phonelist

















