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
    
Description:  


#>
import-module -name az  -Force
import-module  Microsoft.Graph.Applications -verbose




# Connect using managed identity
$context = Connect-AzAccount   -Identity

$subscription = get-azsubscription -SubscriptionName wolffentpsub

Connect-MgGraph -tenant $($subscription.TenantId) -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All","Group.Read.All","Directory.Read.All","Directory.ReadWrite.All"

# Set subscription context
Set-AzContext -Subscription "wolffentpsub"

# Define variables
$vaultname = 'wolffkv'
$resourceGroup = 'Adminrg'
$spnname = 'wolffentpOAI'
$displayName = "wolffentpOAI"

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


 

# Output admin consent URL
Write-Host "`n Admin consent URL:"
Write-Host "https://login.microsoftonline.com/$($subscription.TenantId)/adminconsent?client_id=$($app.id)"
