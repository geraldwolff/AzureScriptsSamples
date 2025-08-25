
Connect-AzAccount

import-module Az.ConnectedMachine 

$subscriptions = Get-AzSubscription -SubscriptionName wolffentpsub



$archybridvmstatus = ''



foreach ($subscription in $subscriptions)
{
    # Select a subscription
    Set-AzContext -SubscriptionId $($subscription.id) 
       
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
            $arcvmobj  | Add-Member -MemberType NoteProperty -name MssqlDiscovered -value $($resource.MssqlDiscovered)
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

        [array]$archybridvmstatus += $arcvmobj 
    }
}



$archybridvmstatus





