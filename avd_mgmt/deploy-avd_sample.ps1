
<#
.SYNOPSIS  
 Wrapper script for \automation_deploy-avd_sample.ps1
.DESCRIPTION  
Script to collect usage data over period of time to identify CPU and Network traffic adn stop inactive VMs based on days number
.EXAMPLE  
automation_deploy-avd_sample.ps1
for all hostpools uncomment hospootname in parameter
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



 'Az.DesktopVirtualization', 'Az.Network','Az.Resources','Az.Compute','Az.Avd', 'Az.Compute', 'Az.Network' | foreach-object  {

    install-module -name $_ -allowclobber -Force
    import-module -name $_ -force 

    }


try
{
    "Logging in to Azure..."
  #  Connect-AzAccount   -Identity
  Connect-AzAccount    -Environment AzureUSGovernment

}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}



 $subscriptiontarget = '<subscription>'


     $subscription = Get-AzSubscription  -SubscriptionName $subscriptiontarget
      set-azcontext -Subscription $subscription -Tenant $subscription.TenantId 
      $context = get-azcontext
       $context

$resourceGroupName = "contosogovavdrg"
$location = "USGov Arizona"

sl 'C:\Users\jerrycontoso\OneDrive - Microsoft\Documents\azure\PS1\avd_mgmt'

$parameters = @{
    ResourceGroup = $resourceGroupName
    Location      = $location
}
New-AzResourceGroup @parameters

$nsgParameters = @{
    ResourceGroupName = $resourceGroupName 
    Location          = $location 
    Name              = "nsg-contoso"
}
$networkSecurityGroup = New-AzNetworkSecurityGroup @nsgParameters

$subnetParameters = @{
    defaultSubnet = "10.0.1.0/24"
    avdSubnet     = "10.0.2.0/24"
}

$subnets = $subnetParameters.GetEnumerator().ForEach( {
        New-AzVirtualNetworkSubnetConfig -Name $_.Name -AddressPrefix $_.Value -NetworkSecurityGroup $networkSecurityGroup
    })

$vnetParameters = @{
    name              = "vnetcontosoavd"
    ResourceGroupName = $resourceGroupName
    Location          = $location
    AddressPrefix     = "10.0.0.0/16" 
    Subnet            = $subnets
    DnsServer         = "10.3.1.4"
}
$virtualNetwork = New-AzVirtualNetwork @vnetParameters 


$galleryParameters = @{
    GalleryName       = "contosoavdGallery"
    ResourceGroupName = $resourceGroupName
    Location          = $location
    Description       = "Shared Image Gallery for my avd gov"
}

$gallery = New-AzGallery @galleryParameters

$galleryContributor = New-AzAdGroup -DisplayName "Gallery Contributor" -MailNickname "GalleryContributor" -Description "This group had shared image gallery contributor permissions"

$galleryRoleParameters = @{
    ObjectId           = $GalleryContributor.Id
    RoleDefinitionName = "contributor"
    ResourceName       = $gallery.Name
    ResourceType       = "Microsoft.Compute/galleries" 
    ResourceGroupName  = $gallery.ResourceGroupName
}

New-AzRoleAssignment @galleryRoleParameters

get-AzRoleAssignment -ObjectId $GalleryContributor.Id -ResourceGroupName $gallery.ResourceGroupName -ResourceName $gallery.Name -ResourceType "Microsoft.Compute/galleries"


$imageDefinitionParameters = @{
    GalleryName       = $gallery.Name
    ResourceGroupName = $gallery.ResourceGroupName
    Location          = $gallery.Location
    Name              = "contosoDefinition"
    OsState           = "Generalized"
    OsType            = "Windows"
    Publisher         = "contoso"
    Offer             = "windows-11"
    Sku               = "win11-21h2-avd"
    HyperVGeneration  = "V2"
}
$imageDefinition = New-AzGalleryImageDefinition @imageDefinitionParameters


$VMcontosogovadmin = "contosogovadmin"
$VMLocalPassword = "Letmeinnow1!"
$VMLocalAdminSecurePassword = ConvertTo-SecureString $VMLocalPassword -AsPlainText -Force

$VMName = "contosoavdvm"
$VMSize = "Standard_D2s_v3"
$ImageSku = "win11-21h2-avd"
$ImageOffer = "windows-11"
$ImagePublisher = "MicrosoftWindowsDesktop"
$ComputerName = $VMName
$DiskSizeGB = 1024
$nicName = "nic-$vmName"

$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $location -SubnetId ($virtualNetwork.Subnets | Where { $_.Name -eq "avdSubnet" }).Id
$Credential = New-Object System.Management.Automation.PSCredential ($VMcontosogovadmin, $VMLocalAdminSecurePassword);

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMOSDisk -Windows -VM $VirtualMachine -CreateOption FromImage -DiskSizeInGB $DiskSizeGB
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName $ImagePublisher -Offer $ImageOffer -Skus $ImageSku -Version latest

