Connect-AzAccount 

$subscriptions = get-azsubscription 

$subscription = $subscriptions | ogv -Title " Please select a subscription" -passthru | Select name, ID 

set-azcontext -Subscription $($subscription.name) 


$providers = Get-AzResourceProvider 


$providerlist = $providers |  select providernamespace , RegistrationState | ogv -Title 'Please slect all providers to register' -PassThru | Select providernamespace 


foreach($Provider in $providerlist)
{
 


   Register-AzResourceProvider    -ProviderNamespace $($Provider.providernamespace)  -verbose 

 Get-AzResourceProvider -ProviderNamespace $($Provider.providernamespace) |  select providernamespace, Registrationstate, resourcetypes


} 




