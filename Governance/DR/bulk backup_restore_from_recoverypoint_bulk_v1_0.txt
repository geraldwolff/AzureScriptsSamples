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
        bulk backup_restore_from_recoverypoint_bulk
        This PowerShell script connects to an Azure Recovery Services Vault, 
        allows the user to select a backup VM, and then allows the user to select 
        a recovery point for that VM. 

        It then creates a storage account and restores the selected recovery point 
        to the storage account. Finally, it provides the restore job status for the user to review.

         The script includes error handling and requires user input for some selections. 
         A disclaimer at the beginning of the script warns that it is not supported under
          any Microsoft standard support program or service, and is provided as-is without warranty.

    Note: this version will fail and produce a warning if the Vm being restored was deleted and the resourcegroup no longer exists
          This version is sequential from the select VMs restorepoints 


#> 

import-module -name az.RecoveryServices | out-null


connect-azaccount  #-Environment AzureUSGovernment

$subscriptions = get-azsubscription

$subscriptionselected = $subscriptions | ogv -Title " Select the subscription for the restoration process: " -PassThru | Select * -First 1

set-azcontext -Subscription $($subscriptionselected.name) 


 

$recoveryservicesvaults = Get-AzRecoveryServicesVault

$vaultselected = $recoveryservicesvaults | ogv -Title " Select recovery services vault to use :" -PassThru | select *

$vault = Get-AzRecoveryServicesVault -ResourceGroupName $($vaultselected.ResourceGroupName) -Name $($vaultselected.Name) 

 $startDate = ((Get-Date).addmonths(-6)).ToUniversalTime()
 $endDate = (Get-Date).ToUniversalTime()


Set-AzRecoveryServicesVaultContext -Vault $vault 


$containers = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $vault.ID

$containerslist = $containers | ogv -title " Select a container to get backups from:" -PassThru | select *


$backupitems = ''
$rpsresults = ''


#$containerselected = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $vault.ID -FriendlyName $($containerslist.FriendlyName)

foreach($container in $containerslist)
{
    $containerinfo = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $vault.ID -FriendlyName $($container.FriendlyName)
    $backupiteminfo   = Get-AzRecoveryServicesBackupItem -Container $containerinfo  -WorkloadType AzureVM -VaultId $vault.ID  


    $backupobj = new-object  PSObject 

    $backupobj | Add-Member -MemberType NoteProperty -Name Friendlyname -Value $($container.FriendlyName)
    $backupobj | Add-Member -MemberType NoteProperty -Name ResourceGroupName -Value $($container.ResourceGroupName)
    $backupobj | Add-Member -MemberType NoteProperty -Name Containername -value $($container.Name)
    $backupobj | Add-Member -MemberType NoteProperty -Name backupitemname -Value $($backupiteminfo.Name)
    $backupobj | Add-Member -MemberType NoteProperty -Name VMid -Value $($backupiteminfo.VirtualMachineId)
    $backupobj | Add-Member -MemberType NoteProperty -Name LastBackupStatus -Value $($backupiteminfo.LastBackupStatus)

     
    [array]$backupitems += $backupobj
     

}
 
$backupItemselected  =  $backupitems  | select Friendlyname, ResourceGroupName,Containername,backupitemname, VMid, LastBackupStatus | where-object {$_.Friendlyname -ne $null}   | ogv -Title " Select backup Vm(s) :" -PassThru | select *



foreach($restorepoint in $backupItemselected)
{

          if (!(Get-AzResourceGroup -ResourceGroupName  $($restorepoint.Resourcegroupname)  -erroraction silentlycontinue)   ) 
            {  
                Write-Host "Resourcegroup has changed or no longet exists Exist, Creating Resourcegroup: $($restorepoint.Resourcegroupname) Now"
               Write-Warning " $($restorepoint.Resourcegroupname) does not exist, Skipping this item " 
             }

     
                if(($rpvmname = get-azvm -ResourceId $($restorepoint.VMid) -ErrorAction SilentlyContinue))
                {

                 $bkpItems = Get-AzRecoveryServicesBackupItem -BackupManagementType AzureVM -WorkloadType AzureVM -Name $($restorepoint.Friendlyname) -VaultId $vault.ID

                    foreach($bkpitem in $bkpitems)
                     {

                        $rpvmname = get-azvm -name $($restorepoint.Friendlyname)
 
                        $rpvmlocation = $($rpvmname.location)
       
 
                        $rps  = Get-AzRecoveryServicesBackupRecoveryPoint -Item $bkpItem  -VaultId $vault.ID -StartDate  $startDate  -EndDate  $endDate  
 

                         foreach($recoverpointdate in $rps)
                         {
                                    $rpoobj = new-object Psobject 

                                            $rpoobj | Add-Member -MemberType NoteProperty -Name VMname    -Value $($rpvmname.name) 
                                            $rpoobj | Add-Member -MemberType NoteProperty -Name Location    -Value $($rpvmname.Location)
                                            $rpoobj | Add-Member -MemberType NoteProperty -Name RecoveryPointId    -Value $($recoverpointdate.RecoveryPointId)
                                            $rpoobj | Add-Member -MemberType NoteProperty -Name RecoveryPointType    -Value $($recoverpointdate.RecoveryPointType)
                                            $rpoobj | Add-Member -MemberType NoteProperty -Name RecoveryPointTime    -Value $($recoverpointdate.RecoveryPointTime)
                                            $rpoobj | Add-Member -MemberType NoteProperty -Name ContainerName    -Value $($recoverpointdate.ContainerName)
                                            $rpoobj | Add-Member -MemberType NoteProperty -Name ContainerFriendlyname    -Value $($restorepoint.Friendlyname)

                                             [array]$rpsresults += $rpoobj
                           }

                      }

                  }

                else    
                {
                    $failedbackupiteminfo = ($restorepoint.Friendlyname).split(';')
                    $failedbackupitem =  ($failedbackupiteminfo)[-1]
                    Write-Warning " VM  $failedbackupitem does not exist, Will skip this VM , Need to restore manually in the portal" 
 
                }
             
  
}

 


