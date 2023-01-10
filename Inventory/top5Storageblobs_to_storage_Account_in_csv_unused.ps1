 <#
.SYNOPSIS  
 Wrapper script for Azure storage inventory
.DESCRIPTION  
 Wrapper script for Azure storage top 5 Blobs inventory to html report
.EXAMPLE  
.\top5Storageblobs_to_storage_Account_in_csv_unused.ps1
Version History  
v1.1   - Modified released and new name 
        - Added date range to look back and identifiy only blobs with a lastmodified data older than <$range> value 
        - $range = 90 default 
        -  #added BlobProperties.LastAccessed.DateTime
        - $count is the count of the top number of discovered record to avaoid over loading and trimming the report  - modify before the run 
        - in the ##### write to storage account section at the bottom, update the storage account, resourcegroupnames and subscription where 
           you want to write the results out to if storage account collection is desired 

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
$connection = connect-azaccount  # -Identity



#$accountcontext = set-azcontext -SubscriptionName    $($connection.Context.Subscription.Name)

$count = 10

$date = get-date -Format "MM/dd/yyyy HH:MM:ss" 
 
 $range = 90

$unuseddaterange = (get-date).AddDays(-$range)



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

                                    $blobs =   Get-AZStorageBlob –Context $Ctx  -Container $ContainerName | where-object {$_.length -gt 0 -and $_.lastmodified -lt $unuseddaterange  -and $_.BlobProperties.LastAccessed.DateTime -lt $unuseddaterange }  | Sort-Object length -desc | select -First $count

                                    #added BlobProperties.LastAccessed.DateTime

                                      foreach($blob in  $blobs )
                                      {

 
                                        $BlobType = $blob.blobtype
                                        $blobname = $blob.Name
                                        $blobcontenttype = $blob.ContentType
                                        $bloblastmodified = $blob.LastModified
                                        $bloblastaccessed = $blob.BlobProperties.LastAccessed.DateTime
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
                                        $obj | add-member -membertype NoteProperty -name "bloblastaccessed" -value "$bloblastmodified"
                                        $obj | add-member -membertype NoteProperty -name "blobcontext" -value "$blobcontext"                                    
                                        $obj | add-member -membertype NoteProperty -name "blobICloudBlob" -value "$blobICloudBlob"
                                        $obj | add-member -membertype NoteProperty -name "blobSize" -Value $($blob.Length)
                                   [array]$AZStoragelist +=     $obj  

                                 }
                }

        }

    }


    

$date = $(Get-Date -Format 'dd MMMM yyyy' )
 
    $CSS = @"
<Title> Azure stroage : $date </Title>
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


($AZStoragelist| Select subscriptioname,  storageaccountname, storageaccountendpoints, storageaccountlocation, storageaccount_type , storageaccountstatus, storageacctkeyStorageAccountName, containername,BlobType,blobname,blobcontenttype, bloblastmodified,blobcontext,blobICloudBlob,blobSize| `   
ConvertTo-Html -Head $CSS )  | out-file "c:\temp\azstorage.html" 

Invoke-Item "c:\temp\azstorage.html" 








##### write to storage account




 $date = $(Get-Date -Format 'dd MMMM yyyy' )
 
########### Prepare for storage account export

$csvresults = $AZStoragelist| Select subscriptioname,  storageaccountname, storageaccountendpoints, storageaccountlocation, storageaccount_type , storageaccountstatus, storageacctkeyStorageAccountName, containername,BlobType,blobname,blobcontenttype, bloblastmodified,blobcontext,blobICloudBlob,blobSize

 $resultsfilename = "Top5storageBlobs$date.csv"

$csvresults  | export-csv $resultsfilename  -NoTypeInformation   

# end vmss data 


##### storage subinfo

$Region = "<Location/Region>"
 $date = Get-Date -Format MMddyyyy
 $subscriptionselected = '<Subscription>'



$resourcegroupname = '<Resourcegroup>'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | select tenantid
$storageaccountname = '<Storageaccount>'
$storagecontainer = 'automationresults'
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
        
        
 
 
     
 
 
 
 







