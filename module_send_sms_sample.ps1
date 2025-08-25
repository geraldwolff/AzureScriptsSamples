import-module SendSms -force -verbose

connect-azaccount -identity

Get-ChildItem "C:\Program Files\WindowsPowerShell\Modules\SendSms"


  $SubscriptionName = "wolffentpsub" 
  $ResourceGroupName = "wolffcommsvcsrg" 
  $AcsResourceName = "wolffacs"


$subscription = get-azsubscription -subscriptionname $SubscriptionName
set-azcontext -Subscription $SubscriptionName



Send-SmsTo `
  -ToNumber "14253459653" `
  -Message "Hello from ACS!" `
  -Subscriptionid "$($subscription.id)" `
  -ResourceGroupName "$ResourceGroupName" `
  -AcsResourceName "$AcsResourceName"





