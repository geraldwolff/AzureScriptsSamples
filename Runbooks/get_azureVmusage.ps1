try
{
    "Logging in to Azure..."
    Connect-AzAccount -Identity
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
            
             [array]$quotalist += $quotaobj
         }
    }

 }

 $quotalist | Where-object {$_.currentvalue -ne 0 } | select name, Currentvalue, Limit, Unit, Location | ft -auto

 
 $resultsfilename = "vmquotausage.csv"

 $quotalist | Where-object {$_.currentvalue -ne 0 } | select name, Currentvalue, Limit, Unit, Location  | export-csv $resultsfilename  -NoTypeInformation  

##### storage subinfo

$Region = "<location>"

 $subscriptionselected = '<subscription>'



$resourcegroupname = '<Resourcegroup>'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = '<storageaccount>'
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
        
 
