connect-azaccount 

import-module az.storage

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

########## get Policy template 



$Policyjsontemplate = "asntaggingdefinition.json"

$jsonblob = get-AzStorageBlob -Blob $Policyjsontemplate -Container $templatecontainer -Context $destContext


#[array]$policytemplatejsoncontent = Get-AzStorageBlobContent -Blob $Policyjsontemplate -Container $templatecontainer -Destination  $Policyjsontemplate  -Context $destContext
 [array]$policytemplatejsoncontent = Get-AzStorageBlobContent -Blob $Policyjsontemplate -Container $templatecontainer    -Context $destContext


Get-Content -Raw  -Path $($policytemplatejsoncontent.name)


###### get parameters



$Policyjsonfile = "asntaggingdefinition.parameters.json"

$jsonblob = get-AzStorageBlob -Blob $Policyjsonfile -Container $templatecontainer -Context $destContext


#[array]$policyjsoncontent = Get-AzStorageBlobContent -Blob $Policyjsonfile -Container $templatecontainer -Destination  $Policyjsonfile  -Context $destContext
[array]$policyjsoncontent = Get-AzStorageBlobContent -Blob $Policyjsonfile -Container $templatecontainer   -Context $destContext
 

#Read local file and get JSON object
 

 $jsonContent = Get-Content -Raw  -Path  $($policyjsoncontent.name) 
  
 
#Convert JSON file to an object  
$JsonParameters = ConvertFrom-Json -InputObject $jsonContent

  $i = 0

  do {
        $i = $i+1
    $JsonParameters.listofallowedtagValues.allowedValues += "ASN98$i"


    }until($i -ge 10000)
 
 $updatedpolicy = "updatedpolicy.json"

$updated_policy = $JsonParameters | ConvertTo-Json -Depth 10  | out-file   $updatedpolicy   

  
  Get-Content -Raw   $updatedpolicy
 




  Set-azStorageBlobContent -Container $storagecontainer -Blob $updatedpolicy  -File $updatedpolicy  -Context $destContext


  New-AzPolicyDefinition -Name asntaggingdefinition -DisplayName 'asntaggingdefinition' -Policy $Policyjsontemplate -Parameter $updatedpolicy -Verbose

  Get-AzPolicyDefinition -Name asntaggingdefinition | `

  Set-AzPolicyDefinition   -SubscriptionId $subscriptioninfo.Id



