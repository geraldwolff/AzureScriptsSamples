

<# 

.NOTES

    THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 

    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 

    FITNESS FOR A PARTICULAR PURPOSE.

    This sample is not supported under any Microsoft standard support program or service. 

    The script is provided AS IS without warranty of any kind. Microsoft further disclaims all

    implied warranties including, without limitation, any implied warranties of merchantability

    or of fitness for a particular purpose. The entire risk arising out of the use or performance

    of the sample and documentation remains with you. In no event shall Microsoft, its authors,

    or anyone else involved in the creation, production, or delivery of the script be liable for 

    any damages whatsoever (including, without limitation, damages for loss of business profits, 

    business interruption, loss of business information, or other pecuniary loss) arising out of 

    the use of or inability to use the sample or documentation, even if Microsoft has been advised 

    of the possibility of such damages, rising out of the use of or inability to use the sample script, 

    even if Microsoft has been advised of the possibility of such damages.

#> 


param(

[String]$Location = $(throw "Value for Location is missing"),
[String]$subscription = $(throw "Value for Subscription is missing")
)



 ######################33
 ##  Necessary Modules to be imported.

import-module Az.Compute -force 
import-module az.marketplaceordering  -force
import-module Az.BareMetal -force 


 ############
 ## connect to Azure with authorized credentials 
 
 Connect-AzAccount # -Environment AzureUSGovernment

### Cleanup 

$publisheroffertable =''


       

				  
            $sub  = get-azsubscription  -SubscriptionName $subscription  | select subscriptionname, subscriptionID
            

             
                   $EnvironmentSubscriptionName = $sub.subscriptionname
                   $EnvironmentSubscriptionid =  $sub.subscriptionID

                        Select-azSubscription   -SubscriptionName $EnvironmentSubscriptionName -verbose
              #   set-azuresubscription -SubscriptionName $EnvironmentSubscriptionName

					set-azcontext -Subscription $($sub.subscriptionname)


				  Get-azSubscription  -Verbose  
				  
 
 

            # Present locations and allow user to choose location of their choice for Resource creation.
            #
 

### PRep for skus completeness 

##Get-AzResourceProvider -ListAvailable | where ProviderNamespace -eq 'microsoft.avs' |  Register-AzResourceProvider -verbose
#Get-AzResourceProvider -ListAvailable | where ProviderNamespace -eq 'Microsoft.BareMetalInfrastructure' |  Register-AzResourceProvider -verbose
 
 
 
		  #View the templates available
        $loc = Get-azLocation  | where-Object Location -eq $location  #first set a location
       $userlocation = $($loc.Location)


        $publishers = Get-azVMImagePublisher -Location $userlocation |  select PublisherName 

        foreach($publishername in $publishers)
        {



                    $publisherofferobj = new-object PSObject 


             #View the templates available
            $publisherimages=Get-azVMImagePublisher -Location $userlocation | where-object publishername -eq $($publishername.PublisherName)   | select publishername #check all the publishers available
             $publisherimages.PublisherName 

             foreach($publisherimage in $publisherimages)
             {

                    $offers = Get-azVMImageOffer -Location $userlocation -PublisherName $($publisherimage.PublisherName)  | where-object publishername -eq  $($publisherimage.PublisherName)  |select offer #look for offers for a publisher
                     $offers.Offer

                     foreach($offer in $offers)
                     {

                          $skus = Get-azVMImageSku -Location $userlocation -PublisherName $($publisherimage.PublisherName)  -Offer $offer.Offer    
                         $skuselected =$skus.skus

                          foreach($sku in $skus)
                          {

                           $svrversion =  Get-azVMImage -Location $userlocation -PublisherName $($publisherimage.PublisherName)  -Offer $offer.Offer -Skus $($sku.Skus)   | select version  -ErrorAction SilentlyContinue  #pick one.!
                           $version = $svrversion.Version 

                                  # $vmSizes  =  Get-azVMSize -Location "$userloc"  | ogv -passthru | select name 
                          }
                    }


                              $publisherofferobj | Add-Member -MemberType NoteProperty -Name   Location    -value $($loc.Location)
              $publisherofferobj | Add-Member -MemberType NoteProperty -Name   Location_Physicallocation     -value $($loc.Physicallocation)
              $publisherofferobj | Add-Member -MemberType NoteProperty -Name   location_geography    -value $($loc.Geographygroup)
              $publisherofferobj | Add-Member -MemberType NoteProperty -Name   PublisherName      -value $($publishername.Publishername)
              $publisherofferobj | Add-Member -MemberType NoteProperty -Name   Sku   -value  $sku 
              $publisherofferobj | Add-Member -MemberType NoteProperty -Name   Offer      -value $($Offer.Offer)
              $publisherofferobj | Add-Member -MemberType NoteProperty -Name   Version    -value $Version
              $publisherofferobj | Add-Member -MemberType NoteProperty -Name   Subscriptionid    -value $($sku.id)




            }
   
   
   
        [array]$publisheroffertable += $publisherofferobj

    
        }

        

         

# $publisheroffertable 

 $resultsfilename = "publisherskureport$($loc.Location).csv"


 $publisheroffertable  | select Location, Location_Physicallocation,location_geography, PublisherName, Sku, Offer, Version, Subscriptionid `
 | export-csv $resultsfilename -NoTypeInformation



 ##### storage subinfo

$Region =  "<location/region>"

 $subscriptionselected = '<Subscription>'



$resourcegroupname = '<resourcegroupname>'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = '<storageaccountname>'
$storagecontainer = 'publisherskuinformation'


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
        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  -StorageAccountName $storageaccountname).value | select -first 1
        $destContext = New-azStorageContext  -storageaccountname $storageaccountname `
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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename  -File $resultsfilename -Context $destContext -force
        
 
     














