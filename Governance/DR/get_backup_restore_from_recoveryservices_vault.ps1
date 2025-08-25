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

Summary 
Script: Backup_restore_dr\get_backup_restore_from_recoveryservices_vault.ps1
 This script imports a module, connects to an Azure account, selects a subscription, selects a 
 recovery services vault, sets the vault context, gets backup jobs, and exports the job status
  to a CSV file. It also creates a storage account, uploads the CSV files to the storage account, 
  and creates containers for successful and failed backup jobs.

  Detailed: 

 This script performs several tasks related to managing Azure resources and backup jobs. Here is
  a detailed explanation of each section of the script:

Importing the Azure Recovery Services module: The script starts by importing the Azure Recovery 
Services module using the Import-Module cmdlet. This module provides cmdlets for managing backup 
and recovery services in Azure.

Connecting to an Azure account: Next, the script connects to an Azure account using the
 Connect-AzAccount cmdlet. The script prompts the user to enter their credentials and select 
 their environment. The cmdlet returns an access token that the script stores in the $credential variable.

Selecting an Azure subscription: The script uses the Get-AzSubscription cmdlet to get a list
 of all available subscriptions. It then prompts the user to select a subscription from the
  list using the Out-GridView cmdlet. The script stores the selected subscription in the
   $subscriptionselected variable.

Selecting a recovery services vault: The script uses the Get-AzRecoveryServicesVault cmdlet
 to get a list of all recovery services vaults in the selected subscription. It prompts the
  user to select a vault from the list using the Out-GridView cmdlet. The script stores the
   selected vault in the $vaultselected variable.

Setting the context for the selected vault: The script uses the Set-AzRecoveryServicesVaultContext 
cmdlet to set the context for the selected vault. This allows the script to perform backup 
and recovery operations on the vault.

Getting backup job information: The script uses the Get-AzRecoveryServicesBackupJob cmdlet 
to get a list of all backup jobs for the selected vault. It filters the list to include only full and
 		#> 

import-module -name az.RecoveryServices | out-null


$connection = connect-azaccount  # -Environment AzureUSGovernment
$credential = Get-AzAccessToken

$subscriptions = get-azsubscription

$subscriptionselected = $subscriptions | ogv -Title " Select the subscription for the restoration process: " -PassThru | Select * -First 1

set-azcontext -Subscription $($subscriptionselected.name) 


 

$recoveryservicesvaults = Get-AzRecoveryServicesVault

$vaultselected = $recoveryservicesvaults | ogv -Title " Select recovery services vault to use :" -PassThru | select *

$vault = Get-AzRecoveryServicesVault -ResourceGroupName $($vaultselected.ResourceGroupName) -Name $($vaultselected.Name) 

 $startDate = ((Get-Date).addmonths(-6)).ToUniversalTime()
 $endDate = (Get-Date).ToUniversalTime()


Set-AzRecoveryServicesVaultContext -Vault $vault 
 

$backupitems = ''
  
 $jobstatus =''


 $backupjobs = Get-AzRecoveryServicesBackupJob   -VaultId $vault.ID | where-object {$_.operation -like '*Full*'  -or $_.operation -like 'log'}

 
$checkdate = get-date -Format('MMddyyy_HHmm')
 

       $countofselected = $backupjobs | Measure-Object | select count

 foreach($backupstatus in $backupjobs)
 {
     
      $backupstatus
      

      $Joblist | foreach-object { 

    $jobobj = new-object PSObject 

    $jobobj | Add-Member -MemberType NoteProperty -Name workload -Value $($_.WorkloadName) 
    $jobobj | Add-Member -MemberType NoteProperty -Name Operation -Value $($_.Operation) 
    $jobobj | Add-Member -MemberType NoteProperty -Name status -Value $($_.status) 
    $jobobj | Add-Member -MemberType NoteProperty -Name Starttime -Value $($_.Starttime) 
    [array]$jobstatus += $jobobj
    }
}
    $jobstatusfilename = "DBjobstatus_$($checkdate).csv"
    $Failedjobstatusfilename = "FailedDBjobstatus_$($checkdate).csv"

   $jobstatus | SELECT Workload, Operation,status,Starttime -Unique
  $jobstatus | select Workload, Operation,status,Starttime -Unique | where status -eq 'Failed' | export-csv $Failedjobstatusfilename -NoTypeInformation  

   $jobstatus | select Workload, Operation,status,Starttime -Unique| export-csv $jobstatusfilename -NoTypeInformation  

###################################################################
 #storage account logging

 ##### storage subinfo
 ##Uncomment next line if storage account is uder a dfferent profile/temant
#connect-azaccount 
 

$Region =  "West US"

 $subscriptionselected = 'wolffentpsub'



$resourcegroupname = 'wolffautomationrg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = 'wolffautosa'
$storagecontainer = 'dbbackupjobs'


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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $jobstatusfilename  -File $jobstatusfilename -Context $destContext -Force




$resourcegroupname = 'wolffautomationrg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = 'wolffautosa'
$storagecontainer = 'dbfailedbackupjobs'
 
  
   
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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $Failedjobstatusfilename  -File $Failedjobstatusfilename -Context $destContext -Force

