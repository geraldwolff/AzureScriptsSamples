connect-azaccount 

import-module az.storage
import-module Az.Resources 


$subscriptionselected = 'Azure Subscription 1'



################  Set up storage account ################


$resourcegroupname = 'jwautomationrg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = 'asnstoragesa'
$storagecontainer = 'policyupdates'
$templatecontainer = 'templatesscntr'

$region = 'westus'

### end storagesub info

Set-azcontext -Subscription $($subscriptioninfo.Name) -Tenant $subscriptioninfo.TenantId

 ####resourcegroup 
 try
 {
     if (!(Get-azresourcegroup -Location 'westus'  -erroraction "continue" ) )
    {  
        Write-Host "resourcegroup Does Not Exist, Creating resourcegroup  : $resourcegroupname Now"

        # b. Provision resourcegroup
        New-azresourcegroup -Name  $resourcegroupname -Location $region -Tag @{"owner" = "Jerry wolff"; "purpose" = "Az Automation" } -Verbose -Force
 
     
        Get-azresourcegroup    -ResourceGroupName  $resourcegroupname  -verbose
     }
   }
   Catch
   {
         WRITE-DEBUG "Resourcegroup   Aleady Exists, SKipping Creation of resourcegroupname"
   
   }

    
 try
 {
     if (!(Get-AzStorageAccount -ResourceGroupName $resourcegroupname -Name $storageaccountname  -erroraction "continue" ) )
    {  
        Write-Host "Storage Account Does Not Exist, Creating Storage Account: $storageAccount Now"

        # b. Provision storage account
        New-AzStorageAccount  -ResourceGroupName $resourcegroupname  -Name $storageaccountname -Location $region -AccessTier Hot -SkuName Standard_LRS -Kind BlobStorage -Tag @{"owner" = "Jerry wolff"; "purpose" = "Az Automation storage write" } -Verbose 
 
        start-sleep 30

        Get-AzStorageAccount -Name   $storageaccountname  -ResourceGroupName  $resourcegroupname  -verbose
     }
   }
   Catch
   {
         WRITE-DEBUG "Storage Account Aleady Exists, SKipping Creation of $storageAccount"
   
   } 
 
             #Upload user.json to storage account

        try
            {
                  if (!(get-azstoragecontainer -Name $storagecontainer -Context $destContext))
                     { 
                         New-azStorageContainer $storagecontainer -Context $destContext

                         
                        start-sleep 30

                        }
             }
        catch
             {
                Write-Warning " $storagecontainer container already exists" 
             }
       

    #############################################################

     


set-azcontext -Subscription $($subscriptioninfo.Name)  -Tenant $($TenantID.TenantId)



$StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  –StorageAccountName $storageaccountname).value | select -first 1
$destContext = New-azStorageContext  –StorageAccountName $storageaccountname `
                 -StorageAccountKey $StorageKey

########## Get Policy template 



$Policyjsontemplate = "asntaggingdefinition.json"

$jsondefinitionblob = get-AzStorageBlob -Blob $Policyjsontemplate -Container $templatecontainer -Context $destContext

 
 [array]$policytemplatejsoncontent = Get-AzStorageBlobContent -Blob $Policyjsontemplate -Container $templatecontainer    -Context $destContext -Force


$policydefinition = get-Content -Raw  $($policytemplatejsoncontent.name)
$policydefinition



###### get parameters



$Policyjsonparamsfile = "asntaggingdefinition.parameters.json"

$jsonparamsblob = get-AzStorageBlob -Blob $Policyjsonparamsfile -Container $templatecontainer -Context $destContext 

 
[array]$policyjsonparamscontent = Get-AzStorageBlobContent -Blob $Policyjsonparamsfile -Container $templatecontainer   -Context $destContext -Force

 $policyparameters = get-Content -raw $($policyjsonparamscontent.name)
$policyparameters



 ###### Get asn codes files from storage container csv file

 $sourcecontainer = 'sourceasn'
 $asnsourceblob = '<Servicetags.csv>'

 $asncodescontainer =  get-AzStorageBlob -Blob $asnsourceblob -Container $sourcecontainer -Context $destContext 
 
 $asvcodesfilecontent = Get-AzStorageBlobContent -Blob $asnsourceblob -Container $sourcecontainer   -Context $destContext -force

 $asncodes = import-csv  $asvcodesfilecontent.Name


#Read local file and get JSON object
  
  
 #######  Set value updates 


        #Convert JSON file to an object  
        $JsonParameters = ConvertFrom-Json -InputObject $policyparameters

         foreach($asncode in $asncodes)
         {

            $JsonParameters.listofallowedtagValues.allowedValues += "$($asncode.'Application Service Number')"

         } 
 

    ############  Create blob file for archive and audit

         $updatedpolicy = "updatedpolicy.json"
         $JsonParameters | ConvertTo-Json -Depth 10  | out-file  $updatedpolicy

    ################################## Add raw content to Variable

        $updated_policy = $JsonParameters | ConvertTo-Json -Depth 10   

  
          #Get-Content -Raw   $updatedpolicy
    ##################  Write updated parameters file to Storage account 

          Set-azStorageBlobContent -Container $storagecontainer -Blob $updatedpolicy  -File $updatedpolicy  -Context $destContext -Force


    ############## Apply updates to Policy parameters and reapply to Definition

          New-AzPolicyDefinition -Name asntaggingdefinition -DisplayName 'asntaggingdefinition' -Policy $policydefinition -Parameter $($updated_policy) -Verbose

       $policytoassign = Get-AzPolicyDefinition -Name asntaggingdefinition 

       
        
          Get-AzPolicyDefinition -Name asntaggingdefinition -SubscriptionId $subscriptioninfo.Id  | `

         Set-AzPolicyDefinition      -Parameter $($updated_policy) -DisplayName asntaggingdefinition -name asntaggingdefinition


  ############## Test/ Validation Policy and values 


  $policydefinitionproperties = Get-AzPolicyDefinition -Name asntaggingdefinition -SubscriptionId $subscriptioninfo.Id | select-object -ExpandProperty properties
   
  $policydefinitionproperties

   
  write-host "$($policydefinitionproperties.parameters.tagName.metadata.description) " -ForegroundColor Green
  write-host "$($policydefinitionproperties.parameters.tagName.metadata.displayName) " -ForegroundColor Green


 $($policydefinitionproperties.parameters).listofallowedtagValues.allowedValues




#####################################  Reassign subscription to update policy
######### Remove old assignment on resource
 
$PolicyAssignment = Get-AzPolicyAssignment  -PolicyDefinitionId $policytoassign.PolicyDefinitionId
Remove-AzPolicyAssignment -Id $PolicyAssignment.ResourceId  

 
 ##################  Reassign Policydefinition
 
 $listofallowedtagValues  = @{'tagName'='AppServiceName'; 'listofallowedtagValues'=$($JsonParameters.listofallowedtagValues.allowedValues) }

 $assigntoscope =   New-AzPolicyAssignment -Name 'asntaggingdefinitionasg' -PolicyDefinition  $policytoassign  -PolicyParameterObject  $listofallowedtagValues  -Scope  "/subscriptions/$($subscriptioninfo.Id)" -NonComplianceMessage @{Message="Stop making mistakes - I will find you"}
        
 



