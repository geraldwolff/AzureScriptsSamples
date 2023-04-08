Connect-AzAccount #-Environment AzureUSGovernment


#Subscription Id.
$SubscriptionId = "<Subscriptionid>"
 
#Tenant Id.
$TenantId = "<tenantid>"
 
#Client Id. AAD  Registered App
$ClientId = "<AppClient id>"
 
#Client Secret. aka Client secret value 
$ClientSecret = "<App Client SecretValue>"


$Resource = "https://management.core.windows.net/ "
$RequestAccessTokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/token"
 
$body = "grant_type=client_credentials&client_id=$ClientId&client_secret=$ClientSecret&resource=$Resource"
 
# Get Access Token
$AccessToken = Invoke-RestMethod -Method Post -Uri $RequestAccessTokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'
 
# Get Azure Virtual Machines

 
# Format Header
$Headers = @{}
$Headers.Add("Authorization","$($AccessToken.token_type) "+ " " + "$($AccessToken.access_token)")



 ## Get az sku cost
 

# $vmAllcollectionsuri = "https://management.azure.com/subscriptions/$SubscriptionId/providers/Microsoft.Consumption/pricesheets/default?api-version=2021-10-01"

 $vmskupriceuri = "https://prices.azure.com/api/retail/prices?api-version=2021-10-01-preview"
 
 $vmcollectionsuri = "https://prices.azure.com/api/retail/prices?"
 
#######


$costlistreport = ''
$pricelistreport = ''
$alllistreport = ''
###########

#Invoke REST API



 #$vmallskucolletion = Invoke-RestMethod -Method Get -Uri $vmAllcollectionsuri -Headers $Headers


 $vmpricecolletion = Invoke-RestMethod -Method Get -Uri $vmskupriceuri -Headers $Headers
 $vmcostcolletion = Invoke-RestMethod -Method Get -Uri $vmcollectionsuri -Headers $Headers


 
 

 Write-Host "Virtual Machine Price Collection : " -ForegroundColor Green
$vmpricecolletion.Items | ForEach-Object {
 
 $Priceobj = new-object PSObject 

 $Priceobj | add-member -MemberType NoteProperty -name armSkuName     -value  $_.armSkuName  
 $Priceobj | add-member -MemberType NoteProperty -name productName     -value     $_.productName   
 $Priceobj | add-member -MemberType NoteProperty -name skuName     -value  $_.skuName  
 $Priceobj | add-member -MemberType NoteProperty -name serviceName     -value  $_.serviceName  
 $Priceobj | add-member -MemberType NoteProperty -name serviceId     -value   $_.serviceId     
 $Priceobj | add-member -MemberType NoteProperty -name serviceFamily     -value  $_.serviceFamily  
 $Priceobj | add-member -MemberType NoteProperty -name currencyCode     -value   $_.currencyCode  
 $Priceobj | add-member -MemberType NoteProperty -name retailPrice     -value  $_.retailPrice  
 $Priceobj | add-member -MemberType NoteProperty -name unitPrice     -value      $_.unitPrice  
 $Priceobj | add-member -MemberType NoteProperty -name armRegionName     -value  $_.armRegionName  
 $Priceobj | add-member -MemberType NoteProperty -name location     -value  $_.location  
  $Priceobj | add-member -MemberType NoteProperty -name effectiveStartDate     -value     $_.effectiveStartDate   
 $Priceobj | add-member -MemberType NoteProperty -name meterId     -value  $_.meterId  
 $Priceobj | add-member -MemberType NoteProperty -name meterName     -value  $_.meterName  
 $Priceobj | add-member -MemberType NoteProperty -name productId     -value    $_.productId    
 $Priceobj | add-member -MemberType NoteProperty -name skuId     -value  $_.skuId  
 $Priceobj | add-member -MemberType NoteProperty -name availabilityId     -value  $_.availabilityId  
 
  $Priceobj | add-member -MemberType NoteProperty -name unitOfMeasure     -value  $_.unitOfMeasure  
 $Priceobj | add-member -MemberType NoteProperty -name type     -value    $_.type    
 $Priceobj | add-member -MemberType NoteProperty -name isPrimaryMeterRegion     -value  $_.isPrimaryMeterRegion  
 $Priceobj | add-member -MemberType NoteProperty -name tierMinimumUnits     -value   $_.tierMinimumUnits  
  

 [array]$pricelistreport += $Priceobj 

}


 Write-Host "Virtual Machine Cost Collection : " -ForegroundColor Green
