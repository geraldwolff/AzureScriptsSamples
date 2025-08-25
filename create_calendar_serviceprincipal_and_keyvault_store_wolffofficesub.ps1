# Connect using managed identity
$context = Connect-AzAccount # -Identity

# Set subscription context
Set-AzContext -Subscription "wolffofficesub"

# Define variables
$vaultname = 'wolffofficekvkv'
$resourceGroup = 'Adminrg'
$spnname = 'wolffcalendarspn'
$displayName = "WOLFFCalendarManagerAppspn"
$appowner = get-azaduser | where mail -eq 'admin@wpi-corp.com'
$spnrec = @()

# Select subscription
$subscription = Get-AzSubscription | Out-GridView -Title "Select a subscription:" -PassThru | Select-Object Name, Id, TenantId -First 1
Set-AzContext -Subscription $($subscription.Name) -Tenant $($subscription.TenantId)

Write-Host "Tenant/sub : $($subscription.Name) - $($subscription.TenantId)" -ForegroundColor Green

# Connect to Microsoft Graph with admin privileges
Connect-MgGraph -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"

$app = New-AzADApplication -DisplayName $displayName `
    -IdentifierUris "https://wpi-corp.com/CalendarManagerApp" `
    -HomePage "https://wpi-corp.com/CalendarManagerApp" 


 $params = @{
  "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($appowner.id)"
}

New-MgApplicationOwnerByRef -ApplicationId $($app.AppId) -BodyParameter $params

 
$appinfo = get-azadapplication | where displayname -eq $displayname

# Create the service principal
$sp = New-AzADServicePrincipal -ApplicationId $($appinfo.appid)


start-sleep -seconds 60



# Get Microsoft Graph SPN
$graphSp = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'"



# Get your app's SPN
$mySp = Get-MgServicePrincipal | where appId -eq "$($appinfo.appid)"

# Assign Graph application permissions
$permissions = @("Calendars.Read", "Calendars.ReadWrite", "MailboxSettings.Read", "User.Read.All")
foreach ($perm in $permissions) {
    $appRole = $($graphSp.AppRoles) | Where-Object { $_.Value -eq $perm -and $_.AllowedMemberTypes -contains "Application" }
    if ($appRole) {
        New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $($mySp.Id) `
            -PrincipalId $($mySp.Id) `
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


$automationIp = "20.236.10.163"  # for automation MI internal Microsoft IP only not public

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


$vault =   Get-AzKeyVault -VaultName "$vaultname" -ResourceGroupName "$resourceGroup"  -SubscriptionId $($subscription.Id)

Update-AzKeyVaultNetworkRuleSet -VaultName "$vaultname" -Bypass AzureServices


Set-AzKeyVaultAccessPolicy -VaultName "$vaultname" `
    -ObjectId "$($mysp.id)" `
    -PermissionsToSecrets set,get,list



# Store secret in Key Vault
$secureSecretValue = ConvertTo-SecureString -String $($spnrec.Clientsecret) -AsPlainText -Force

try {

        $clientSecret = New-AzADAppCredential -ApplicationId $($spnrec.ClientID)
        $secureSecretValue = ConvertTo-SecureString -String $clientSecret.SecretText -AsPlainText -Force
       
     #  Update-AzKeyVaultNetworkRuleSet -DefaultAction Allow -VaultName $vaultname
               
      #      Update-AzKeyVault -ResourceGroupName $resourceGroup `
      #                        -VaultName $vaultname `
      #                        -PublicNetworkAccess Enabled  


    Set-AzKeyVaultSecret -VaultName $vaultname -Name 'wolffcalendarspn-secret' `
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

            Set-AzKeyVaultSecret -VaultName $vaultname -Name 'wolffcalendarspn-secret' `
    -SecretValue $secureSecretValue `
    -Tag @{Purpose = "Spnautomation"; Clientid = "$($spnrec.ClientID)"; Enddatetime = "$($spnrec.Enddate)"; keyid = "$($spnrec.keyid)"} `
    -ContentType "$($spnrec.Appid)"

        }
        catch {


        
                  Update-AzKeyVaultNetworkRuleSet -DefaultAction Allow -VaultName $vaultname
               
                 Update-AzKeyVault -ResourceGroupName $resourceGroup `
                              -VaultName $vaultname `
                              -PublicNetworkAccess Enabled  
                             
                             
          $clientSecret = New-AzADAppCredential -ApplicationId $($spnrec.ClientID)
        $secureSecretValue = ConvertTo-SecureString -String $clientSecret.SecretText -AsPlainText -Force

            Set-AzKeyVaultSecret -VaultName $vaultname -Name 'wolffcalendarspn-secret' `
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


<# Optional: Create a Key Vault key for metadata
Remove-AzKeyVaultKey -VaultName $vaultname -Name $($spnrec.Displayname) -Force -InRemovedState -ErrorAction Ignore
Add-AzKeyVaultKey -VaultName $vaultname -Name $($spnrec.Displayname) `
    -Tag @{Purpose = "spncalendar"; Clientid = "$($spnrec.ClientID)"; Enddatetime = "$($spnrec.Enddate)"; keyid = "$($spnrec.keyid)"} `
    -Destination Software
#>


# Output admin consent URL
Write-Host "`n Admin consent URL:"
Write-Host "https://login.microsoftonline.com/$($subscription.TenantId)/adminconsent?client_id=$($app.ApplicationId)"
