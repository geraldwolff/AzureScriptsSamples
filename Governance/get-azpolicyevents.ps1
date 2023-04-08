
 import-module  Az.OperationalInsights -force

 import-module Az.PolicyInsights -Force 

 ############
 ## connect to Azure with authorized credentials 
 
 Connect-AzAccount


#########################################
##  uncomment this line if anomalies in queries display deprecation messages - This will allow script to continue discovery

##$ErrorActionPreference = 'silentlyContinue'

### get the list of subscriptions accessible by the credentials provided   

#########################################
### Clear Array collector 
## This is used to collect data using the custom schema in $resultobj
   $policystateresults = ''

#########################################

##  Get ist of subscriptions that will be read for discovery 
 
 $Subs =  Get-azSubscription | select Name, ID,TenantId


 foreach($Subscription in  $subs)
    {

            ## Progress counter 

                        $i = 0
              

                             $a = $a+1

                    # Determine the completion percentage
                    $SubCompleted = ($a/$subs.count) * 100
                    $Subactivity = "Subscriptions - Processing Iteration " + ($a + 1);
         
                         Write-Progress -Activity " $Subactivity " -Status "Progress:" -PercentComplete $SubCompleted

                    ###### end progrss counter for subscriptions

                             $SubscriptionName =  $Subscription.name

                             
                           $azcontext = (set-azcontext -SubscriptionName $SubscriptionName  -ErrorAction SilentlyContinue)

                       write-host "$SubscriptionName" -foregroundcolor yellow



  
               $policyStates =  Get-AzPolicyState   -All
          
  

          foreach($policystate in $policystates) 
          {
                #Get-AzPolicySetDefinition -SubscriptionId 


                 #$policydefdata = Get-AzPolicyDefinition -Name $($policystate.PolicyDefinitionName)  -ErrorAction SilentlyContinue

                ################### counter for policy States
            $policyevents =   Get-AzPolicyEvent -PolicyDefinitionName $($policystate.PolicyDefinitionName) -ErrorAction SilentlyContinue

                            $i = $i+1
                                    # Determine the completion percentage
                                    $Completed = ($i/$policystates.count) * 100
                                    $activity = "policystates- Processing Iteration " + ($i + 1);
         
                                 Write-Progress -Activity " $activity " -Status "Progress:" -PercentComplete $Completed  


                #################### end progress counter for policy states 

                }

}




