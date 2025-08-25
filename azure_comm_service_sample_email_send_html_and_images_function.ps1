 $MaximumVariableCount = 8192
 $MaximumFunctionCount = 8192
   
  
  'Az.Communication', 'az',  'az.keyvault' | foreach-object {


  if((Get-InstalledModule -name $_))
  { 
    Write-Host " Module $_ exists  - updating" -ForegroundColor Green
         update-module $_ -force -ErrorAction Ignore 
    }
    else
    {
    write-host "module $_ does not exist - installing" -ForegroundColor red -BackgroundColor white
     
        install-module -name $_ -allowclobber
        import-module -name $_ -force
    }
   #  Get-InstalledModule
}
  
 
    
$logincontext =    connect-azaccount -Identity

function send_custom_message  
{


    param (
        [string]$imagepath,
        [string]$to,
        [string]$subject,
        [string]$messagetext,
        [string]$filepath
    )


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

    $File = [System.IO.File]::ReadAllBytes("$filepath")

    $Image = [System.IO.File]::ReadAllBytes("$imagepath")


    $emailAttachment = @(
	    @{
		    ContentInBase64 = $File
		    ContentType = "text/html"
		    Name = "$filepath"
	    },
	    @{
		    ContentInBase64 = $Image
		    ContentType = "image/png"
		    Name = "$imagepath"
		    contentId = "$($Image.id)"
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
	    ContentPlainText = "$messaagetext"	
        Attachment = @($emailAttachment) # Array of attachments
        ContentHtml = "<html><head><title>Enter title</title></head><body><img src='cid:inline-attachment' alt='Company Logo'/><h1>Emailtest from ACS- HTML</h1></body></html>"

    }

    # Send the email
    Send-AzEmailServicedataEmail  -Message $message  -Endpoint "https://wolffacs.unitedstates.communication.azure.com/"

}

 send_custom_message  -imagepath "C:\temp\chimpanzes_holding_a_sign.JPEG" -filepath "C:\temp\activitylog.html" -messagetext " chimpanzes_holding_a_sign" -subject "functional test" -to "jerrywolff@microsoft.com"


