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

  $erroractionpreference = 'silentlycontinue'

 ######################33
 ##  Necessary Modules to be imported.

import-module Az.Compute -force 

 ############
 ## connect to Azure with authorized credentials 
 
 Connect-AzAccount



$skuavaiability_chart = ''
$Available_Sizes = ''

$locations  = Get-azLocation | `
select displayname  



$Available_resourceskus  = Get-AzComputeResourceSku  

foreach($locname in $locations){
[array]$Available_Sizes += Get-AZVMSize -Location $($locname.DisplayName)  | select *

}


#### Source data fields

<#
ResourceType : virtualMachines
Name         : Standard_E16bs_v5
Tier         : Standard
Size         : E16bs_v5
Family       : standardEBSv5Family
Kind         : 
Capacity     : 
Locations    : {westus}
LocationInfo : {Microsoft.Azure.Management.Compute.Models.ResourceSkuLocationInfo}
ApiVersions  : {}
Costs        : {}
Capabilities : {MaxResourceVolumeMB, OSVhdSizeMB, vCPUs, MemoryPreservingMaintenanceSupported...}
Restrictions : {}
#>

<#

MaxDataDiskCount     : 32
MemoryInMB           : 131072
Name                 : Standard_E16-4s_v3
NumberOfCores        : 16
OSDiskSizeInMB       : 1047552
ResourceDiskSizeInMB : 262144
RequestId            : 09d2fa0e-5e34-45e7-bef5-29c5c2ce8940
StatusCode           : OK

#>

foreach ($Available_resourcesku in $Available_resourceskus)
{
    foreach($Available_Size in $Available_Sizes | where-object {$_.name -eq $($Available_resourcesku.Name) } )
    {
        
        $regionalSkuStatusobj = new-object PSObject 


        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name  ResourceType     -Value   $($Available_resourcesku.ResourceType)
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name  Name     -Value   $($Available_resourcesku.Name)
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Tier      -Value   $($Available_resourcesku.Tier)
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Size      -Value   $($Available_resourcesku.Size)
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Family      -Value   $($Available_resourcesku.Family)
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Kind      -Value   $($Available_resourcesku.Kind)
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Capacity      -Value   $($Available_resourcesku.Capacity)
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Locations      -Value   $($Available_resourcesku.Locations)
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name LocationInfo      -Value   $($Available_resourcesku.LocationInfo.Capacity)
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name ApiVersions      -Value   $($Available_resourcesku.ApiVersions)
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Costs      -Value   $($Available_resourcesku.Costs)
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Capabilities      -Value $($Available_resourcesku.Capabilities.Capacity)
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Restrictions      -Value ($($Available_resourcesku.Restrictions).reasoncode  | select -first 1)
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name SizeMaxDataDiskCount      -Value $( $Available_Size.MaxDataDiskCount)  
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name MemoryInMB      -Value $( $Available_Size.MemoryInMB)  
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name SKUName      -Value  $($Available_Size.name) 
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name NumberOfCores      -Value   $( $Available_Size.NumberOfCores)
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name OSDiskSizeInMB      -Value   $( $Available_Size.OSDiskSizeInMB)
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name ResourceDiskSizeInMB      -Value  $($Available_Size.ResourceDiskSizeInMB)  
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name RequestId      -Value    $($Available_Size.RequestId) 
        $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name StatusCode      -Value    $($Available_Size.StatusCode) 
 
                                                            
        [array]$skuavaiability_chart += $regionalSkuStatusobj    


    }



}                       


 $resultsfilename = 'azurevmskuavailability.csv'
 
 

 $skuavaiability_chart  | Select Locations, ResourceType,  Tier, Size,Family ,Kind, Capacity,  LocationInfo,  ApiVersions,   Costs,  Capabilities, Restrictions ,MaxDataDiskCount, MemoryInMB, `
  Name, NumberOfCores, OSDiskSizeInMB , ResourceDiskSizeInMB, RequestId, StatusCode | `
export-csv $resultsfilename -NoTypeInformation 

 
 $Region =  "West US"

 $subscriptionselected = 'wolffentpSub'



$resourcegroupname = 'wolffautomationrg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = 'wolffautosa'
$storagecontainer = 'azurevmavailability'


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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename  -File $resultsfilename -Context $destContext -Force
 
 





