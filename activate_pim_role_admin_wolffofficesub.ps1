import-module -name Az.Resources   -force 

# Connect to Azure
Connect-AzAccount


$subscription = get-azsubscription -SubscriptionName wolffofficesub
 
 
$scope = "/subscriptions/$($subscription.id)/"
 
$guid = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"

$startTime = Get-Date -Format o
 
 $appowner = get-azaduser | where mail -eq 'admin@wpi-corp.com'


Get-AzRoleAssignment -ResourceGroupName testRG -SignInName $($appowner.UserPrincipalName)


$newroleazzignment = New-AzRoleEligibilityScheduleRequest -Name $guid `
-Scope $scope `
-ExpirationDuration PT1441H `
-ExpirationType AfterDuration `
-PrincipalId $($appowner.id) `
-RequestType AdminAssign `
-RoleDefinitionId "subscriptions/$($subscription.id)/providers/Microsoft.Authorization/roleDefinitions/$guid" `
-ScheduleInfoStartDateTime $startTime


$global:roles = @()
 
 
    $global:roles = Get-AzRoleEligibilityScheduleRequest   `
    -scope "/subscriptions/$($subscription.id)/"
    Write-Host "Eligible roles collected"
 
 
# $roleassignment = Get-AzRoleAssignment | Where-Object {$_.id -eq $($appowner.id) -and $($_RoleDefinitionDisplayName) -eq 'Reader'}
#Remove-AzRoleAssignment -InputObject $roleassignment


$justification = " because I said so "

[int]$DurationHours = 1444
[string]$Duration = "PT${DurationHours}H"
[switch]$ValidateActivation

$rolesToActivate = $global:roles | Where-Object { $_.principalid -eq $($appowner.id) }

foreach ($role in $rolesToActivate) {
    $activationParams = @{
        "Name"                   = (New-Guid).Guid
        "RoleDefinitionId"       = $role.RoleDefinitionId
        "PrincipalId"            = $role.PrincipalId
        "Scope"                  = $Scope
        "Justification"          = $justification
        "ExpirationDuration"     = $Duration
        "ExpirationType"         = "AfterDuration"
        "RequestType"            = "SelfActivate"
        "ScheduleInfoStartDateTime" = (Get-Date).ToUniversalTime()
    }

    $activation = New-AzRoleAssignmentScheduleRequest @activationParams

    if ($ValidateActivation) {
        Write-Host "Activated role for $($role.PrincipalId) with justification: $($role.Justification)"
    }
}



Get-AzRoleAssignment -Scope $Scope -PrincipalId $role.PrincipalId
 
 
 