$rps_selected = $rpsresults | select vmname, Location,RecoveryPointId,RecoveryPointType,RecoveryPointTime,ContainerName, ContainerFriendlyname | where vmname -ne $null | ogv -Title " Select Recover point for each :" -PassThru | select *


### Build records






########################################################
function createstorageaccount($subscriptionname, $tenantid, $vmname,$resourcegroupname, $storageaccountname, $region)
{

     write-host " $tenantid, $subscriptionname, $vmname, $resourcegroupname, $storageaccountname) " -ForegroundColor green
 
    ### end storagesub info

    set-azcontext -Subscription $subscriptionname  -Tenant  $tenantid


    $region = $($vault.location)

    $storagecontainer = ($($backupItem.Name)) -split(';') 

    $backupvmname = $storagecontainername = $storagecontainer[3]
 
    $resourcegroupname = $($vault.ResourceGroupName)


    #BEGIN Create Storage Accounts
 
    # $backupstorageaccount = Get-AzStorageAccount -ResourceGroupName $($vault.ResourceGroupName) 
 
     try
     {
         if (!(Get-AzStorageAccount -ResourceGroupName $resourcegroupname -Name $storageaccountname -erroraction silentlycontinue)   ) 
        {  
            Write-Host "Storage Account Does Not Exist, Creating Storage Account: $storageAccount Now"

            # b. Provision storage account
            New-AzStorageAccount -ResourceGroupName $resourcegroupname  -Name $storageaccountname -Location $region -AccessTier Hot -SkuName Standard_LRS   -Kind StorageV2  -Tag @{"owner" = "Jerry wolff"; "purpose" = "Az Automation storage write" } | out-null 
 
     
           Get-AzStorageAccount -Name   $storageaccountname  -ResourceGroupName  $resourcegroupname  -verbose -ErrorAction SilentlyContinue
         }
       }
       Catch
       {
             WRITE-DEBUG "Storage Account Aleady Exists, SKipping Creation of $storageAccount"
   
       } 
            $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  –StorageAccountName $storageaccountname).value | select -first 1
            $destContext = New-azStorageContext  –StorageAccountName $storageaccountname `
                                            -StorageAccountKey $StorageKey


                 ###create container for Blob

            try
                {
                      if (!(get-azstoragecontainer -Name $storagecontainer -Context $destContext) | out-null )
                         { 
                             New-azStorageContainer $storagecontainer -Context $destContext | out-null 
                            }
                 }
            catch
                 {
                    Write-Warning " $storagecontainer container already exists" 
                 }
       
 }
 


#######################################

foreach($rpitem in $rps_selected)
{

 

$vminfo   = get-azvm -Name $rpitem.VMname | select -Property *

$vmdata = ($vminfo.Id) -split('/')

$subscriptionid = $vmdata[2]

$subscriptioninfo = (get-azsubscription -Subscriptionid $subscriptionid)

$tenantid = $subscriptioninfo.TenantId

$subscriptionname = $($subscriptioninfo.Name)

$resourcegroupname = $($vminfo.ResourceGroupName)

$vmname = $($vminfo.Name)

$region = $($vminfo.Location)
 
  
 $storageaccountname = ("$resourcegroupname"+'restsa').ToLower()

 ###############################

 createstorageaccount -tenantid  $tenantid `
 -vmname $vmname `
 -resourcegroupname $resourcegroupname `
  -storageaccountname $storageaccountname `
   -subscriptionname $subscriptionname `
   -location $region

 ###########################
 
$BackupItem = Get-AzRecoveryServicesBackupItem -BackupManagementType "AzureVM" -WorkloadType "AzureVM" -Name $($rpitem.ContainerFriendlyname) -VaultId $vault.ID
 
$RP = Get-AzRecoveryServicesBackupRecoveryPoint -Item $BackupItem  -VaultId $vault.ID | where RecoveryPointId -eq $($rpitem.RecoveryPointId)

$RestoreJob = Restore-AzRecoveryServicesBackupItem -RecoveryPoint $RP[0] -TargetResourceGroupName $($vminfo.resourcegroupname) -StorageAccountName $storageaccountname -StorageAccountResourceGroupName $resourcegroupname -VaultId $vault.ID -VaultLocation $vault.Location 


$resotrestatus =  Get-AzRecoveryServicesBackupStatus -Name $($vminfo.name) -ResourceGroupName $($vminfo.resourcegroupname) -Type AzureVM
  $resotrestatus | fl *


}







