 Connect-AzAccount
 Set-AzContext -Subscription wolffentpsub
 
 $Policyjsontemplate = "C:\Users\jerrywolff\OneDrive - Microsoft\Documents\azure\json\propgatedefaultroutechangeprevent.json"
 
  $policyjson = Get-Content -Raw    $Policyjsontemplate 

  New-AzPolicyDefinition -Name policytopreventchangevnetpropogationofdefaultroutes -DisplayName 'policytopreventchangevnetpropogationofdefaultroutes' -Policy $Policyjsontemplate   -Verbose

  Get-AzPolicyDefinition -Name policytopreventchangevnetpropogationofdefaultroutes | `

  Set-AzPolicyDefinition   -SubscriptionId $subscriptioninfo.Id

