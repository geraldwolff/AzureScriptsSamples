 <#
.SYNOPSIS  
 Wrapper script to copy storage accounts contents from one subscription to another
.DESCRIPTION  
 Wrapper script to copy storage accounts contents from one subscription to another
.EXAMPLE  
.\copy_storage_accounts_to_another_subscription.ps1
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

 

$sourcesubscription =  'wolffMSSUB'
$destsubscription = 'wpi-corp' 

## will copy all source storage account and contents using aZCOPY  ###

$sourceResourcegroup = 'wolffmsbackups'
 
$destresourcegroupname = 'jwolffbackups'

 $deststorageaccount = "wpibackupstorage"
                 
  

 #### Location '<region or location>'
 $region = 'westus'

  ######  Check to see if destination storage account and resourcegroupname exist

           set-azcontext -subscription $destsubscription 

      
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


set-azcontext -subscription $sourcesubscription -Force



 

      $storageaccountlist = Get-AzStorageAccount -ResourceGroupName $sourceResourcegroup  | select-object -Property *

foreach($storageaccount in $storageaccountlist)
{
        $storageaccountname =  $($storageaccount.storageaccountname)

        $storageaccounturipros = $storageaccount.PrimaryEndpoints.blob
 
       $srcStorageKey = (Get-AzStorageAccountKey -ResourceGroupName $sourceResourcegroup  –StorageAccountName $storageaccountname).value | select -first 1
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






 
 

























