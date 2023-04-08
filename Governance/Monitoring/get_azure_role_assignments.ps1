
cls
  
import-Module -Name Az  
 
 $date = get-date 
 

        #######################################################################################
 
 
 

        # Authenticate to Azure

                # Switch to Azure Resource Manager mode
                #switch-AzureMode -Name AzureResourceManager

               #  Select an Azure Subscription for which to report usage data
                $subscriptionId = 
                    (Get-AzureSubscription |
                     Out-GridView `
                        -Title "Select an Azure Subscription ..." `
                        -PassThru).SubscriptionId
               
   
                Select-AzureSubscription -SubscriptionId $subscriptionId


$ProgressPreference = 'Continue'

 Clear-Host
        $subs = Get-AzSubscription 
   
   $i = 0

            foreach($sub in $subs) 
            {

                $subscriptionName = $sub.name
          

                    Set-AzContext -subscription $subscriptionname 


              $rgs = Get-AzResourceGroup


              foreach ( $rg in $rgs) 
                {
 
                  $i = $i+1
                    # Determine the completion percentage
                    $Completed = ($i/$rgs.count) * 100
                    $activity = "Job 2 - Processing Iteration " + ($i + 1);
         
                 Write-Progress -Activity " $activity " -Status "Progress:" -PercentComplete $Completed

                 

            Get-AzRoleAssignment -ResourceGroupName  $($rg.ResourceGroupName)

            }


            
        }
 
