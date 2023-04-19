
<#
.SYNOPSIS  
 Wrapper script for automation_automation_get_Usage_stats_CPU_Network_Timespan_stop_unused_vm .ps1  -days
.DESCRIPTION  
Script to collect usage data over period of time to identify CPU and Network traffic adn stop inactive VMs based on days number
.EXAMPLE  
automation_automation_get_Usage_stats_CPU_Network_Timespan_stop_unused_vm .ps1  -days
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

    sampled part of code from https://rozemuller.com/avd-automation-cocktail-avd-automated-with-powershell/#avd-sessionhosts

#> 


 

'Az.DesktopVirtualization','az.avd' | foreach-object {

install-module -name $_ -allowclobber
import-module -name $_ -force
}


param(

[String]$minimumSessions = $(throw "Value for Miimum number of sessions is incorrect or missing - use interger"),
[String]$subscription = $(throw "Value subscription name is missing"),
[String]$Resourcegroupname = $(throw "Value subscription name is missing"),
 [String]$location = $(throw "Value location/region is missing")
)



try
{
    "Logging in to Azure..."
    Connect-AzAccount   -Identity
  Connect-AzAccount    -Environment AzureUSGovernment

}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

 
 
     $subscription = Get-AzSubscription  -SubscriptionName $subscription
       set-azcontext -Subscription $subscription
      $context = get-azcontext
       $context


  #########################################      
 

  $keyvault = get-AzKeyVault -Name avdkeyvault   
      $secretname = "avdadmin"
 

$secret = get-AzKeyVaultSecret -VaultName $keyvault.VaultName -Name   $secretname

#########################
$hostpoolParameters = @{
    Name = "CoconutBeach-Hostpool"
    Description = "A nice coconut on a sunny beach"
    ResourceGroupName = $resourceGroupName
    Location = $location
    HostpoolType = "Pooled"
    LoadBalancerType = "BreadthFirst"
    preferredAppGroupType = "Desktop"
    ValidationEnvironment = $true
    StartVMOnConnect = $true
}
$avdHostpool = New-AzWvdHostPool @hostpoolParameters



########################

$sessionHostCount = 5
$initialNumber = 1
$VMLocalAdminUser = "avdadmin"
$VMLocalAdminSecurePassword = ConvertTo-SecureString (Get-AzKeyVaultSecret -VaultName $keyVault.Vaultname -Name $secret.Name ) -AsPlainText -Force
$avdPrefix = "AVD"
$VMSize = "Standard_D2s_v3"
$DiskSizeGB = 1028
$domainUser = "avdadmin@domain.local"
$domain = $domainUser.Split("@")[-1]
$ouPath = "OU=Computers,OU=AVD,DC=domain,DC=local"

$registrationToken = Update-AvdRegistrationToken -HostpoolName $avdHostpool.name   
#$moduleLocation = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration.zip"


Do {
    $VMName = $avdPrefix+"$initialNumber"
    $ComputerName = $VMName
    $nicName = "nic-$vmName"
    $NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $location -SubnetId ($virtualNetwork.Subnets | Where { $_.Name -eq "avdSubnet" }).Id
    $Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

    $VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
    $VirtualMachine = Set-AzVMOSDisk -Windows -VM $VirtualMachine -CreateOption FromImage -DiskSizeInGB $DiskSizeGB
    $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -Id $imageVersion.id

    $sessionHost = New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine

        $domainJoinSettings = @{
        Name                   = "joindomain"
        Type                   = "JsonADDomainExtension" 
        Publisher              = "Microsoft.Compute"
        typeHandlerVersion     = "1.3"
        SettingString          = '{
            "name": "'+ $($domain) + '",
            "ouPath": "'+ $($ouPath) + '",
            "user": "'+ $($domainUser) + '",
            "restart": "'+ $true + '",
            "options": 3
        }'
        ProtectedSettingString = '{
            "password":"' + $(Get-AzKeyVaultSecret -VaultName $keyVault.Vaultname -Name $secret.Name -AsPlainText) + '"}'
        VMName                 = $VMName
        ResourceGroupName      = $resourceGroupName
        location               = $Location
    }
    Set-AzVMExtension @domainJoinSettings


    $avdDscSettings = @{
        Name               = "Microsoft.PowerShell.DSC"
        Type               = "DSC" 
        Publisher          = "Microsoft.Powershell"
        typeHandlerVersion = "2.73"
        SettingString      = "{
            ""modulesUrl"":'$avdModuleLocation',
            ""ConfigurationFunction"":""Configuration.ps1\\AddSessionHost"",
            ""Properties"": {
                ""hostPoolName"": ""$($fileParameters.avdSettings.avdHostpool.Name)"",
                ""registrationInfoToken"": ""$($registrationToken.token)"",
                ""aadJoin"": true
            }
        }"
        VMName             = $VMName
        ResourceGroupName  = $resourceGroupName
        location           = $Location
    }
    Set-AzVMExtension @avdDscSettings


    $initialNumber++
    $sessionHostCount--
    Write-Output "$VMName deployed"
}
while ($sessionHostCount -ge $minimumSessions) {
    Write-Verbose "Session hosts are created"

    }
 


 $loganalyticsParameters = @{
    Location = $Location 
    Name = "loganalyticsavd" + (Get-Random -Maximum 999)
    Sku = "Standard" 
    ResourceGroupName = $resourceGroupName
}


$laws = New-AzOperationalInsightsWorkspace @loganalyticsParameters

$diagnosticsParameters = @{
    Name = "AVD-Diagnostics"
    ResourceId = $avdHostpool.id
    WorkspaceId = $laws.ResourceId
    Enabled = $true
    Category = @("Checkpoint","Error","Management","Connection","HostRegistration")
}

$avdDiagnotics = Set-AzDiagnosticSetting  @diagnosticsParameters



