<###########################################################################################
# Add the SQL Server provider.
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
 


##########################################################################################
#>


connect-azaccount 


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
  
                                <#
                                    Primary              : NIeCrLwBBkGPV7wqu8htCIo2Sxv13XgzMfPnnsrPV/Z33ZJSOweY1FhgZtDww2Fn8C3eQjkLoGx/D1Z3eMRWxg==
                                    Secondary            : H7P5kDFAOaACJbe3TcnyhwuAHFO3PTYLVFokRCH1naPaRtnVPNXFrTUSatlOU7sm6hXD8+oAk1W6FwxP58j13A==
                                    StorageAccountName   : supportimages
                                    OperationDescription : Get-AZStorageKey
                                    OperationId          : 446eff60-1216-3e90-b825-1f3245bf1a3b
                                    OperationStatus      : Succeeded
                                #>
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



                                      foreach($blob in $blobs)
                                      {

                                      <#

                              
                                        ICloudBlob        : Microsoft.WindowsAzure.Storage.Blob.CloudBlockBlob
                                        BlobType          : BlockBlob
                                        Length            : 4091876
                                        ContentType       : application/octet-stream
                                        LastModified      : 2/15/2016 6:37:47 AM +00:00
                                        SnapshotTime      : 
                                        ContinuationToken : 
                                        Context           : Microsoft.WindowsAzure.Commands.Common.Storage.LazyAZStorageContext
                                        Name              : 6cb1c84c-d3ae-11e5-9bd9-0050b671a5b5_jason@jasonegeplace.com-1.zip
                                                                      #>
                                        $BlobType = $blob.blobtype
                                        $blobname = $blob.Name
                                        $blobcontenttype = $blob.ContentType
                                        $bloblastmodified = $blob.LastModified
                                        $blobcontect = $blob.Context
                                        $blobICloudBlob = $blob.ICloudBlob.Name
 

                                        $obj = new-object PSObject

     ##################################################  Get tage data

                                 $Resource = Get-AzResource -Name $StorageAccountName | select -Property *


                               $Resource.Tags.GetEnumerator() | ForEach-Object {

                                   #Write-Output "$($_.key)   = $($_.Value)" 
 
                                  $obj | add-member -membertype Noteproperty -name $($_.key) -value $($_.value)

                                  }




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


 

 
$AZStoragelist_report = ($AZStoragelist | sort-object addressprefix   | Select  subscriptioname, storageaccountname , storageaccountendpoints ,storageaccountlocation ,storageacctkeyStorageAccountName,`
containername,BlobType,blobcontenttype,bloblastmodified, blobcontect,blobICloudBlob|`   
ConvertTo-Html -Head $CSS )  | out-file "c:\temp\Azure_storage_account_Inventory.html" 

invoke-item "c:\temp\Azure_storage_account_Inventory.html" 

 


 
 

 
 







