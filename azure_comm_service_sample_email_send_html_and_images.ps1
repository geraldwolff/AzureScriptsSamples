 Install-Module -Name Az.Communication
 
 import-module   -Name Az.Communication
    
$logincontext =    connect-azaccount -Identity

$vaultname = 'wolffkv'
$spnname = 'wolffcommsvcspn'

# Retrieve the service principal
$serviceprincipal = Get-AzADServicePrincipal -DisplayName "$spnname"

# Retrieve the secret from Key Vault
$credsecret = Get-AzKeyVaultSecret -VaultName "$vaultname" -Name "$($serviceprincipal.AppId)" -AsPlainText

# Retrieve the client key info from Key Vault
$clientkeyinfo = Get-AzKeyVaultKey -VaultName "$vaultname" -Name "$($serviceprincipal.DisplayName)"

# Convert the secret to a secure string
$secureSecretValue = ConvertTo-SecureString -String "$credsecret" -AsPlainText -Force


# Assuming $secureSecretValue is already a SecureString
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "$($clientkeyinfo.Id)",$secureSecretValue


$from = "DoNotReply@dd688cae-f235-4138-9b3f-5caae105b7d2.azurecomm.net"
$to = "jerrywolff@microsoft.com"

$subject = " Alert notification  for $spnname "
 
# Define the email message

$fileBytes1 = [System.IO.File]::ReadAllBytes("C:\temp\Azure_storage_account_sizes.html")

$fileBytes2 = [System.IO.File]::ReadAllBytes("C:\temp\Archer_,_lana_kane_and_Ci.JPEG")


$emailAttachment = @(
	@{
		ContentInBase64 = $fileBytes1
		ContentType = "text/html"
		Name = "Azure_storage_account_sizes.html"
	},
	@{
		ContentInBase64 = $fileBytes2
		ContentType = "image/png"
		Name = "archer"
		contentId = "$($fileBytes2.id)"
	}
)


$emailRecipientTo = @(
   @{
        Address = "$to"
        DisplayName = "Automation"
    }
)

$message = @{
	ContentSubject = "$subject"
	RecipientTo = @($emailRecipientTo)  # Array of email address objects
	SenderAddress = "$from"	
	ContentPlainText = "sample storage"	
    Attachment = @($emailAttachment) # Array of attachments
    ContentHtml = "<html><head><title>Enter title</title></head><body><img src='cid:inline-attachment' alt='Company Logo'/><h1>Emailtest from ACS- HTML</h1></body></html>"

}

# Send the email
Send-AzEmailServicedataEmail  -Message $message  -Endpoint "https://wolffacs.unitedstates.communication.azure.com/"

