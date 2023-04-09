# Connect to Azure
Connect-AzAccount #-Environment AzureUSGovernment

        # Define the Azure subscription and resource group
 
         $subscriptions = get-azsubscription 
         $initiativeassignedlist = ''

         foreach($subscription in $subscriptions) 
         {
                set-azcontext -Subscription $($subscription.name) -force

        # Get all the initiatives in the subscription
        $initiatives = Get-AzPolicySetDefinition -SubscriptionId $subscription.Id | select-object -ExpandProperty Properties  

        # Loop through each initiative



            # Get the compliance states for all resources assigned to the initiative

 

      #$compliancestates =  Get-AzPolicyState -All | SELECT -UNIQUE # -ErrorAction SilentlyContinue
           $compliancestates =    Get-AzPolicyState  -all # | select-object -ExpandProperty properties 
  
   
        $a = 0 
 
         Foreach($Compliance in $compliancestates)
         {
              
                         $a = $a+1

                    # Determine the completion percentage
                    $ResourcesCompleted = ($a/$compliancestates.count) * 100
                    $Resourceactivity = "Complianceobjects  - Processing Iteration " + ($a + 1);
              
                
                foreach($initiative in $initiatives)
                {
                
                
                 write-host "$($initiative.policydefinitionid) " -ForegroundColor Green

                    write-host " $($Compliance.PolicySetDefinitionId)" -ForegroundColor Magenta

         
                        $initiativepd = $($initiatve.DisplayName)
                        #$initiative
                                $initiativepd                                                                                                                                                                                                                                                                                                                                                                                                                  
                         $initiativeset = $($initiative.PolicyDefinitions.policyDefinitionId)
               # $initiativeset

                $compliance  |  where  policysetdefinitionid -eq   $($initiative.policydefinitionid) | select -first 1 
          

            # Print the results
            Write-Host "Initiative: $($initiative.DisplayName)"
            Write-Host "  $($compliance.PolicyAssignmentId) " -ForegroundColor Cyan
            Write-Host "-------------------------"
          
                $initiativeobj = New-OBject PSObject 

                 $initiativeobj | Add-Member -MemberType NoteProperty -Name Initiative -value  $($initiative.DisplayName)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name AdditionalProperties -value  $($compliance.AdditionalProperties)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name Timestamp -value  $($compliance.Timestamp)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name ResourceId -value  $($compliance.ResourceId)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicyAssignmentId -value  $($compliance.PolicyAssignmentId)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicyDefinitionId -value  $($compliance.PolicyDefinitionId)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name EffectiveParameters -value  $($compliance.EffectiveParameters)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name IsCompliant -value  $($compliance.IsCompliant)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name SubscriptionId -value  $($compliance.SubscriptionId)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name ResourceType -value  $($compliance.ResourceType)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name ResourceLocation -value  $($compliance.ResourceLocation)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name ResourceGroup -value  $($compliance.ResourceGroup)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name ResourceTags -value  $($compliance.ResourceTags)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicyAssignmentName -value  $($compliance.PolicyAssignmentName)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicyAssignmentOwner -value  $($compliance.PolicyAssignmentOwner)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicyAssignmentParameters -value  $($compliance.PolicyAssignmentParameters)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicyAssignmentScope -value  $($compliance.PolicyAssignmentScope)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicyDefinitionName -value  $($compliance.PolicyDefinitionName)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicyDefinitionAction -value  $($compliance.PolicyDefinitionAction)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicyDefinitionCategory -value  $($compliance.PolicyDefinitionCategory)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicySetDefinitionId -value  $($compliance.PolicySetDefinitionId)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicySetDefinitionName -value  $($compliance.PolicySetDefinitionName)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicySetDefinitionOwner -value  $($compliance.PolicySetDefinitionOwner)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicySetDefinitionCategory -value  $($compliance.PolicySetDefinitionCategory)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicySetDefinitionParameters -value  $($compliance.PolicySetDefinitionParameters)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name ManagementGroupIds -value  $($compliance.ManagementGroupIds)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicyDefinitionReferenceId -value  $($compliance.PolicyDefinitionReferenceId)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name ComplianceState -value  $($compliance.ComplianceState)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicyEvaluationDetails -value  $($compliance.PolicyEvaluationDetails)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicyDefinitionGroupNames -value  $($compliance.PolicyDefinitionGroupNames)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicyDefinitionVersion -value  $($compliance.PolicyDefinitionVersion)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicySetDefinitionVersion -value  $($compliance.PolicySetDefinitionVersion)
                 $initiativeobj | Add-Member -MemberType NoteProperty -Name PolicyAssignmentVersion -value  $($compliance.PolicyAssignmentVersion)

                 $initiativeobj
            [array]$initiativeassignedlist += $initiativeobj
        }
 
            
          
           
     }

     

}




 $resultsfilename1 = "PolicyInitiaveCompliance.csv"



