
Connect-AzAccount

import-module Az.ConnectedMachine 

$subscriptions = Get-AzSubscription -SubscriptionName wolffentpsub



$azarchybridstatus = ''



foreach ($subscription in $subscriptions)
{
    # Select a subscription
    Set-AzContext -SubscriptionId $($subscription.id) 


 #       $vmList = Get-AzResource -ResourceType Microsoft.HybridCompute/machines -ExpandProperties #| Where-Object {$_.Properties.osType -eq "hybrid"} | ForEach-Object {
      
     $resources = (Get-AzConnectedMachine) | Select *

    foreach($resource in $resources)
    {
          $vmName = $resource.Name

           $arcvmobj = new-object PSobject

            $arcvmobj  | Add-Member -MemberType NoteProperty -name AdFqdn -value $($resource.AdFqdn)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name AgentConfigurationConfigMode -value $($resource.AgentConfigurationConfigMode)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name AgentConfigurationExtensionsAllowList -value $($resource.AgentConfigurationExtensionsAllowList)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name AgentConfigurationExtensionsBlockList -value $($resource.AgentConfigurationExtensionsBlockList)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name AgentConfigurationExtensionsEnabled -value $($resource.AgentConfigurationExtensionsEnabled)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name AgentConfigurationGuestConfigurationEnabled -value $($resource.AgentConfigurationGuestConfigurationEnabled)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name AgentConfigurationIncomingConnectionsPort -value $($resource.AgentConfigurationIncomingConnectionsPort)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name AgentConfigurationProxyBypass -value $($resource.AgentConfigurationProxyBypass)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name AgentConfigurationProxyUrl -value $($resource.AgentConfigurationProxyUrl)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name AgentUpgradeCorrelationId -value $($resource.AgentUpgradeCorrelationId)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name AgentUpgradeDesiredVersion -value $($resource.AgentUpgradeDesiredVersion)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name AgentUpgradeEnableAutomaticUpgrade -value $($resource.AgentUpgradeEnableAutomaticUpgrade)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name AgentUpgradeLastAttemptMessage -value $($resource.AgentUpgradeLastAttemptMessage)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name AgentUpgradeLastAttemptStatus -value $($resource.AgentUpgradeLastAttemptStatus)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name AgentUpgradeLastAttemptTimestamp -value $($resource.AgentUpgradeLastAttemptTimestamp)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name AgentVersion -value $($resource.AgentVersion)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name ClientPublicKey -value $($resource.ClientPublicKey)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name CloudMetadataProvider -value $($resource.CloudMetadataProvider)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name DetectedProperty -value $($resource.DetectedProperty)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name DisplayName -value $($resource.DisplayName)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name DnsFqdn -value $($resource.DnsFqdn)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name DomainName -value $($resource.DomainName)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name ErrorDetail -value $($resource.ErrorDetail)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name Extension -value $($resource.Extension)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name ExtensionServiceStartupType -value $($resource.ExtensionServiceStartupType)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name ExtensionServiceStatus -value $($resource.ExtensionServiceStatus)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name Fqdn -value $($resource.Fqdn)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name GuestConfigurationServiceStartupType -value $($resource.GuestConfigurationServiceStartupType)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name GuestConfigurationServiceStatus -value $($resource.GuestConfigurationServiceStatus)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name Id -value $($resource.Id)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name IdentityPrincipalId -value $($resource.IdentityPrincipalId)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name IdentityTenantId -value $($resource.IdentityTenantId)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name IdentityType -value $($resource.IdentityType)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name LastStatusChange -value $($resource.LastStatusChange)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name LinuxConfigurationPatchSettingsAssessmentMode -value $($resource.LinuxConfigurationPatchSettingsAssessmentMode)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name LinuxConfigurationPatchSettingsPatchMode -value $($resource.LinuxConfigurationPatchSettingsPatchMode)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name Location -value $($resource.Location)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name LocationDataCity -value $($resource.LocationDataCity)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name LocationDataCountryOrRegion -value $($resource.LocationDataCountryOrRegion)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name LocationDataDistrict -value $($resource.LocationDataDistrict)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name LocationDataName -value $($resource.LocationDataName)
      #      $arcvmobj  | Add-Member -MemberType NoteProperty -name MssqlDiscovered -value $($resource.MssqlDiscovered)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name Name -value $($resource.Name)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name OSName -value $($resource.OSName)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name OSProfileComputerName -value $($resource.OSProfileComputerName)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name OSSku -value $($resource.OSSku)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name OSType -value $($resource.OSType)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name OSVersion -value $($resource.OSVersion)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name ParentClusterResourceId -value $($resource.ParentClusterResourceId)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name PrivateLinkScopeResourceId -value $($resource.PrivateLinkScopeResourceId)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name ProvisioningState -value $($resource.ProvisioningState)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name Resource -value $($resource.Resource)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name ResourceGroupName -value $($resource.ResourceGroupName)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name Status -value $($resource.Status)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name SystemData -value $($resource.SystemData)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name SystemDataCreatedAt -value $($resource.SystemDataCreatedAt)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name SystemDataCreatedBy -value $($resource.SystemDataCreatedBy)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name SystemDataCreatedByType -value $($resource.SystemDataCreatedByType)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name SystemDataLastModifiedAt -value $($resource.SystemDataLastModifiedAt)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name SystemDataLastModifiedBy -value $($resource.SystemDataLastModifiedBy)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name SystemDataLastModifiedByType -value $($resource.SystemDataLastModifiedByType)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name Tag -value $($resource.Tag)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name Type -value $($resource.Type)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name VMId -value $($resource.VMId)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name VMUuid -value $($resource.VMUuid)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name WindowsConfigurationPatchSettingsAssessmentMode -value $($resource.WindowsConfigurationPatchSettingsAssessmentMode)
            $arcvmobj  | Add-Member -MemberType NoteProperty -name WindowsConfigurationPatchSettingsPatchMode -value $($resource.WindowsConfigurationPatchSettingsPatchMode)

        ($resource.DetectedProperty.AdditionalProperties).GetEnumerator() | ForEach-Object {

                $arcvmobj  | Add-Member -MemberType NoteProperty -name $($_.key) -value $($_.value)

        }

        [array]$azarchybridstatus += $arcvmobj 
    }
}






 $date = $(Get-Date -Format 'dd MMMM yyyy' )
 
    $CSS = @"
