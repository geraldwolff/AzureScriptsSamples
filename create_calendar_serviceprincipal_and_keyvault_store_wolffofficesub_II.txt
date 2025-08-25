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
    
Description: Integration for Calendar Management
This script automates the creation and configuration of an Azure AD application and service principal
 for managing calendar events via Microsoft Graph. It also securely stores the app credentials in Azure Key Vault and configures network access policies.

✅ Actions Performed
Module Import & Authentication

Imports Microsoft.Graph.Applications module with verbose output.
Authenticates to Azure using managed identity and sets the subscription context to "wolffofficesub".
App Registration

Creates a new Azure AD application named WOLFFCalendarManagerAppspn with specified homepage and identifier URI.
Retrieves the app owner (admin@wpi-corp.com) and assigns ownership (commented out in current script).
Service Principal Creation

Generates a service principal for the registered app.
Retrieves the Microsoft Graph service principal and assigns required Graph API permissions:
Calendars.Read, Calendars.ReadWrite, MailboxSettings.Read, User.Read.All.
Metadata Recording

Captures and stores metadata about the service principal and app registration (e.g., tenant ID, client ID,
 secret, key ID, validity dates).
Key Vault Configuration

Retrieves current IP rules and adds the user's public IP and automation IP (20.236.10.163) if not already
 present.
Updates Key Vault network rules and enables public network access.
Sets access policies for the service principal and current user to manage secrets.
Secret Management

Generates a new client secret for the app and stores it in Azure Key Vault.
Tags the secret with metadata for automation tracking.
Implements error handling to dynamically add client IP to firewall rules if access is denied, then retries
 secret creation and storage.
Admin Consent URL Output

Displays the admin consent URL for granting permissions to the app.
📌 Requirements
Azure Modules: Microsoft.Graph.Applications, Az.Accounts, Az.Resources, Az.KeyVault, Az.AD
Permissions:
Admin privileges to register applications and assign Graph roles.
Access to modify Key Vault network rules and set access policies.
Key Vault: Must exist with name wolffofficekvkv2 in resource group Adminrg.
Subscription Selection: Interactive selection via Out-GridView.
Firewall Access: Script must be run from an IP address that can be added to Key Vault rules if needed.


#>
import-module -name az  -Force
import-module  Microsoft.Graph.Applications -verbose




# Connect using managed identity
$context = Connect-AzAccount # -tenant wolffofficetenant -Subscription wolffofficesub # -Identity

# Set subscription context
Set-AzContext -Subscription "wolffofficesub"

# Define variables
$vaultname = 'wolffofficekvkv2'
$resourceGroup = 'Adminrg'
$spnname = 'wolffcalendarspn'
$displayName = "WOLFFCalendarManagerAppspn"
$appowner = get-azaduser | where mail -eq 'admin@wpi-corp.com'
$spnrec = @()

# Select subscription
$subscription = Get-AzSubscription | Out-GridView -Title "Select a subscription:" -PassThru | Select-Object Name, Id, TenantId -First 1


Write-Host "Tenant/sub : $($subscription.Name) - $($subscription.TenantId)" -ForegroundColor Green

# Connect to Microsoft Graph with admin privileges
Connect-MgGraph -tenant $($subscription.TenantId) -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"


Set-AzContext -Subscription $($subscription.Name) -Tenant $($subscription.TenantId)





$app = New-AzADApplication -DisplayName $displayName `
    -IdentifierUris "https://wpi-corp.com/CalendarManagerApp" `
    -HomePage "https://wpi-corp.com/CalendarManagerApp" 


 $params = @{
  "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($appowner.id)"
}

$appinfo = get-azadapplication | where displayname -eq $displayname

start-sleep -seconds 60
#$newowner = New-MgApplicationOwnerByRef -ApplicationId $($appinfo.AppId) -BodyParameter $params

 


# Create the service principal
$newsp = New-AzADServicePrincipal -ApplicationId $($appinfo.appid)
$sp = get-AzADServicePrincipal -ApplicationId $($appinfo.appid)


start-sleep -seconds 60



# Get Microsoft Graph SPN
$graphSp = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'"



# Get your app's SPN
#$mySp = Get-MgServicePrincipal -ServicePrincipalId 

