 Install-Module -Name Az.Communication
 
 import-module   -Name Az.Communication
    
$logincontext =    connect-azaccount -Identity

    $vaultname = 'wolffkv' 
    $spnname = 'wolffcommsvcspn'
  
              
              #  Get-AzKeyVaultKey -VaultName "$vaultname" -Name "$($spnrec.displayname)"
 

            $serviceprincipal =  get-AzADServicePrincipal -DisplayName "$($spnrec.displayname)"

            $credsecret =       Get-AzKeyVaultsecret -VaultName "$vaultname" -name "$($serviceprincipal.appid)"  -AsPlainText

            $clientkeyinfo =  Get-AzKeyVaultKey -VaultName "$vaultname" -name "$($serviceprincipal.displayname)" 

            $secureSecretValue = ConvertTo-SecureString -String "$credsecret" -AsPlainText -Force


# Assuming $secureSecretValue is already a SecureString
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "$($clientkeyinfo.Id)",$secureSecretValue


$from = "DoNotReply@dd688cae-f235-4138-9b3f-5caae105b7d2.azurecomm.net"
$to = "jerrywolff@microsoft.com"

$subject = " Alert notification  for $spnname "
 
# Define the email message

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
	ContentPlainText = "$($clientkeyinfo.Tags)"	
}

# Send the email
Send-AzEmailServicedataEmail  -Message $message  -Endpoint "https://wolffacs.unitedstates.communication.azure.com/"

