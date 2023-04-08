
 Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'

   

 connect-azaccount     #  -Environment AzureUSGovernment # -identity
  


####################  modules

import-module -Name az.billing -force -ErrorAction SilentlyContinue

import-module -Name az.advisor -force -ErrorAction SilentlyContinue
 import-module -name Az.Reservations -force  -ErrorAction SilentlyContinue


## Cleanup
 

 $recommendationresults = ''

 $Subscriptionconsumptionreport = ''

$subs = get-Azsubscription 

$startDate = (Get-Date).AddDays(-90)
$endDate = Get-Date
 


foreach($sub in $subs)
{
    $subname = $sub.Name

         Set-Azcontext -Subscription $subname   

 
$advisorRecommendations = Get-AzAdvisorRecommendation -SubscriptionId $sub.Id 
#$advisorRecommendations #   | Export-Csv -Path C:\Recommendations.csv


    foreach($recommendation in $advisorRecommendations)
    {
    
     

    $recommendationamount =Get-AzAdvisorRecommendation -resourceid $($recommendation.Id) | Select-Object -ExpandProperty ExtendedProperty | select *
    
    $($recommendationamount.Properties.CostSavings).amount



        $recommendationobj = new-object PSobject 

        $resourcename = $($recommendation.ResourceMetadataResourceId).Split('/')[-1]


   
                 $extendedProperties = $recommendation.ExtendedProperty | select *
 
                #Write-Host "Keys for recommendation $($recommendation.Id):"
<#
                foreach ($key in $extendedProperties) {



                        $keymetadata = $($key.keys) -split(' ') 
                        $valuedata = $($key.values) -split(' ') 
                        $($keymetadata).count 
#>
             if( $($extendedProperties.AdditionalProperties.Keys) -like '*Savings*')
                    {
                         $extendedProperties.AdditionalProperties.GetEnumerator() | foreach-object  {

                         $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  $($_.key)  -Value  $($_.value)


                            Write-Host "  $($_.key)    $($_.value) "
                        }
                    }
               
  

 ################


            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  Action  -Value  $($RECOMMENDATION.Action)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  Category  -Value  $($RECOMMENDATION.Category)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  Description  -Value  $($RECOMMENDATION.Description)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  ExposedMetadataProperty  -Value  $($RECOMMENDATION.ExposedMetadataProperty)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  ExtendedProperty  -Value  $($RECOMMENDATION.ExtendedProperty)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  Id  -Value  $($RECOMMENDATION.Id)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  Impact  -Value  $($RECOMMENDATION.Impact)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  ImpactedField  -Value  $($RECOMMENDATION.ImpactedField)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  ImpactedValue  -Value  $($RECOMMENDATION.ImpactedValue)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  Label  -Value  $($RECOMMENDATION.Label)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  LastUpdated  -Value  $($RECOMMENDATION.LastUpdated)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  LearnMoreLink  -Value  $($RECOMMENDATION.LearnMoreLink)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  Metadata  -Value  $($RECOMMENDATION.Metadata)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  Name  -Value  $($RECOMMENDATION.Name)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  PotentialBenefit  -Value  $($RECOMMENDATION.PotentialBenefit)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  RecommendationTypeId  -Value  $($RECOMMENDATION.RecommendationTypeId)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  Remediation  -Value  $($RECOMMENDATION.Remediation)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  ResourceGroupName  -Value  $($RECOMMENDATION.ResourceGroupName)

            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  resourcename  -Value  $resourcename

            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  ResourceMetadataAction  -Value  $($RECOMMENDATION.ResourceMetadataAction)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  ResourceMetadataPlural  -Value  $($RECOMMENDATION.ResourceMetadataPlural)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  ResourceMetadataResourceId  -Value  $($RECOMMENDATION.ResourceMetadataResourceId)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  ResourceMetadataSingular  -Value  $($RECOMMENDATION.ResourceMetadataSingular)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  ResourceMetadataSource  -Value  $($RECOMMENDATION.ResourceMetadataSource)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  Risk  -Value  $($RECOMMENDATION.Risk)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  ShortDescriptionProblem  -Value  $($RECOMMENDATION.ShortDescriptionProblem)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  ShortDescriptionSolution  -Value  $($RECOMMENDATION.ShortDescriptionSolution)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  SuppressionId  -Value  $($RECOMMENDATION.SuppressionId)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  Type  -Value  $($RECOMMENDATION.Type)
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  UsageQuantity  -Value  $newusage
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  Originalcost  -Value  [decimal]$originalcost
            $RECOMMENDATIONobj  | add-member -MemberType NoteProperty -Name  Newcost  -Value  [decimal]$Newcost

            [ARRAY]$recommendationresults += $recommendationobj
         
 

    }


     

            $Subscriptionconsumptiondetails = Get-AzConsumptionUsageDetail -Expand MeterDetails -erroraction "silentlycontinue"

            foreach($Subscriptionconsumptiondetail in $Subscriptionconsumptiondetails)
            {

            $usageconsumptionobj = new-object PSObject 



                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  AccountName  -Value  $($Subscriptionconsumptiondetail.AccountName)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  AdditionalInfo  -Value  $($Subscriptionconsumptiondetail.AdditionalInfo)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  AdditionalProperties  -Value  $($Subscriptionconsumptiondetail.AdditionalProperties)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  BillableQuantity  -Value  $($Subscriptionconsumptiondetail.BillableQuantity)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  BillingPeriodId  -Value  $($Subscriptionconsumptiondetail.BillingPeriodId)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  BillingPeriodName  -Value  $($Subscriptionconsumptiondetail.BillingPeriodName)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  ConsumedService  -Value  $($Subscriptionconsumptiondetail.ConsumedService)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  CostCenter  -Value  $($Subscriptionconsumptiondetail.CostCenter)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  Currency  -Value  $($Subscriptionconsumptiondetail.Currency)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  DepartmentName  -Value  $($Subscriptionconsumptiondetail.DepartmentName)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  Id  -Value  $($Subscriptionconsumptiondetail.Id)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  InstanceId  -Value  $($Subscriptionconsumptiondetail.InstanceId)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  InstanceLocation  -Value  $($Subscriptionconsumptiondetail.InstanceLocation)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  InstanceName  -Value  $($Subscriptionconsumptiondetail.InstanceName)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  InvoiceId  -Value  $($Subscriptionconsumptiondetail.InvoiceId)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  InvoiceName  -Value  $($Subscriptionconsumptiondetail.InvoiceName)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  IsEstimated  -Value  $($Subscriptionconsumptiondetail.IsEstimated)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  MeterDetails  -Value  $($Subscriptionconsumptiondetail.MeterDetails)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  MeterId  -Value  $($Subscriptionconsumptiondetail.MeterId)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  Name  -Value  $($Subscriptionconsumptiondetail.Name)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  PretaxCost  -Value  $($Subscriptionconsumptiondetail.PretaxCost)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  Product  -Value  $($Subscriptionconsumptiondetail.Product)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  SubscriptionGuid  -Value  $($Subscriptionconsumptiondetail.SubscriptionGuid)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  SubscriptionName  -Value  $($Subscriptionconsumptiondetail.SubscriptionName)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  Tags  -Value  $($Subscriptionconsumptiondetail.Tags)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  Type  -Value  $($Subscriptionconsumptiondetail.Type)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  UsageEnd  -Value  $($Subscriptionconsumptiondetail.UsageEnd)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  UsageQuantity  -Value  $($Subscriptionconsumptiondetail.UsageQuantity)
                $usageconsumptionobj  | add-member -MemberType NoteProperty -Name  UsageStart  -Value  $($Subscriptionconsumptiondetail.UsageStart)


            [array]$Subscriptionconsumptionreport += $usageconsumptionobj
            }


}



$resultsfilename = 'advisiordata.csv'
$resultsfilename1 = 'subscriptionusageconsumptiondetails.csv'

##########################################




 $recommendationresults |  Select  Action,`
Category,`
Description,`
ExposedMetadataProperty,`
ExtendedProperty,`
Id,`
Impact,`
ImpactedField,`
ImpactedValue,`
Label,`
LastUpdated,`
LearnMoreLink,`
Metadata,`
Name,`
PotentialBenefit,`
RecommendationTypeId,`
Remediation,`
ResourceGroupName,`
Resourcename,`
ResourceMetadataAction,`
ResourceMetadataPlural,`
ResourceMetadataResourceId,`
ResourceMetadataSingular,`
ResourceMetadataSource,`
Risk,`
ShortDescriptionProblem,`
ShortDescriptionSolution,`
SuppressionId,`
Type,`
UsageQuantity,`
 MaxCpuP95, `
 MaxTotalNetworkP95, `
 MaxMemoryP95, `
savingsAmount, `
annualSavingsAmount, `
savingsCurrency, `
deploymentId, `
roleName, `
currentSku, `
targetSku, `
recommendationMessage, `
recommendationType, `
regionId, `
subscriptionId, `
Duration `
| export-csv $resultsfilename -notypeinformation 


###################################################

$Subscriptionconsumptionreport | Select AccountName,`
AdditionalInfo,`
AdditionalProperties,`
BillableQuantity,`
BillingPeriodId,`
BillingPeriodName,`
ConsumedService,`
CostCenter,`
Currency,`
DepartmentName,`
Id,`
InstanceId,`
InstanceLocation,`
InstanceName,`
InvoiceId,`
InvoiceName,`
IsEstimated,`
MeterDetails,`
MeterId,`
Name,`
PretaxCost,`
Product,`
SubscriptionGuid,`
SubscriptionName,`
Tags,`
Type,`
UsageEnd,`
UsageQuantity,`
UsageStart | export-csv $resultsfilename1 -NoTypeInformation 









<# Get the savings plan information
$savingsPlans = Get-AzConsumptionUsageDetail -InstanceName  "SavingsPlan"

# Display the savings plan information
$savingsPlans | Format-Table -AutoSize

 $savingsplans | gm 

 #>

 ##### storage subinfo

$Region =  "West US"

 $subscriptionselected = 'HPC GBB Americas'



$resourcegroupname = 'wolffautorg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = 'wolffgovernancesa'
$storagecontainer = 'advisorrecommendations'


### end storagesub info

set-azcontext -Subscription $($subscriptioninfo.Name)  -Tenant $($TenantID.TenantId)

 

#BEGIN Create Storage Accounts
 
 
 
 try
 {
     if (!(Get-AzStorageAccount -ResourceGroupName $resourcegroupname -Name $storageaccountname ))
    {  
        Write-Host "Storage Account Does Not Exist, Creating Storage Account: $storageAccount Now"

        # b. Provision storage account
        New-AzStorageAccount -ResourceGroupName $resourcegroupname  -Name $storageaccountname -Location $region -AccessTier Hot -SkuName Standard_LRS -Kind BlobStorage -Tag @{"owner" = "Jerry wolff"; "purpose" = "Az Automation storage write" } -Verbose -ErrorAction SilentlyContinue
 
     
        Get-AzStorageAccount -Name   $storageaccountname  -ResourceGroupName  $resourcegroupname  -verbose
     }
   }
   Catch
   {
         WRITE-DEBUG "Storage Account Aleady Exists, SKipping Creation of $storageAccount"
   
   } 
        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  -StorageAccountName $storageaccountname).value | select -first 1
        $destContext = New-azStorageContext  -StorageAccountName $storageaccountname `
                                        -StorageAccountKey $StorageKey


             #Upload user.csv to storage account

        try
            {
                  if (!(get-azstoragecontainer -Name $storagecontainer -Context $destContext))
                     { 
                         New-azStorageContainer $storagecontainer -Context $destContext -ErrorAction SilentlyContinue
                        }
             }
        catch
             {
                Write-Warning " $storagecontainer container already exists" 
             }
       

          Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename  -File $resultsfilename -Context $destContext -force



################################################

$storageaccountname = 'wolffgovernancesa'
$storagecontainer = 'usagesonsumptiondetails'


### end storagesub info

set-azcontext -Subscription $($subscriptioninfo.Name)  -Tenant $($TenantID.TenantId)

 

#BEGIN Create Storage Accounts
 
 
 
 try
 {
     if (!(Get-AzStorageAccount -ResourceGroupName $resourcegroupname -Name $storageaccountname ))
    {  
        Write-Host "Storage Account Does Not Exist, Creating Storage Account: $storageAccount Now"

        # b. Provision storage account
        New-AzStorageAccount -ResourceGroupName $resourcegroupname  -Name $storageaccountname -Location $region -AccessTier Hot -SkuName Standard_LRS -Kind BlobStorage -Tag @{"owner" = "Jerry wolff"; "purpose" = "Az Automation storage write" } -Verbose -ErrorAction SilentlyContinue
 
     
        Get-AzStorageAccount -Name   $storageaccountname  -ResourceGroupName  $resourcegroupname  -verbose
     }
   }
   Catch
   {
         WRITE-DEBUG "Storage Account Aleady Exists, SKipping Creation of $storageAccount"
   
   } 
        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  -StorageAccountName $storageaccountname).value | select -first 1
        $destContext = New-azStorageContext  -StorageAccountName $storageaccountname `
                                        -StorageAccountKey $StorageKey


             #Upload user.csv to storage account

        try
            {
                  if (!(get-azstoragecontainer -Name $storagecontainer -Context $destContext))
                     { 
                         New-azStorageContainer $storagecontainer -Context $destContext -ErrorAction SilentlyContinue
                        }
             }
        catch
             {
                Write-Warning " $storagecontainer container already exists" 
             }
       






        
          Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename1  -File $resultsfilename1 -Context $destContext -force
      
     