# Assign Graph application permissions
$permissions = @("Calendars.Read", "Calendars.ReadWrite", "MailboxSettings.Read", "User.Read.All")
foreach ($perm in $permissions) {
    $appRole = $($graphSp.AppRoles) | Where-Object { $_.Value -eq $perm -and $_.AllowedMemberTypes -contains "Application" }
    if ($appRole) {
        New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $($sp.Id) `
            -PrincipalId $($Sp.Id) `
            -ResourceId $($graphSp.Id) `
            -AppRoleId $($appRole.Id) 

        Write-Output "✅ Assigned $perm"
    } else {
        Write-Warning "⚠️ Permission $perm not found in Microsoft Graph"
    }
}

# Record SPN metadata
$spnobj = New-Object PSObject
$spnobj | Add-Member -MemberType NoteProperty -Name Tenantid -Value $($subscription.TenantId)
$spnobj | Add-Member -MemberType NoteProperty -Name Applicationid -Value $($app.AppId)
$spnobj | Add-Member -MemberType NoteProperty -Name Displayname -Value $($app.DisplayName)
$spnobj | Add-Member -MemberType NoteProperty -Name ClientID -Value $($app.AppId)
$spnobj | Add-Member -MemberType NoteProperty -Name Appid -Value $($appinfo.AppId)
$spnobj | Add-Member -MemberType NoteProperty -Name Clientsecret -Value $appSecret
$spnobj | Add-Member -MemberType NoteProperty -Name Keyid -Value ([guid]::NewGuid())
$spnobj | Add-Member -MemberType NoteProperty -Name Enddate -Value (Get-Date).AddYears(1)
$spnobj | Add-Member -MemberType NoteProperty -Name Startdate -Value (Get-Date)
$spnobj | Add-Member -MemberType NoteProperty -Name Objectid -Value $($sp.Id)
$spnrec = $spnobj



############

 
 <#######  Add my current ip address to the network firewallrule if not there 

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

# Get current IP rules
$kv = Get-AzKeyVault -VaultName $vaultName -ResourceGroupName $resourceGroup
$currentIps = $kv.NetworkAcls.IpRules.IpAddressOrRange

# Add the automation IP if not already present
if ($currentIps -notcontains $automationIp) {
    $updatedIps = $currentIps + $automationIp

    Update-AzKeyVaultNetworkRuleSet -VaultName $vaultName `
        -ResourceGroupName $resourceGroup `
        -IpAddressRange $updatedIps `
        -DefaultAction Deny

    Write-Host "✅ Added automation IP $automationIp to Key Vault firewall rules."
} else {
    Write-Host "ℹ️ IP $automationIp is already allowed."
}
#>

#$vault =   Get-AzKeyVault -VaultName "$vaultname" -ResourceGroupName "$resourceGroup"  -SubscriptionId $($subscription.Id)

Update-AzKeyVaultNetworkRuleSet -VaultName "$vaultname" -Bypass AzureServices


Set-AzKeyVaultAccessPolicy -VaultName "$vaultname" `
    -ObjectId "$($sp.id)" `
    -PermissionsToSecrets set,get,list




try {

        $clientSecret = New-AzADAppCredential -ApplicationId $($spnrec.ClientID) 
        $secureSecretValue = ConvertTo-SecureString -String $clientSecret.SecretText -AsPlainText -Force
       
     #  Update-AzKeyVaultNetworkRuleSet -DefaultAction Allow -VaultName $vaultname
               
            Update-AzKeyVault -ResourceGroupName $resourceGroup `
                              -VaultName $vaultname `
                             -PublicNetworkAccess Enabled  

        (Get-AzContext).Account.Id


        $userobjectid = (Get-AzADUser -UserPrincipalName (Get-AzContext).Account.Id).Id


        Set-AzKeyVaultAccessPolicy `
  -VaultName "wolffofficekvkv2" `
  -ObjectId "$userobjectid" `
  -PermissionsToSecrets get, list, delete, purge, set




    Set-AzKeyVaultSecret -VaultName $vaultname -Name $spnrec.Displayname `
    -SecretValue $secureSecretValue `
    -Tag @{Purpose = "Spnautomation"; Clientid = "$($spnrec.ClientID)"; Enddatetime = "$($spnrec.Enddate)"; keyid = "$($spnrec.keyid)"} `
    -ContentType "$($spnrec.Appid)" 

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

        Start-Sleep -Seconds 15

        try {

                $clientSecret = New-AzADAppCredential -ApplicationId $($spnrec.ClientID)
        $secureSecretValue = ConvertTo-SecureString -String $clientSecret.SecretText -AsPlainText -Force

            Set-AzKeyVaultSecret -VaultName $vaultname -Name $($spnrec.Displayname)`
    -SecretValue $secureSecretValue `
    -Tag @{Purpose = "Spnautomation"; Clientid = "$($spnrec.ClientID)"; Enddatetime = "$($spnrec.Enddate)"; keyid = "$($spnrec.keyid)"} `
    -ContentType "$($spnrec.Appid)"

        }
        catch {

        Set-AzKeyVaultAccessPolicy `
  -VaultName "wolffofficekvkv2" `
  -ObjectId "$userobjectid" `
  -PermissionsToSecrets get, list, delete, purge, set

  #########  To cleanup old secrets if this is re-run with the same app name


               Remove-AzKeyVaultSecret -VaultName $vaultname -Name "$($spnrec.Displayname)" -Force -InRemovedState 

##########################
        
                  Update-AzKeyVaultNetworkRuleSet -DefaultAction Allow -VaultName $vaultname
               
                 Update-AzKeyVault -ResourceGroupName $resourceGroup `
                              -VaultName $vaultname `
                              -PublicNetworkAccess Enabled  
                             
                             
          $clientSecret = New-AzADAppCredential -ApplicationId $($spnrec.ClientID)
        $secureSecretValue = ConvertTo-SecureString -String $clientSecret.SecretText -AsPlainText -Force

            Set-AzKeyVaultSecret -VaultName $vaultname -Name $($spnrec.Displayname) `
    -SecretValue $secureSecretValue `
    -Tag @{Purpose = "Spnautomation"; Clientid = "$($spnrec.ClientID)"; Enddatetime = "$($spnrec.Enddate)"; keyid = "$($spnrec.keyid)"} `
    -ContentType "$($spnrec.Appid)"

            Write-Error "Retry failed. fixing network access."
            return
        }
    }
    else {
        Write-Host "Could not extract IP address from error message."
        Write-Host "Raw error: $rawError"
        return
    }
}


 

# Output admin consent URL
Write-Host "`n Admin consent URL:"
Write-Host "https://login.microsoftonline.com/$($subscription.TenantId)/adminconsent?client_id=$($app.ApplicationId)"
