# Connect to Azure using managed identity
Connect-AzAccount -Identity

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
        } else {
            Write-Host " $($cred.EndDateTime)" -ForegroundColor Green
        }
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
    }
}






