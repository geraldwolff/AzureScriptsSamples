 Connect-AzAccount
 $subscription = get-azsubscription -SubscriptionName WolffMSsub
 $customersub = get-azsubscription -SubscriptionName wpi-corp 


$PartnerTenantId = "$($subscription.TenantId)"
$CustomerTenantId = "$($customersub.TenantId)"
$PartnerSubscriptionId = "PartnerSubscriptionId"
$PartnerContext = Get-AzContext -ListAvailable  | where tenantid -EQ $subscription.TenantId
$CustomerContext = Get-AzContext   | where tenantid -EQ $customersub.TenantId
$PartnerExternalUserAssignments = Get-AzRoleAssignment -Scope "/providers/Microsoft.Management/managementGroups/$($PartnerContext.Account.Id)" -RoleDefinitionName "Lighthouse Provider Operations" -IncludeClassicAdministrators | Where-Object { $_.Properties.PrincipalId -ne $null }
$CustomerExternalUserAssignments = Get-AzRoleAssignment -Scope "/providers/Microsoft.Management/managementGroups/$($CustomerContext.Account.Id)" -RoleDefinitionName "Lighthouse Provider Operations" -IncludeClassicAdministrators | Where-Object { $_.Properties.PrincipalId -ne $null }
$CustomerExternalUserAssignments | ForEach-Object {
    $ExternalUser = Get-AzADUser -ObjectId $_.Properties.PrincipalId
    Write-Output "External User $($ExternalUser.UserPrincipalName) is assigned to $($CustomerContext.Account.Id)"
}




