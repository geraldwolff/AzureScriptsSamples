# Install MSAL.PS if not already installed
Install-Module -Name MSAL.PS -Scope CurrentUser -Force

# Connect using managed identity
$context = Connect-AzAccount #-Identity

# Set subscription context
Set-AzContext -Subscription "wolffofficesub"

$vaultname = 'wolffofficekvkv2'
$resourceGroup = 'Adminrg'
$spnname = 'wolffcalendarspn'
$displayName = "WOLFFCalendarManagerAppspn"
$logFile = "$env:USERPROFILE\kv_access_log.txt"
$removeIpAfter = $true  # Set to $false if you want to keep the IP in the firewall

# Get the app and service principal info
#$appinfo = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'"
$appinfo = Get-MgServicePrincipal -Filter "displayName eq 'WOLFFCalendarManagerAppspn'"
$clientId = "$($appinfo.AppId)"
$tenantId = (Get-AzContext).Tenant.Id
$scopes = "https://graph.microsoft.com/.default"

# Get your app registration info
$spninfo = Get-AzADApplication -DisplayName $displayName

# Try to get the secret
try {
    $clientsecret = Get-AzKeyVaultSecret -VaultName $vaultName -Name $($spninfo.displayname) -AsPlainText
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

        Start-Sleep -Seconds 5

        try {
            $clientsecret = Get-AzKeyVaultSecret -VaultName $vaultName -Name $($spninfo.displayname) -AsPlainText
        }
        catch {
            Write-Error "Retry failed. Still unable to retrieve the secret."
            return
        }
    }
    else {
        Write-Host "Could not extract IP address from error message."
        Write-Host "Raw error: $rawError"
        return
    }
}

# Ensure secret was retrieved
if (-not $clientsecret) {
    Write-Error "Client secret could not be retrieved. Aborting."
    return
}

# Convert to SecureString
#$secureClientSecret = ConvertTo-SecureString $($clientsecret)   -Force
$secureClientSecret = ConvertTo-SecureString $clientsecret -AsPlainText -Force

# Get token
$tokenResponse = Get-MsalToken `
    -ClientId $clientId `
    -TenantId $tenantId `
    -Scopes $scopes `
    -ClientSecret $secureClientSecret

Write-Host "Access token acquired successfully."

# Optional: Remove the IP from the firewall
if ($removeIpAfter -and $clientIp) {
    Write-Host "Removing $clientIp from Key Vault firewall..."
    $kv = Get-AzKeyVault -VaultName $vaultName
    $updatedIps = $kv.NetworkAcls.IpRules | Where-Object { $_.IpAddress -ne $clientIp }
    Update-AzKeyVaultNetworkRuleSet -VaultName $vaultName -IpAddressRange @($updatedIps.IpAddress)
    Write-Host "$clientIp removed from Key Vault firewall."

    # Log the removal
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "$timestamp - Removed IP $clientIp from $vaultName"
}

 


 
$scope = "https://graph.microsoft.com/.default"

$body = @{
    grant_type    = "client_credentials"
    client_id     = $clientId
    client_secret = $secureClientSecret
    scope         = $scope
}

$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" `
    -Method POST -Body $body

 $accessToken = $tokenResponse.access_token

# Extract access token
#$accessToken = $tokenResponse.AccessToken




#$accessToken = Get-MsalToken -ClientId "$clientId" -Scopes "https://graph.microsoft.com/Calendars.ReadWrite" 

#$accessToken



# Define event details
$eventBody = @{
    subject = "WOLFF Calendar Test Event"
    body = @{
        contentType = "Text"
        content = "This is a test event created via Microsoft Graph using delegated permissions."
    }
    start = @{
        dateTime = (Get-Date).AddHours(2).ToString("yyyy-MM-ddTHH:mm:ss")
        timeZone = "Pacific Standard Time"
    }
    end = @{
        dateTime = (Get-Date).AddHours(3).ToString("yyyy-MM-ddTHH:mm:ss")
        timeZone = "Pacific Standard Time"
    }
    location = @{
        displayName = "Virtual"
    }
    attendees = @(
        @{
            emailAddress = @{
                address = "<your-email@example.com>"
                name = "<Your Name>"
            }
            type = "required"
        }
    )
} | ConvertTo-Json -Depth 10


# Connect with delegated permissions
Connect-MgGraph -tenant $($context.Context.Tenant.Id)  -Scopes "Calendars.ReadWrite", "User.Read"

# Get the user object
$user = Get-MgUser -UserId "jerrywolff@wpi-corp.com"
$userid = $user.Id

# Define the event details
$eventBody = @{
    subject = "Strategy Sync with Team"
    body = @{
        contentType = "HTML"
        content = "Let's align on Q3 priorities and blockers."
    }
    start = @{
        dateTime = "2025-07-18T10:00:00"
        timeZone = "Pacific Standard Time"
    }
    end = @{
        dateTime = "2025-07-18T11:00:00"
        timeZone = "Pacific Standard Time"
    }
    location = @{
        displayName = "Microsoft Teams Meeting"
    }
    attendees = @(
        @{
            emailAddress = @{
                address = "gerald.wolff@outlook.com"
                name = "Jerry Wolff"
            }
            type = "required"
        }
    )
    isOnlineMeeting = $true
    onlineMeetingProvider = "teamsForBusiness"
} | ConvertTo-Json -Depth 10

# Create the event
$response = Invoke-MgGraphRequest -Method POST `
    -Uri "https://graph.microsoft.com/v1.0/users/$userid/events" `
    -Body $eventBody `
    -ContentType "application/json"

# Output the response
$response
