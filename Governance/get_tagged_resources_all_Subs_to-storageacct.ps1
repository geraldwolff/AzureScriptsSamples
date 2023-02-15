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

#> 
  Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'
 
try
{
    "Logging in to Azure..."
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$resourcedata  = ''

$subscriptions = get-azsubscription 

foreach($subscription in $subscriptions)
{
 
 
        set-azcontext -Subscription $subscription
          Get-azSubscription –SubscriptionName $subscription | Select-azSubscription

        #Get all ARM resources from all resource groups
        $ResourceGroups = Get-AzResourceGroup

        foreach ($ResourceGroup in $ResourceGroups)
        {    
            Write-host "Showing resources in resource group   $($ResourceGroup.ResourceGroupName)" -ForegroundColor cyan


            $Resources = Get-AzResource | ? {$_.Tags.Keys -contains "owner" -or $_.Tags.value -contains "Jerry wolff"} | select -Property *

            foreach ($Resource in $Resources)
            {

                Write-host " ($($Resource.Name) +   $($Resource.ResourceType))" -ForegroundColor green

                $resourcetype = $($resource.ResourceType) -split('/')[-1]

		         

                $resourceobj = new-object PSobject

                $resourceobj | add-member -membertype Noteproperty -name Name -Value $($resource.name)
                $resourceobj | add-member -membertype Noteproperty -name Resourcegroupname -Value $($resource.resourcegroupname)
                $resourceobj | add-member -membertype Noteproperty -name resourcetype -Value    $resourcetype
                $resourceobj | add-member -membertype Noteproperty -name Location -Value $($resource.location)



                 $Resource.Tags.GetEnumerator() | ForEach-Object {

                   #Write-Output "$($_.key)   = $($_.Value)" 
 
                 $resourceobj | add-member -membertype Noteproperty -name $($_.key) -value $($_.value)

                  }
            [array]$resourcedata += $resourceobj


            }
           
        }


}

$resourcedata




 
 $resultsfilename1 = "TaggedResourcereport.csv"

 



 $resourcedata  | export-csv $resultsfilename1  -NoTypeInformation   

 

 
# end vmss data 


##### storage subinfo

$Region =  "West US"

 $subscriptionselected = 'msushpc2022'



$resourcegroupname = 'wolffautorg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = 'wolffgovernancesa'
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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename1  -File $resultsfilename1 -Context $destContext -Force
 
 
 
     
 
