$initialVM = New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine

$content = 
@"
    param (
        `$sysprep,
        `$arg
    )
    Start-Process -FilePath `$sysprep -ArgumentList `$arg -Wait
"@

Set-Content -Path .\sysprep.ps1 -Value $content
$vm = Get-AzVM -Name $VMName
$vm | Invoke-AzVMRunCommand -CommandId "RunPowerShellScript" -ScriptPath .\sysprep.ps1 -Parameter @{sysprep = "C:\Windows\System32\Sysprep\Sysprep.exe"; arg = "/generalize /oobe /shutdown /quiet /mode:vm" }

$vm | Set-AzVm -Generalized

$imageVersionParameters = @{
    GalleryImageDefinitionName = $imageDefinition.Name
    GalleryImageVersionName    = (Get-Date -f "yyyy.MM.dd")
    GalleryName                = $gallery.Name
    ResourceGroupName          = $gallery.ResourceGroupName
    Location                   = $gallery.Location
    SourceImageId              = $vm.id.ToString()
}
$imageVersion = New-AzGalleryImageVersion @imageVersionParameters

$JsonParameters = Get-Content .\Parameters\avd-environment.json | ConvertFrom-Json

$hostpoolParameters = @{
    Name                  = "contosoavdHostpool"
    Description           = "AVDhostpool avd"
    ResourceGroupName     = $resourceGroupName
    Location              = $location
    HostpoolType          = "Pooled"
    LoadBalancerType      = "BreadthFirst"
    preferredAppGroupType = "Desktop"
    ValidationEnvironment = $true
    StartVMOnConnect      = $true
}

$avdHostpool = New-AzWvdHostPool @hostpoolParameters

$roleass = get-AzRoleAssignment -ObjectId $GalleryContributor.Id -ResourceGroupName $gallery.ResourceGroupName -ResourceName $gallery.Name -ResourceType "Microsoft.Compute/galleries"

$startVmParameters = @{
    HostpoolName      = $avdHostpool.Name
    ResourceGroupName = $hostpoolParameters.resourceGroupName
    HostsResourceGroup = $hostpoolParameters.resourceGroupName
    Rolename =  $roleass.SignInName
}

#$startVmOnConnect = Enable-AvdStartVmOnConnect @startVmParameters

$applicationGroupParameters = @{
    ResourceGroupName    = $ResourceGroupName
    Name                 = "contosoavdApplications-dac"
    Location             = $location
    FriendlyName         = "Applications on the avd"
    Description          = "From the contoso avd deployment"
    HostPoolArmPath      = $avdHostpool.Id
    ApplicationGroupType = "Desktop"
}

$applicationGroup = New-AzWvdApplicationGroup @applicationGroupParameters

$workSpaceParameters = @{
    ResourceGroupName         = $ResourceGroupName
    Name                      = "contosogovWorkspace"
    Location                  = $location
    FriendlyName              = "The gov workspace"
    ApplicationGroupReference = $applicationGroup.Id
    Description               = "This is the workspace"
}

$workSpace = New-AzWvdWorkspace @workSpaceParameters

$keyVaultParameters = @{
    Name              = "contosoavdkeyvault"
    ResourceGroupName = $resourceGroupName
    Location          = $location
}

$keyVault = New-AzKeyVault @keyVaultParameters

$secretParameters = @{
    VaultName   = $keyVault.VaultName
    Name        = "contosogovsvcPassword"
    SecretValue = ConvertTo-SecureString -String "Letmeinnow1!" -AsPlainText -Force
}

$secret = Set-AzKeyVaultSecret @secretParameters

$sessionHostCount = 3
$initialNumber = 0
$VMcontosogovadmin = "contosogovadmin"
[securestring]$domainPassword = ConvertTo-SecureString (Get-AzKeyVaultSecret -VaultName $keyVault.Vaultname -Name $secret.Name -AsPlainText ) -AsPlainText -Force
$avdPrefix = "avdac"
$VMSize = "Standard_D2s_v3"
$DiskSizeGB = 1024
$domainUser = "contosogovsvc@contosogov.com"
$domain = $domainUser.Split("@")[-1]
$ouPath = "OU=Computers,OU=WVD,DC=contosogov,DC=com"

$registrationToken = Update-AvdRegistrationToken -HostpoolName $avdHostpool.name $resourceGroupName
$moduleLocation = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration.zip"

Do {
    $VMName = $avdPrefix + "$initialNumber"
    $ComputerName = $VMName
    $nicName = "nic-$vmName"
    $NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $location -SubnetId ($virtualNetwork.Subnets | Where { $_.Name -eq "avdSubnet" }).Id
    [pscredential]$Credential = New-Object System.Management.Automation.PSCredential ($VMcontosogovadmin, $domainPassword)

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
while ($sessionHostCount -ne 0) {
    Write-Verbose "Session hosts are created"
}


$loganalyticsParameters = @{
    Location = $Location 
    Name = "loganalyticsavd1"  
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
