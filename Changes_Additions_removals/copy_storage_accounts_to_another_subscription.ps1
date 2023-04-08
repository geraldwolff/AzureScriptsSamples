import-module -Name  Az.ContainerInstance



Connect-AzAccount



 
 $region = 'westus'



 
           set-azcontext -subscription wpi-corp 

                $deststorageaccount = "wpibackupstorage"
                $destresourcegroupname = 'jwolffbackups'


    try
     {
         if (!(Get-AzStorageAccount -ResourceGroupName $destresourcegroupname -Name $deststorageaccount ))
        {  
            Write-Host "Storage Account Does Not Exist, Creating Storage Account: $deststorageaccount Now"

            # b. Provision storage account

            New-AzStorageAccount -ResourceGroupName $destresourcegroupname  -Name $deststorageaccount -Location $region -AccessTier cool -SkuName Standard_LRS -Kind BlobStorage -Tag @{"owner" = "Jerry wolff"; "purpose" = "backups" } -Verbose
 
     
            Get-AzStorageAccount -Name   $deststorageaccount  -ResourceGroupName  $destresourcegroupname  -verbose
         }
       }
       Catch
       {
             WRITE-DEBUG "Storage Account Aleady Exists, SKipping Creation of $deststorageaccount"
   
       } 

        $deststorage = Get-AzStorageAccount -Name   $deststorageaccount  -ResourceGroupName  $destresourcegroupname  -verbose
  
            $deststorageaccount =  Get-AzStorageAccount -ResourceGroupName $destresourcegroupname -Name $deststorage.StorageAccountName

            $deststorageaccounturipros = $deststorageaccount.PrimaryEndpoints.blob

            $destStorageKey = (Get-AzStorageAccountKey -ResourceGroupName $destresourcegroupname  –StorageAccountName $deststorageaccount.StorageAccountName).value | select -first 1
            $destContext = New-azStorageContext  –StorageAccountName $deststorageaccount.StorageAccountName `
                                            -StorageAccountKey $destStorageKey


#############################################


set-azcontext -subscription wolffmssub -Force

$resourcegroupname = 'wolffmsbackups'

 

      $storageaccountlist = Get-AzStorageAccount -ResourceGroupName $resourcegroupname  | select-object -Property *

foreach($storageaccount in $storageaccountlist)
{
        $storageaccountname =  $($storageaccount.storageaccountname)

        $storageaccounturipros = $storageaccount.PrimaryEndpoints.blob
 
       $srcStorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  –StorageAccountName $storageaccountname).value | select -first 1
      $srcContext = New-azStorageContext  –StorageAccountName $storageaccountname `
                                            -StorageAccountKey $srcStorageKey
        $srccontainers = get-azstoragecontainer  -Context $srcContext

             foreach($storagecontainer in $srccontainers)
             {


                 $srccontaineruriprops =  (get-azstoragecontainer -Name $($storagecontainer.name) -Context $srcContext).CloudBlobContainer.Uri
           
               $srcstorageuri = $srccontaineruriprops.AbsoluteUri
 
     
    get-childitem -path "C:\Users\jerrywolff\AppData\Local\Microsoft\Azure\AzCopy"  -recurse -file | remove-item -verbose -force  -confirm:$false

    $targetaccount = ("$storageaccounturipros") 
             azcopy /source:"$srcstorageuri" /sourcekey:$srcStorageKey /dest:"$deststorageaccounturipros$($storagecontainer.Name)" /destkey:$destStorageKey   /S /V /NC:10


    }
 }






 
 

























