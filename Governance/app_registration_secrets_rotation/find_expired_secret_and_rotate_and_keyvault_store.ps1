<#
.NOTES

    THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 

    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 

    FITNESS FOR A PARTICULAR PURPOSE.

    This sample is not supported under any Microsoft standard support program or service. 

    The script is provided AS IS without warranty of any kind. Microsoft further disclaims all

    implied warranties including, without limitation, any implied warranties of merchantability

    or of fitness for a particular purpose. The entire risk arising out of the use or performance

    of the sample and documentation remains with you. In no event shall Microsoft, its authors,

    or anyone else involved in the creation, production, or delivery of the script be liable for 

    any damages whatsoever (including, without limitation, damages for loss of business profits, 

    business interruption, loss of business information, or other pecuniary loss) arising out of 

    the use of or inability to use the sample or documentation, even if Microsoft has been advised 

    of the possibility of such damages, rising out of the use of or inability to use the sample script, 

    even if Microsoft has been advised of the possibility of such damages.
    
Description:  This script automates the rotation of expired secrets for Azure AD App Registrations and securely stores the new secrets in Azure Key Vault. It also ensures that necessary network firewall rules and access policies are updated to allow secret management via managed identity.

✅ Prerequisites
Before running this script, ensure the following:


Modules Installed:

Az module (via Import-Module -Name Az -Force)
Microsoft.Graph.Applications module (via Import-Module Microsoft.Graph.Applications -Verbose)



Managed Identity Access:

The script uses Connect-AzAccount -Identity, so it must be run in a context where a managed identity is available (e.g., Azure Automation, VM with system-assigned identity).



Permissions:

Managed identity must have:

Contributor or Owner access to the subscription.
Key Vault Administrator or equivalent access to manage secrets.
Microsoft Graph API permissions: Application.ReadWrite.All, AppRoleAssignment.ReadWrite.All, Group.Read.All, Directory.Read.All, Directory.ReadWrite.All.

 
Environment Setup:

Subscription name: "<Subscriptionname>"
Key Vault name: "<keyvaultname>"
Resource group: "<resourcegroup oAdminrg"
App Registration display name: "wolffentpOAI"




🧩 Script Breakdown
1. Module Imports & Authentication
PowerShellImport-Module -Name Az -ForceImport-Module Microsoft.Graph.Applications -VerboseShow more lines

Loads required modules and authenticates using managed identity.


2. Subscription & Graph Connection
PowerShell$subscription = Get-AzSubscription -SubscriptionName wolffentpsubConnect-MgGraph -Tenant $($subscription.TenantId) -Scopes ...Show more lines

Retrieves subscription context and connects to Microsoft Graph.


3. Function: rotate_expired_secrets

Purpose: Rotates secrets for a given App Registration.
Steps:

Retrieves the App and Service Principal.
Adds current and automation IPs to Key Vault firewall if missing.
Updates Key Vault access policy for the SP.
Creates a new secret and stores it in Key Vault.
Handles errors by retrying and logging IP additions.




4. Function: remove_expired_credential_secrets

Purpose: Deletes expired secrets from App Registrations.
Steps:

Uses Remove-AzADAppCredential to clean up old credentials.




5. Secret Expiration Audit

Purpose: Audits all App Registrations for secrets/certificates expiring within 30 days.
Steps:

Loops through all apps and credentials.
Flags expired items and stores metadata in $expirationlist.




6. Rotation Execution

Purpose: Executes rotation and cleanup for expired credentials.
Steps:

Loops through $expirationlist.
Calls remove_expired_credential_secrets and rotate_expired_secrets for each expired item.




📌 Key Features

Firewall Rule Automation: Dynamically adds IPs to Key Vault network ACLs.
Error Handling: Captures and retries on IP-related access errors.
Credential Lifecycle Management: Ensures secrets are rotated and stored securely.
Logging: Logs IP additions and errors for traceability.