$initiativeassignedlist | select Initiative,  AdditionalProperties, `
Timestamp, `
ResourceId, `
PolicyAssignmentId, `
PolicyDefinitionId, `
EffectiveParameters, `
IsCompliant, `
SubscriptionId, `
ResourceType, `
ResourceLocation, `
ResourceGroup, `
ResourceTags, `
PolicyAssignmentName, `
PolicyAssignmentOwner, `
PolicyAssignmentParameters, `
PolicyAssignmentScope, `
PolicyDefinitionName, `
PolicyDefinitionAction, `
PolicyDefinitionCategory, `
PolicySetDefinitionId, `
PolicySetDefinitionName, `
PolicySetDefinitionOwner, `
PolicySetDefinitionCategory, `
PolicySetDefinitionParameters, `
ManagementGroupIds, `
PolicyDefinitionReferenceId, `
ComplianceState, `
PolicyEvaluationDetails, `
PolicyDefinitionGroupNames, `
PolicyDefinitionVersion, `
PolicySetDefinitionVersion, `
PolicyAssignmentVersion | export-csv $resultsfilename1  -NoTypeInformation   



 
 
 
# end vmss data 


##### storage subinfo

$Region =  "<Location>"

 $subscriptionselected = '<subscriptionname>'



$resourcegroupname = '<Resourcegroupname>'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = '<Storageaccountname>'
$storagecontainer = 'policyinitivescompliance2'


### end storagesub info

set-azcontext -Subscription $($subscriptioninfo.Name)  -Tenant $($TenantID.TenantId)

 

#BEGIN Create Storage Accounts
 
 
 
 try
 {
     if (!(Get-AzStorageAccount -ResourceGroupName $resourcegroupname -Name $storageaccountname ))
    {  
        Write-Host "Storage Account Does Not Exist, Creating Storage Account: $storageAccount Now"

        # b. Provision storage account
        New-AzStorageAccount -ResourceGroupName $resourcegroupname  -Name $storageaccountname -Location $region -AccessTier Hot -SkuName Standard_LRS -Kind BlobStorage -Tag @{"owner" = "Jerry wolff"; "purpose" = "Az Automation storage write" } -Verbose
 
     
        Get-AzStorageAccount -Name   $storageaccountname  -ResourceGroupName  $resourcegroupname  -verbose
     }
   }
   Catch
   {
         WRITE-DEBUG "Storage Account Aleady Exists, SKipping Creation of $storageAccount"
   
   } 
        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  –StorageAccountName $storageaccountname).value | select -first 1
        $destContext = New-azStorageContext  –StorageAccountName $storageaccountname `
                                        -StorageAccountKey $StorageKey


             #Upload user.csv to storage account

        try
            {
                  if (!(get-azstoragecontainer -Name $storagecontainer -Context $destContext))
                     { 
                         New-azStorageContainer $storagecontainer -Context $destContext
                        }
             }
        catch
             {
                Write-Warning " $storagecontainer container already exists" 
             }
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename1  -File $resultsfilename1 -Context $destContext -Force

















