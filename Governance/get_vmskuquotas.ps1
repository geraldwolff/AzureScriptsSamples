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

    Script Name: get_vmskuquotas.ps1
    Description: Custom script collect Subscription quota counts 
    NOTE:   Scripts creates resourcegroup, storage account, containers and csv files loaded to storage account

#> 

####### Suppress powershell module changes warning during execution 

  Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'




try
{
    "Logging in to Azure..."
    Connect-AzAccount # -Environment AzureUSGovernment    #-Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}
$ErrorActionPreference = 'silentlyContinue'


 $subscriptions = Get-azSubscription  

set-azcontext -Subscription $subscription

 $quotalist = ''

 foreach($sub in $subscriptions)
 {
    Set-azcontext -Subscription $sub.Name

    $locations = Get-AzLocation

    foreach($loc in $locations)
       {

          #  write-host " $($sub.Subscription.Name) - Quota usage - $LOCATION" -FOREGROUNDCOLOR RED

      $quota =      get-azvmusage -location $loc.DisplayName  

      foreach($quotaitem in $quota)
      {
            
            $quotaobj = new-object PSobject 

            
            $quotaobj | Add-Member -MemberType NoteProperty -Name  Name -Value $($quotaitem.name).LocalizedValue
            $quotaobj | Add-Member -MemberType NoteProperty -Name  Currentvalue -Value $($quotaitem.Currentvalue)
            $quotaobj | Add-Member -MemberType NoteProperty -Name  Limit -Value $($quotaitem.Limit)
            $quotaobj | Add-Member -MemberType NoteProperty -Name  Unit -Value $($quotaitem.Unit)
            $quotaobj | Add-Member -MemberType NoteProperty -Name  Location -Value $($loc.DisplayName)
            $quotaobj | Add-Member -MemberType NoteProperty -Name  Subscription -Value $($sub.name)
                       
             [array]$quotalist += $quotaobj
         }
    }

 }

#$quotalist | Where-object {$_.currentvalue -ne 0 } | select name, Currentvalue, Limit, Unit, Location, subscription | ft -auto

 
 $resultsfilename = "vmquotausage.csv"

 $quotalist| Where-object {$_.currentvalue -ne 0 } | select name, Currentvalue, Limit, Unit, Location , subscription | export-csv $resultsfilename  -NoTypeInformation  

##### storage subinfo

$Region = "West US"

 $subscriptionselected = '<Subscription>'



$resourcegroupname = '>resourcegroupname>'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = '<storageaccountname>'
$storagecontainer = 'vmquotausage'
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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename  -File $resultsfilename -Context $destContext -force
        
 
