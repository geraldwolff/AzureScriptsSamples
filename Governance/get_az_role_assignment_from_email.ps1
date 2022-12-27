Connect-AzAccount 
#####

$subs = get-Azsubscription 
foreach ($sub in $subs) 
{

set-Azcontext $($sub.name)
    $userEmail = '<emailAddress>' 
     $SubscriptionName = "$($sub.name)"
get-AzRoleAssignment    -Scope "/subscriptions/$($sub.ID)"   -RoleDefinitionName owner | where SignInName -match "$userEmail"

}

