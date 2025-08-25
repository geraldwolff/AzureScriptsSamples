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
  Script Description: Calendar Event Creation via Microsoft Graph with Azure Key Vault Integration
This PowerShell script automates the creation of a Microsoft Teams calendar event using Microsoft Graph API
 and securely retrieves credentials from Azure Key Vault. It is designed for use within the context of the 
 wolffofficesub Azure subscription.

  Setup and Authentication
Modules & Context: Imports the Microsoft Graph Calendar module and sets the Azure subscription context.
Graph Connection: Connects to Microsoft Graph with delegated permissions for managing applications and role 
assignments.
  Key Vault Access
Vault Configuration: Updates network rules and public access settings for the Key Vault named wolffofficekvkv2 
in resource group Adminrg.
Secret Retrieval: Attempts to retrieve the client secret for the app registration WOLFFCalendarManagerAppspn. 
If blocked by firewall rules, it dynamically adds the client IP to the Key Vault’s access list and retries.
  Token Acquisition
Uses the retrieved client secret to request an access token from Microsoft’s OAuth2 endpoint for Graph API access.
  Calendar Event Definition
Defines a Teams meeting titled “POC Strategy Sync” for user jerrywolff@wpi-corp.com, scheduled on July 31, 2025, 
from 10:00 AM to 11:00 AM PST.
Includes HTML-formatted body content and specifies the meeting as online via Teams.
  Event Creation
Retrieves the target user's email via Graph.
Sends a POST request to Microsoft Graph to create the calendar event.
Logs the response to a local file for auditing.
 
 
 #>
 
 
 
 
    Import-Module Microsoft.Graph.Calendar

# Set subscription context
Connect-AzAccount #-Identity
$context = Set-AzContext -Subscription "wolffofficesub"

# Variables
$vaultname = 'wolffofficekvkv2'
$resourceGroup = 'Adminrg'
  
$displayName = "WOLFFCalendarManagerAppspn"
$logFile = "$env:USERPROFILE\kv_access_log.txt"
$removeIpAfter = $true

# Connect to Microsoft Graph with delegated permissions
Connect-MgGraph -tenant $($subscription.TenantId) -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"

# Get app registration info
$app = Get-AzADApplication -DisplayName $displayName
$clientId = $app.AppId
$tenantId = (Get-AzContext).Tenant.Id
$scopes = "https://graph.microsoft.com/.default"
$secretName = $($app.displayname) 

                  Update-AzKeyVaultNetworkRuleSet -DefaultAction Allow -VaultName $vaultname
               
                 Update-AzKeyVault -ResourceGroupName $resourceGroup `
                              -VaultName $vaultname `
                              -PublicNetworkAccess Enabled  


# Try to retrieve the client secret from Key Vault
try {
    $clientSecret = Get-AzKeyVaultSecret -VaultName $vaultName -Name $secretName -AsPlainText
    if ([string]::IsNullOrWhiteSpace($clientSecret)) {
        throw "Client secret is empty. Check the Key Vault secret value."
    }
}
catch {
    $rawError = $_.Exception.Message
    if ($rawError -match "Client address: (\d{1,3}(?:\.\d{1,3}){3})") {
        $clientIp = $matches[1]
        Write-Host "Detected client IP: $clientIp"

        # Add IP to firewall
        Update-AzKeyVaultNetworkRuleSet -VaultName $vaultName -IpAddressRange $clientIp
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Added IP $clientIp to $vaultName"
        Start-Sleep -Seconds 15

        # Retry secret retrieval
        $clientSecret = Get-AzKeyVaultSecret -VaultName $vaultName -Name $secretName -AsPlainText
        if ([string]::IsNullOrWhiteSpace($clientSecret)) {
            # Fallback: open public access
            Update-AzKeyVaultNetworkRuleSet -DefaultAction Allow -VaultName $vaultName
            Update-AzKeyVault -ResourceGroupName $resourceGroup -VaultName $vaultName -PublicNetworkAccess Enabled
            $clientSecret = Get-AzKeyVaultSecret -VaultName $vaultName -Name $secretName -AsPlainText
        }
    } else {
        Write-Error "Could not extract IP address. Raw error: $rawError"
        return
    }
}

# Get access token
$tokenBody = @{
    grant_type    = "client_credentials"
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = $scopes
}

try {
    $tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" `
        -Method POST -Body $tokenBody
    $accessToken = $tokenResponse.access_token
}
catch {
    Write-Error "Failed to acquire token: $($_.Exception.Message)"
    return
}

# Define calendar event
$UPN = "jerrywolff@wpi-corp.com"
$event = @{
    subject = "Protyp Sync"
    body = @{
        contentType = "HTML"
        content = "This meeting was scheduled using application permissions."
    }
    start = @{
        dateTime = "2025-08-31T10:00:00"
        timeZone = "Pacific Standard Time"
    }
    end = @{
        dateTime = "2025-08-31T11:00:00"
        timeZone = "Pacific Standard Time"
    }
    location = @{
        displayName = "Microsoft Teams Meeting"
    }
    attendees = @(
        @{
            emailAddress = @{
                address = $userEmail
                name = "Target User"
            }
            type = "required"
        }
    )
    isOnlineMeeting = $true
    onlineMeetingProvider = "teamsForBusiness"
} | ConvertTo-Json -Depth 10

# Create the event
try {
$useremailinfo = Get-MgUser | where Userprincipalname -eq  "$upn"
$useremail = $($useremailinfo.mail)

    $response = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/$userEmail/events" `
        -Headers @{ Authorization = "Bearer $accessToken" } `
        -Method POST `
        -Body $event `
        -ContentType "application/json"
    $response
    $response | Out-File c:\temp\calendar_create_response.txt -Encoding unicode

 
 
     
}
catch {
    Write-Error "Failed to create calendar event: $($_.Exception.Message)"
}