<Title> Azure Recovery services Storage Report: $date </Title>
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


 

 
 $azarconnecteddata = ($azarchybridstatus | Select AdFqdn, `
AgentConfigurationConfigMode,`
AgentConfigurationExtensionsAllowList,`
AgentConfigurationExtensionsBlockList,`
AgentConfigurationExtensionsEnabled,`
AgentConfigurationGuestConfigurationEnabled,`
AgentConfigurationIncomingConnectionsPort,`
AgentConfigurationProxyBypass,`
AgentConfigurationProxyUrl,`
AgentUpgradeCorrelationId,`
AgentUpgradeDesiredVersion,`
AgentUpgradeEnableAutomaticUpgrade,`
AgentUpgradeLastAttemptMessage,`
AgentUpgradeLastAttemptStatus,`
AgentUpgradeLastAttemptTimestamp,`
AgentVersion,`
ClientPublicKey,`
CloudMetadataProvider,`
DetectedProperty,`
DisplayName,`
DnsFqdn,`
DomainName,`
ErrorDetail,`
Extension,`
ExtensionServiceStartupType,`
ExtensionServiceStatus,`
Fqdn,`
GuestConfigurationServiceStartupType,`
GuestConfigurationServiceStatus,`
Id,`
IdentityPrincipalId,`
IdentityTenantId,`
IdentityType,`
LastStatusChange,`
LinuxConfigurationPatchSettingsAssessmentMode,`
LinuxConfigurationPatchSettingsPatchMode,`
Location,`
LocationDataCity,`
LocationDataCountryOrRegion,`
LocationDataDistrict,`
LocationDataName,`
Name,`
OSName,`
OSProfileComputerName,`
OSSku,`
OSType,`
OSVersion,`
ParentClusterResourceId,`
PrivateLinkScopeResourceId,`
ProvisioningState,`
Resource,`
ResourceGroupName,`
Status,`
SystemData,`
SystemDataCreatedAt,`
SystemDataCreatedBy,`
SystemDataCreatedByType,`
SystemDataLastModifiedAt,`
SystemDataLastModifiedBy,`
SystemDataLastModifiedByType,`
Tag,`
Type,`
VMId,`
VMUuid,`
WindowsConfigurationPatchSettingsAssessmentMode,`
WindowsConfigurationPatchSettingsPatchMode,`
cloudprovider,`
coreCount,`
logicalCoreCount,`
manufacturer,`
model,`
mssqldiscovered,`
processorCount,`
processorNames,`
productType,`
serialNumber,`
smbiosAssetTag,`
totalPhysicalMemoryInBytes,`
totalPhysicalMemoryInGigabytes   | ConvertTo-Html -Head $CSS )  | out-file "c:\temp\azarcconnectedreport.html" 