#>
import-module -name az  -Force
import-module  Microsoft.Graph.Applications -verbose




# Connect using managed identity
$context = Connect-AzAccount   -Identity

$subscription = get-azsubscription -SubscriptionName wolffentpsub

Connect-MgGraph -tenant $($subscription.TenantId) -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All","Group.Read.All","Directory.Read.All","Directory.ReadWrite.All"

# Set subscription context
Set-AzContext -Subscription "wolffentpsub"

Function rotate_expired_secrets ([string]$appspn_displayname)
{

        # Define variables
        $vaultname = 'wolffkv'
        $resourceGroup = 'Adminrg'
        $spnname = "$appspn_displayname"
        $displayName = "$appspn_displayname"

        $sp = @()

        # Select subscription
        #$subscription = Get-AzSubscription | Out-GridView -Title "Select a subscription:" -PassThru | Select-Object Name, Id, TenantId -First 1

        Write-Host "Tenant/sub : $($subscription.Name) - $($subscription.TenantId)" -ForegroundColor Green

        Set-AzContext -Subscription $($subscription.Name) -Tenant $($subscription.TenantId)



 
        $appinfo = get-azadapplication | where displayname -eq $displayname 

        start-sleep -seconds 60
 
 


        # Create the service principal
 
        $sp = get-AzADServicePrincipal -ApplicationId $($appinfo.appid)


        start-sleep -seconds 60
 
        ############

 


         #######  Add my current ip address to the network firewallrule if not there 

        # Get your current public IP address
        $myIp = (Invoke-RestMethod -Uri "https://api.ipify.org?format=json").ip

        # Get current IP rules
        $kv = Get-AzKeyVault -VaultName $vaultName -ResourceGroupName $resourceGroup
        $currentIps = $kv.NetworkAcls.IpRules.IpAddressOrRange

        # Add your IP if it's not already in the list
        if ($currentIps -notcontains $myIp) {
            $updatedIps = $currentIps + $myIp

            # Update the Key Vault network rules
            Update-AzKeyVaultNetworkRuleSet -VaultName $vaultName `
                -ResourceGroupName $resourceGroup `
                -IpAddressRange $updatedIps `
                -DefaultAction Deny

            Write-Host "✅ Added IP $myIp to Key Vault firewall rules."
        } else {
            Write-Host "ℹ️ IP $myIp is already allowed."
        }


        #$automationIp = "20.236.10.163"  # for automation MI internal Microsoft IP only not public

        $kv = Get-AzKeyVault -VaultName $vaultName -ResourceGroupName $resourceGroup
        $currentIps = $kv.NetworkAcls.IpRules.IpAddressOrRange

        # Add the automation IP if not already present
        if ($currentIps -notcontains $automationIp) {
            $updatedIps = $currentIps + $automationIp

            Update-AzKeyVaultNetworkRuleSet -VaultName $vaultName `
                -ResourceGroupName $resourceGroup `
                -IpAddressRange $updatedIps `
                -DefaultAction Allow

            Write-Host "✅ Added automation IP $automationIp to Key Vault firewall rules."
        } else {
            Write-Host "ℹ️ IP $automationIp is already allowed."
        }
 

         $vault =   Get-AzKeyVault -VaultName "$vaultname" -ResourceGroupName "$resourceGroup"  -SubscriptionId $($subscription.Id)

         Update-AzKeyVaultNetworkRuleSet -VaultName "$vaultname" -Bypass AzureServices


        Set-AzKeyVaultAccessPolicy -VaultName "$vaultname" `
            -ObjectId "$($sp.id)" `
            -PermissionsToSecrets set,get,list


            $startdate = get-date
            $enddate = (Get-Date).AddYears(5)
      #used to create expired secrets for testing
      #  enddate = (Get-Date).adddays(1)

            $customKey = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("wolffentpopenaisecret"))

                $clientSecret = New-AzADAppCredential -ApplicationId $($sp.AppId) -EndDate $enddate -StartDate $startdate -CustomKeyIdentifier  "$customKey"
                $secureSecretValue = ConvertTo-SecureString -String $($clientSecret.SecretText) -AsPlainText -Force
       
              Update-AzKeyVaultNetworkRuleSet -DefaultAction Allow -VaultName $vaultname

         try {              
                    Update-AzKeyVault -ResourceGroupName $resourceGroup `
                                      -VaultName $vaultname `
                                     -PublicNetworkAccess Enabled  

                (Get-AzContext).Account.Id


                $userobjectid = (Get-AzADUser -UserPrincipalName (Get-AzContext).Account.Id).Id


                Set-AzKeyVaultAccessPolicy `
                  -VaultName "wolffkv" `
                  -ObjectId "$userobjectid" `
                  -PermissionsToSecrets get, list, delete, purge, set


           ####################################

            Set-AzKeyVaultSecret -VaultName $vaultname -Name $sp.Displayname `
            -SecretValue $secureSecretValue `
            -Tag @{Purpose = "Spnautomation"; AppId = "$($sp.id)"; Enddatetime = "$($sp.Enddate)"; keyid = "$($sp.keyid)"} `
            -ContentType "$($sp.Appid)" 

        }
        catch {
            $rawError = $Error[0].ToString()

            if ($rawError -match "Client address: (\d{1,3}(?:\.\d{1,3}){3})") {
                $clientIp = $matches[1]
                Write-Host "Detected client IP: $clientIp"

                # Add IP to firewall
                Write-Host "Adding $clientIp to Key Vault firewall..."
                Update-AzKeyVaultNetworkRuleSet -VaultName $vaultName -IpAddressRange $clientIp
                Write-Host "IP address added. Retrying secret retrieval..."

                # Log the IP and timestamp
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Add-Content -Path $logFile -Value "$timestamp - Added IP $clientIp to $vaultName"

            else {

                Write-Host "Raw error: $rawError"
                return
            }

                Start-Sleep -Seconds 15

                try {


                    Set-AzKeyVaultSecret -VaultName $vaultname -Name $($sp.Displayname)`
                        -SecretValue $secureSecretValue `
                        -Tag @{Purpose = "Spnautomation"; AppId = "$($sp.id)"; Enddatetime = "$($sp.Enddate)"; keyid = "$($sp.keyid)"} `
                        -ContentType "$($sp.Appid)"

                }
                catch {

                        Set-AzKeyVaultAccessPolicy `
                          -VaultName "wolffkv" `
                          -ObjectId "$userobjectid" `
                          -PermissionsToSecrets get, list, delete, purge, set

          #########  To cleanup old secrets if this is re-run with the same app name


                    Remove-AzKeyVaultSecret -VaultName $vaultname -Name "$($sp.Displayname)" -Force -InRemovedState 
                             
                             
                    Set-AzKeyVaultSecret -VaultName $vaultname -Name $($sp.Displayname) `
                        -SecretValue $secureSecretValue `
                        -Tag @{Purpose = "Spnautomation"; AppId = "$($sp.id)"; Enddatetime = "$($sp.Enddate)"; keyid = "$($sp.keyid)"} `
                        -ContentType "$($sp.Appid)"

          
                    return
                }
            }

        }

}
  

Function remove_expired_credential_secrets ([string]$appspn_displayname,[string]$keyid)
{
    

    $expiredsec_tobedeleted = Get-AzADApplication -DisplayName $appspn_displayname | Remove-AzADAppCredential  -verbose  #-whatif 
    
    Write-host "Removing old expired secret from App Registration for $($appspn_displayname) " -ForegroundColor Red -BackgroundColor white
     Write-host "new secret already created as replacement and stored in $($vaultname) -  $($appspn_displayname) " -ForegroundColor black -BackgroundColor white
} 




  ###################################################################
  $expirationlist = ''

# Set expiration threshold (e.g., 30 days)
$thresholdDays = 30
$cutoffDate = (Get-Date).AddDays($thresholdDays)

# Get all App Registrations
$appRegistrations = Get-AzADApplication

foreach ($app in $appRegistrations) {
    # Check Password Credentials
    foreach ($cred in $app.PasswordCredentials) {
        $daysRemaining = ($cred.EndDateTime - (Get-Date)).Days
        Write-Host "App: $($app.DisplayName) - Secret expires on:" -NoNewline

        if ($daysRemaining -le $thresholdDays) {
            Write-Host " $($cred.EndDateTime)" -ForegroundColor Red -BackgroundColor White
            $seccertstatus = "Expired"
        } else {
            Write-Host " $($cred.EndDateTime)" -ForegroundColor Green
            $seccertstatus = "Active"
        }

        $seccertobj = new-object PSObject 

        $seccertobj | Add-member -MemberType NoteProperty -name  App  -value $($app.DisplayName)
        $seccertobj | Add-member -MemberType NoteProperty -name Expireson    -value $($cred.EndDateTime)
        $seccertobj | Add-member -MemberType NoteProperty -name status   -value $seccertstatus
        $seccertobj | Add-member -MemberType NoteProperty -name keyid   -value  $($cred.KeyId)
        $seccertobj | Add-member -MemberType NoteProperty -name type   -value  "PasswordCredentials"


        [array]$expirationlist += $seccertobj
    }

    # Check Key Credentials (Certificates)
    foreach ($cert in $app.KeyCredentials) {
        $certDaysRemaining = ($cert.EndDateTime - (Get-Date)).Days
        Write-Host "App: $($app.DisplayName) - Certificate expires on:" -NoNewline

        if ($certDaysRemaining -le $thresholdDays) {
            Write-Host " $($cert.EndDateTime)" -ForegroundColor Red -BackgroundColor White
        } else {
            Write-Host " $($cert.EndDateTime)" -ForegroundColor Green
        }

         $seccertobj = new-object PSObject 

        $seccertobj | Add-member -MemberType NoteProperty -name App  -value $($app.DisplayName)
        $seccertobj | Add-member -MemberType NoteProperty -name Expireson    -value $($cert.EndDateTime)
        $seccertobj | Add-member -MemberType NoteProperty -name status   -value $seccertstatus
        $seccertobj | Add-member -MemberType NoteProperty -name keyid   -value $($cert.KeyId)
        $seccertobj | Add-member -MemberType NoteProperty -name type   -value  "Certkeycredential"

        [array]$expirationlist += $seccertobj

    }
}



foreach($appspn in $expirationlist)
{
    
       if($appspn.status -eq "Expired" -or $appspn.status -eq $null)
    {
         remove_expired_credential_secrets -appspn_displayname $($appspn.app) -keyid $($appspn.keyid)
        write-host "$($appspn.app) - $($appspn.status)" -ForegroundColor green 

             Write-host "adding new secret/cred to  $($appspn.app) " -ForegroundColor blue -BackgroundColor white

   rotate_expired_secrets -appspn_displayname $($appspn.app)
     }





}

# Get all App Registrations
$appRegistrations = Get-AzADApplication

foreach ($app in $appRegistrations) {
    # Check Password Credentials
    foreach ($cred in $app.PasswordCredentials) {
        $daysRemaining = ($cred.EndDateTime - (Get-Date)).Days
        Write-Host "App: $($app.DisplayName) - Secret expires on:" -NoNewline

        if ($daysRemaining -le $thresholdDays) {
            Write-Host " $($cred.EndDateTime)" -ForegroundColor Red -BackgroundColor White
            $seccertstatus = "Expired"
        } else {
            Write-Host " $($cred.EndDateTime)" -ForegroundColor Green
            $seccertstatus = "Active"
        }

    }

}

 