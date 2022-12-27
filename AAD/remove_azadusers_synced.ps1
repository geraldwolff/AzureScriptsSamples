#### Remove "#" to allow to connect to Azure US Government Tenants
  Connect-AzAccount #-EnvironmentName AzureUSGovernment


Get-AzSubscription -SubscriptionId <subscriptionID>
Set-AzContext -Tenant  <tenantname>

Get-AzSubscription
#Get-AzResource | fl *
Get-azaduser | where-object {$_.UserPrincipalName -notlike '*xxxxx*' -and $_.UserPrincipalName -notlike '*onmicrosoft.com*'}  | Remove-AzADUser -verbose -force

