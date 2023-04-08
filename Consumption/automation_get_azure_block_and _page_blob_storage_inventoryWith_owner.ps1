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
connect-azaccount # -Identity


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
 
                               $stgkey =  (Get-AZStorageAccountKey -Name $StorageAccountName -ResourceGroupName $storageaccountrg) 
  
                      
                                $stgkey.value
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
                                    Get-AZStorageBlob -Context  $ctx  -Container $containeritem.Name

                                    $containername = $containeritem.name  

                                    #List the snapshots of a blob.

                                    $blobs =   Get-AZStorageBlob –Context $Ctx  -Container $ContainerName   

                                   $subowner =   get-AzRoleAssignment    -Scope "/subscriptions/$SubscriptionID"   -RoleDefinitionName owner

                                      foreach($blob in $blobs)
                                      {

 
                                        $BlobType = $blob.blobtype
                                        $blobname = $blob.Name
                                        $blobcontenttype = $blob.ContentType
                                        $bloblastmodified = $blob.LastModified
                                        $blobcontect = $blob.Context
                                        $blobICloudBlob = $blob.ICloudBlob.Name
 

                                        $obj = new-object PSObject
                                        $obj | add-member -membertype NoteProperty -name "subscriptioname" -value "$SubscriptionName"
                                        $obj | add-member -membertype NoteProperty -name "Subscriptionowner" -value "$($subowner.signinname)"
                                        $obj | add-member -membertype NoteProperty -name "storageaccountname" -value "$storageaccountname"
                                        $obj | add-member -membertype NoteProperty -name "storageaccountendpoints" -value "$storageaccountendpoints"
                                        $obj | add-member -membertype NoteProperty -name "storageaccountlocation" -value "$storageaccountlocation "
                                        $obj | add-member -membertype NoteProperty -name "storageaccount_type" -value "$storageaccount_type"
                                        $obj | add-member -membertype NoteProperty -name "storageaccountstatus" -value "$storageaccountstatus"
                                        $obj | add-member -membertype NoteProperty -name "storageacctkeyprimary" -value "$storageacctkeyprimary"
                                        $obj | add-member -membertype NoteProperty -name "storageacctkeySecondary" -value "$storageacctkeySecondary"
                                        $obj | add-member -membertype NoteProperty -name "storageacctkeyStorageAccountName" -value "$storageacctkeyStorageAccountName"   
                                        $obj | add-member -membertype NoteProperty -name "containername" -value "$containername"
                                        $obj | add-member -membertype NoteProperty -name "BlobType" -value "$BlobType"
                                        $obj | add-member -membertype NoteProperty -name "blobname" -value "$blobname"   
                                        $obj | add-member -membertype NoteProperty -name "blobcontenttype" -value "$blobcontenttype"
                                        $obj | add-member -membertype NoteProperty -name "bloblastmodified" -value "$bloblastmodified"
                                        $obj | add-member -membertype NoteProperty -name "blobcontect" -value "$blobcontect"                                    
                                        $obj | add-member -membertype NoteProperty -name "blobICloudBlob" -value "$blobICloudBlob"
                                   [array]$AZStoragelist +=     $obj  

                                 }
                }

        }

    }

 $date = $(Get-Date -Format 'dd MMMM yyyy' )
 
    $CSS = @"
<Title> Azure Storage list Report: $date </Title>
<Style>
th {
	font: bold 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	color: #FFFFFF;
	border-right: 1px solid #C1DAD7;
	border-bottom: 1px solid #C1DAD7;
	border-top: 1px solid #C1DAD7;
	letter-spacing: 2px;
	text-transform: uppercase;
	text-align: left;
	padding: 6px 6px 6px 12px;
	background: #5F9EA0;
}
td {
	font: 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	border-right: 1px solid #C1DAD7;
	border-bottom: 1px solid #C1DAD7;
	background: #fff;
	padding: 6px 6px 6px 12px;
	color: #6D929B;
}
</Style>
"@


 

 
$AZStoragelist_report = ($AZStoragelist | sort-object addressprefix   | Select  subscriptioname,Subscriptionowner, storageaccountname , storageaccountendpoints ,storageaccountlocation  ,storageacctkeyprimary, storageacctkeySecondary,storageacctkeyStorageAccountName,`
containername,BlobType,blobcontenttype,bloblastmodified, blobcontect,blobICloudBlob|`   
ConvertTo-Html -Head $CSS )  | out-file "c:\temp\Azure_storage_account_Inventory.html" 

invoke-item "c:\temp\Azure_storage_account_Inventory.html" 


$AZStoragelist | sort-object addressprefix   | Select  subscriptioname,Subscriptionowner, storageaccountname , storageaccountendpoints ,storageaccountlocation  ,storageacctkeyprimary, storageacctkeySecondary,storageacctkeyStorageAccountName,`
containername,BlobType,blobcontenttype,bloblastmodified, blobcontect,blobICloudBlob| export-csv "c:\temp\Azure_storage_account_Inventory.csv" -notypeinformation
 

 $AZStoragelist_report = ($AZStoragelist |where BlobType -like '*page*'| sort-object addressprefix   | Select  subscriptioname, Subscriptionowner,storageaccountname , storageaccountendpoints ,storageaccountlocation  ,storageacctkeyprimary, storageacctkeySecondary,storageacctkeyStorageAccountName,`
containername,BlobType,blobcontenttype,bloblastmodified, blobcontect,blobICloudBlob |`   
ConvertTo-Html -Head $CSS )  | out-file "c:\temp\Azure_storage_Page_blobaccount_Inventory.html" 
 
 
 invoke-item "c:\temp\Azure_storage_Page_blobaccount_Inventory.html" 
 
 
 $AZStoragelist |where BlobType -like '*page*'| sort-object addressprefix   | Select  subscriptioname, Subscriptionowner,storageaccountname , storageaccountendpoints ,storageaccountlocation  ,storageacctkeyprimary, storageacctkeySecondary,storageacctkeyStorageAccountName,`
containername,BlobType,blobcontenttype,bloblastmodified, blobcontect,blobICloudBlob | export-csv "c:\temp\Azure_storage_Page_blobaccount_Inventory.csv" -notypeinformation