invoke-item "c:\temp\azarcconnectedreport.html" 



#####################################################################################
 ######### Uncomment and configure to send results to storage account blob 


 
 $date = $(Get-Date -Format 'dd MMMM yyyy' )
 
########### Prepare for storage account export

 $resultsfilename = "azarcconnectedreport.csv"



$csvresults = ($azarchybridstatus   | Select  AdFqdn,`
AgentConfigurationConfigMode,`
AgentConfigurationExtensionsAllowList,`
AgentConfigurationExtensionsBlockList,`
AgentConfigurationExtensionsEnabled,`
AgentConfigurationGuestConfigurationEnabled,`
AgentConfigurationIncomingConnectionsPort,`
AgentConfigurationProxyBypass,`
AgentConfigurationProxyUrl,`
AgentUpgradeCorrelationId,`
AgentUpgradeDesiredVersion,`
AgentUpgradeEnableAutomaticUpgrade,`
AgentUpgradeLastAttemptMessage,`
AgentUpgradeLastAttemptStatus,`
AgentUpgradeLastAttemptTimestamp,`
AgentVersion,`
ClientPublicKey,`
CloudMetadataProvider,`
DetectedProperty,`
DisplayName,`
DnsFqdn,`
DomainName,`
ErrorDetail,`
Extension,`
ExtensionServiceStartupType,`
ExtensionServiceStatus,`
Fqdn,`
GuestConfigurationServiceStartupType,`
GuestConfigurationServiceStatus,`
Id,`
IdentityPrincipalId,`
IdentityTenantId,`
IdentityType,`
LastStatusChange,`
LinuxConfigurationPatchSettingsAssessmentMode,`
LinuxConfigurationPatchSettingsPatchMode,`
Location,`
LocationDataCity,`
LocationDataCountryOrRegion,`
LocationDataDistrict,`
LocationDataName,`
Name,`
OSName,`
OSProfileComputerName,`
OSSku,`
OSType,`
OSVersion,`
ParentClusterResourceId,`
PrivateLinkScopeResourceId,`
ProvisioningState,`
Resource,`
ResourceGroupName,`
Status,`
SystemData,`
SystemDataCreatedAt,`
SystemDataCreatedBy,`
SystemDataCreatedByType,`
SystemDataLastModifiedAt,`
SystemDataLastModifiedBy,`
SystemDataLastModifiedByType,`
Tag,`
Type,`
VMId,`
VMUuid,`
WindowsConfigurationPatchSettingsAssessmentMode,`
WindowsConfigurationPatchSettingsPatchMode,`
cloudprovider,`
coreCount,`
logicalCoreCount,`
manufacturer,`
model,`
mssqldiscovered,`
processorCount,`
processorNames,`
productType,`
serialNumber,`
smbiosAssetTag,`
totalPhysicalMemoryInBytes,`
totalPhysicalMemoryInGigabytes   )| export-csv $resultsfilename -notypeinformation 



  

# end vmss data 


##### storage subinfo

$Region = "westus"
 $date = Get-Date -Format MMddyyyy
 $subscriptionselected = 'wolffentpsub'



$resourcegroupname = 'wolffautomationrg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | select tenantid
$storageaccountname = 'wolffautosa'
$storagecontainer = 'azarcconnectedreport'
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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename  -File $resultsfilename -Context $destContext -FORCE
        
        
 


