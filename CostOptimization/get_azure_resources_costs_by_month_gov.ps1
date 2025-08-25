Connect-AzAccount -Environment AzureUSGovernment 



$startdate = '01-01-2023'
$endDate = '08-10-2023'
$resources = ''
$ResourceGroups = Get-AzResourceGroup 
foreach($Resourcegroup in  $ResourceGroups)
{ 
[array]$resources += Get-AzConsumptionUsageDetail -ResourceGroup $($resourcegroup.ResourceGroupName) -StartDate $startDate -EndDate $endDate

}


    
         
   $resources | select UsageStart,  UsageEnd, BillingPeriodName,InstanceName, UsageQuantity,BillableQuantity, PretaxCost, MeterId| Export-Csv C:\temp\azure_resource_costs.csv -NoTypeInformation 
 



