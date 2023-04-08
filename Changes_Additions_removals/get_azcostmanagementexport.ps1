 # install-module -name Az.CostManagement -allowclobber 
 cls
 Import-module Az.CostManagement  
 Import-module Az.Profile

 Install-Module -Name Az.Reservations
 Import-module -Name Az.Reservations

 # Connect to Azure
Connect-AzAccount #-Environment AzureUSGovernment

        # Define the Azure subscription and resource group
 
         $subscriptions = get-azsubscription 
         $initiativeassignedlist = ''

         foreach($subscription in $subscriptions) 
         {
                set-azcontext -Subscription $($subscription.name) -force

 Get-AzAdvisorRecommendation -Category Cost  | Where-Object {$_.ImpactedField -eq "Microsoft.Compute/virtualMachines"} | Select-Object -ExpandProperty ExtendedProperties





 Get-AzReservationOrderId
 #Get-AzConsumptionUsageDetail -StartDate 2021-10-02 -EndDate 2022-02-27  
  #Invoke-AzCostManagementQuery -Scope "subscriptions/$($subscription.id)"  -Timeframe MonthToDate -Type Usage -DatasetGranularity 'Daily'
 

            #    Get-AzCostManagementExport -Scope "subscriptions/$($subscription.id)"  
                
  #$getExport = Get-AzCostManagementExport -Name 'wolffExport' -Scope "subscriptions/$($subscription.id)" 
 #Invoke-AzCostManagementExecuteExport -InputObject $getExport 

}



<#
ETag              Name                               Type
----              ----                               ----
"************" TestExport                         Microsoft.CostManagement/exports
"************" TestExport1                        Microsoft.CostManagement/exports
"************" TestExport2                        Microsoft.CostManagement/exports

#>

 





 Get-AzAdvisorRecommendation -Category Cost | Where-Object {$_.ImpactedField -eq "Microsoft.Compute/virtualMachines"} | Select-Object -ExpandProperty ExtendedProperties