$vmcostcolletion.Items | ForEach-Object {
 
 $costobj = new-object PSObject 

 $costobj | add-member -MemberType NoteProperty -name armSkuName     -value  $_.armSkuName  
 $costobj | add-member -MemberType NoteProperty -name productName     -value     $_.productName   
 $costobj | add-member -MemberType NoteProperty -name skuName     -value  $_.skuName  
 $costobj | add-member -MemberType NoteProperty -name serviceName     -value  $_.serviceName  
 $costobj | add-member -MemberType NoteProperty -name serviceId     -value   $_.serviceId     
 $costobj | add-member -MemberType NoteProperty -name serviceFamily     -value  $_.serviceFamily  
 $costobj | add-member -MemberType NoteProperty -name currencyCode     -value   $_.currencyCode  
 $costobj | add-member -MemberType NoteProperty -name retailPrice     -value  $_.retailPrice  
 $costobj | add-member -MemberType NoteProperty -name unitPrice     -value      $_.unitPrice  
 $costobj | add-member -MemberType NoteProperty -name armRegionName     -value  $_.armRegionName  
 $costobj | add-member -MemberType NoteProperty -name location     -value  $_.location  
  $costobj | add-member -MemberType NoteProperty -name effectiveStartDate     -value     $_.effectiveStartDate   
 $costobj | add-member -MemberType NoteProperty -name meterId     -value  $_.meterId  
 $costobj | add-member -MemberType NoteProperty -name meterName     -value  $_.meterName  
 $costobj | add-member -MemberType NoteProperty -name productId     -value    $_.productId    
 $costobj | add-member -MemberType NoteProperty -name skuId     -value  $_.skuId  
 $costobj | add-member -MemberType NoteProperty -name availabilityId     -value  $_.availabilityId  
 
 $costobj | add-member -MemberType NoteProperty -name unitOfMeasure     -value  $_.unitOfMeasure  
 $costobj | add-member -MemberType NoteProperty -name type     -value    $_.type    
 $costobj | add-member -MemberType NoteProperty -name isPrimaryMeterRegion     -value  $_.isPrimaryMeterRegion  
 $costobj | add-member -MemberType NoteProperty -name tierMinimumUnits     -value   $_.tierMinimumUnits  
 

 [array]$costlistreport += $costobj 

}

 

 ##############################################  HTML 


$date = $(Get-Date -Format 'dd MMMM yyyy' )
 
    $CSS = @"
<Title> Azure Compute prices/costs : $date </Title>
<Style>
th {
	font: bold 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	color: #FFFFFF;
	border-right: 1px solid #FF45007;
	border-bottom: 1px solid #FF4500;
	border-top: 1px solid #FF4500;
	letter-spacing: 2px;
	text-transform: uppercase;
	text-align: left;
	padding: 6px 6px 6px 12px;
	background: #5F9EA0;
}
td {
	font: 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	border-right: 1px solid #FF4500;
	border-bottom: 1px solid #FF4500;
	background: #fff;
	padding: 6px 6px 6px 12px;
	color: #6D929B;
}
</Style>
"@


 

  ($pricelistreport  | Select armSkuName,  productName,  skuName, serviceName, serviceId,  serviceFamily, `
  currencyCode, retailPrice, unitPrice, armRegionName, location |Sort-Object location,SKUNAME   | `   
ConvertTo-Html -Head $CSS )  | out-file "c:\temp\Az_SComputeSkuprices.html" 

