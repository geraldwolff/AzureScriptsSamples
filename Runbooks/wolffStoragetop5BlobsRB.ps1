 <#
.SYNOPSIS  
 Wrapper script for Azure storage inventory
.DESCRIPTION  
 Wrapper script for Azure storage inventory to html report
.EXAMPLE  
.\automation_get_azure_block_and _page_blob_storage_inventory.ps1
Version History  
v1.0   - Initial Release  
 

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

### uncomment when using for AAzure Automation
 connect-azaccount   -Identity
<#
try
{ 

    "Logging in to Azure..." 

$identity = Get-AzUserAssignedIdentity -ResourceGroupName wolffautorg -Name wolffautomationMI
Connect-AzAccount -Identity -AccountId $identity.ClientId 
} 
catch { 
    Write-Error -Message $_.Exception 
    throw $_.Exception 
} 

#>

###########
import-module az.storage -force

      $AZStoragelist =''  
             $subscriptionlist =  Get-AZSubscription |select  name, ID 

    foreach($Subscription  in $subscriptionlist)
    {

             $SubscriptionName =  $Subscription.name
             
             $SubscriptionID =  $Subscription.ID 

            set-AZcontext -SubscriptionName  $SubscriptionName

             write-host "$SubscriptionName" -foregroundcolor yellow

            #Get-Command -Module Azure -Noun *Storage*`


             $SubscriptionName 
             $storageaccounts = Get-AZStorageAccount | select StorageAccountName, context, PrimaryEndpoints,AccountType, ProvisioningState ,PrimaryLocation ,Resourcegroupname ,Tags


                foreach($storageaccount in $storageaccounts)
                { 
                            $StorageAccountName = $storageaccount.StorageAccountName
                            $storageaccountrg = $storageaccount.resourcegroupname
                              

                                 #$stgacct = Get-AZStorageAccount | Format-Table -Property StorageAccountName, Location, AccountType, StorageAccountStatus

                                 Set-AZContext -SubscriptionName $SubscriptionName 

                          #       Set-AZStorageAccount -StorageAccountName $StorageAccountName -ResourceGroupName $storageaccountrg
 
                               $stgkey =  (Get-AZStorageAccountKey -Name $StorageAccountName -ResourceGroupName $storageaccountrg -erroraction silentlycontinue)
  
                      
                               # $stgkey.value
                                $storageacctkeyprimary = ($stgkey.value ) | select -First 1
                                $storageacctkeySecondary = ($stgkey.value ) | select -skip 1  
                                $storageacctkeyStorageAccountName = $StorageAccountName
 
 

                              $storageaccountendpoints = $storageaccount.PrimaryEndpoints
                              $storageaccountlocation = $storageaccount.PrimaryLocation
                              $storageaccount_type =  $storageaccount.AccountType
                              $storeageaccountstatus = $storageaccount.StatusOfPrimary
                    
                               # $ctx = $storageaccount.context
                                $ctx = New-AZStorageContext -StorageAccountName  $StorageAccountName -StorageAccountKey $storageacctkeyprimary 
                               $containers = Get-AzStorageContainer  -context $ctx




                               foreach($containeritem in $containers)
                              {
                                   # Get-AZStorageBlob -Context  $ctx  -Container $containeritem.Name

                                    $containername = $containeritem.name  

                                    #List the snapshots of a blob.

                                    $blobs =   Get-AZStorageBlob –Context $Ctx  -Container $ContainerName | where length -gt 0   | Sort-Object length -desc | select -First 10



                                      foreach($blob in  $blobs )
                                      {

 
                                        $BlobType = $blob.blobtype
                                        $blobname = $blob.Name
                                        $blobcontenttype = $blob.ContentType
                                        $bloblastmodified = $blob.LastModified
                                        $blobcontect = $blob.Context
                                        $blobICloudBlob = $blob.ICloudBlob.Name
                                  


                                        $obj = new-object PSObject
                                        $obj | add-member -membertype NoteProperty -name "subscriptioname" -value "$SubscriptionName"
                                        $obj | add-member -membertype NoteProperty -name "storageaccountname" -value "$storageaccountname"
                                        $obj | add-member -membertype NoteProperty -name "storageaccountendpoints" -value "$storageaccountendpoints"
                                        $obj | add-member -membertype NoteProperty -name "storageaccountlocation" -value "$storageaccountlocation "
                                        $obj | add-member -membertype NoteProperty -name "storageaccount_type" -value "$storageaccount_type"
                                        $obj | add-member -membertype NoteProperty -name "storageaccountstatus" -value "$storageaccountstatus"
                                        $obj | add-member -membertype NoteProperty -name "storageacctkeyStorageAccountName" -value "$storageacctkeyStorageAccountName"   
                                        $obj | add-member -membertype NoteProperty -name "containername" -value "$containername"
                                        $obj | add-member -membertype NoteProperty -name "BlobType" -value "$BlobType"
                                        $obj | add-member -membertype NoteProperty -name "blobname" -value "$blobname"   
                                        $obj | add-member -membertype NoteProperty -name "blobcontenttype" -value "$blobcontenttype"
                                        $obj | add-member -membertype NoteProperty -name "bloblastmodified" -value "$bloblastmodified"
                                        $obj | add-member -membertype NoteProperty -name "blobcontext" -value "$blobcontext"                                    
                                        $obj | add-member -membertype NoteProperty -name "blobICloudBlob" -value "$blobICloudBlob"
                                        $obj | add-member -membertype NoteProperty -name "blobSize" -Value $($blob.Length)
                                   [array]$AZStoragelist +=     $obj  

                                 }
                }

        }

    }

 $date = $(Get-Date -Format 'dd MMMM yyyy' )
 
########### Prepare for storage account export

$csvresults = $AZStoragelist| Select subscriptioname,  storageaccountname, storageaccountendpoints, storageaccountlocation, storageaccount_type , storageaccountstatus, storageacctkeyStorageAccountName, containername,BlobType,blobname,blobcontenttype, bloblastmodified,blobcontext,blobICloudBlob,blobSize

 $resultsfilename = "Top5storageBlobs.csv"

$csvresults  | export-csv $resultsfilename  -NoTypeInformation   

# end vmss data 


##### storage subinfo

$Region = "West US"
 $date = Get-Date -Format MMddyyyy
 $subscriptionselected = 'Subscription'



$resourcegroupname = 'wolffautorg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | select tenantid
$storageaccountname = 'wolffautomationsa'
$storagecontainer = 'largestorageblobs'
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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfile  -File $resultsfilename -Context $destContext
        
        
 
 
     
 
 
 
 







