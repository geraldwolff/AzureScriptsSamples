Connect-AzAccount   
 $ErrorActionPreference = 'Continue'

 
 foreach($sub in Get-AzSubscription)
 {
    
    $tenant = Get-AzTenant -TenantId $($sub.TenantId)
    Get-AzContext -ListAvailable
    write-host "subscription : $($sub.Name) - $($sub.TenantId)" -ForegroundColor Cyan
    write-host "Tenant : $($tenant.Name) - Domains $($tenant.Domains)" -ForegroundColor  Green
    }