Invoke-Item "c:\temp\Az_SComputeSkuprices.html" 

  ($costlistreport  | Select armSkuName,  productName,  skuName, serviceName, serviceId,  serviceFamily, `
  currencyCode, retailPrice, unitPrice, armRegionName, location |Sort-Object location,SKUNAME | where location -like 'us *' | `   
ConvertTo-Html -Head $CSS )  | out-file "c:\temp\Az_SComputeSkucost.html" 

Invoke-Item "c:\temp\Az_SComputeSkucost.html" 

 
#############################################  CSV 

$resultsfile1 = "azomputeskuprices.csv"
$resultsfile2 = "uscostlistreport.csv"
$resultsfile3 = "azpricelistreport.csv"




 $pricelistreport  | Select armSkuName,  productName,  skuName, serviceName, serviceId,  serviceFamily, `
  currencyCode, retailPrice, unitPrice, armRegionName, location |Sort-Object location,SKUNAME   | export-csv "$resultsfile1" -NoTypeInformation

  $costlistreport  | Select armSkuName,  productName,  skuName, serviceName, serviceId,  serviceFamily, `
  currencyCode, retailPrice, unitPrice, armRegionName, location |Sort-Object location,SKUNAME | where location -like 'us *' | export-csv "$resultsfile2" -NoTypeInformation


$pricelistreport  | Select currencyCode,  tierMinimumUnits,  retailPrice, unitPrice, armRegionName,  location, `
  effectiveStartDate, meterId, meterName, productId, skuId, availabilityId, productName, skuName, `
  serviceName, serviceId, serviceFamily, unitOfMeasure, type,isPrimaryMeterRegion, armSkuName | export-csv "$resultsfile3" -NoTypeInformation
 

  ##### storage subinfo

$Region = "<location>"
#####  Subscription name if results storage accounts are in a separate subscription

### If results storage account is in a separate tenant 
#Connect-azaccount   # for storage account tenant and subscription context verification

 $subscriptionselected = '<results subscription>'



$resourcegroupname = '<resourcegroupname>'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = '<storaceaccountcontainer>'
 
### end storagesub info

set-azcontext -Subscription $($subscriptioninfo.Name)  -Tenant $($TenantID.TenantId)


#BEGIN Create Storage Accounts
 
 


 ####resourcegroup 
 try
 {
     if (!(Get-azresourcegroup -Location 'westus' -Name $resourcegroupname -erroraction "silentlycontinue" ) )
    {  
        Write-Host "resourcegroup Does Not Exist, Creating resourcegroup  : $resourcegroupname Now"

        # b. Provision resourcegroup
        New-azresourcegroup  -Name  $resourcegroupname -Location $region -Tag @{"owner" = "Jerry wolff"; "purpose" = "Az Automation" } -Verbose -Force
 
       start-sleep 30
        Get-azresourcegroup    -ResourceGroupName  $resourcegroupname  -verbose
     }
   }
   Catch
   {
         WRITE-DEBUG "Resourcegroup   Aleady Exists, SKipping Creation of resourcegroupname"
   
   }



 
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


####################


$storagecontainer = 'azomputeskuprices'

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
       
        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  –StorageAccountName $storageaccountname).value | select -first 1
        $destContext = New-azStorageContext  –StorageAccountName $storageaccountname `
                                        -StorageAccountKey $StorageKey


       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfile1 -File $resultsfile1 -Context $destContext -force


########################

       $storagecontainer = 'uscostlistreport'

       
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
               
               
        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  –StorageAccountName $storageaccountname).value | select -first 1
        $destContext = New-azStorageContext  –StorageAccountName $storageaccountname `
                                        -StorageAccountKey $StorageKey



        Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfile2  -File $resultsfile2 -Context $destContext -force


#################
        
       $storagecontainer = 'azpricelistreport'



        
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



        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  –StorageAccountName $storageaccountname).value | select -first 1
        $destContext = New-azStorageContext  –StorageAccountName $storageaccountname `
                                        -StorageAccountKey $StorageKey




       
         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfile3  -File $resultsfile3 -Context $destContext -force
         
 

