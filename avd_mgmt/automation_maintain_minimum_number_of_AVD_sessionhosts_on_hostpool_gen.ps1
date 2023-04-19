
<#
.SYNOPSIS  
 Wrapper script for \automation_maintain_minimum_number_of_AVD_sessionhosts.ps1
.DESCRIPTION  
Script to collect usage data over period of time to identify CPU and Network traffic adn stop inactive VMs based on days number
.EXAMPLE  
automation_maintain_minimum_number_of_AVD_sessionhosts.ps1 -minimumSessions nn -subscription <xxxxx> -Resourcegroupname <xxxxxxxxxxx> -location <xxxxxxxxxx> -Hostpoolname <xxxxxxxxxxx> -vnet <namexxxxx>
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


param(

[String]$minimumSessions = $(throw "Value for Miimum number of sessions is incorrect or missing - use integer"),
[String]$subscription = $(throw "Value subscription name is missing"),
[String]$Resourcegroupname = $(throw "Value subscription name is missing"),
[String]$location = $(throw "Value location/region is missing") ,
[String]$vnet = $(throw "Value VNET is missing")  ,
[String]$Hostpoolname = $(throw "Value Hostpoolname is missing")
)

 'Az.DesktopVirtualization', 'Az.Network','Az.Resources','Az.Compute','Az.Avd', 'Az.Compute', 'Az.Network' | foreach-object  {

    install-module -name $_ -allowclobber
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

 ######################*********************#####################
 $minimumSessions = 10
 $subscription = '<subscription>'
 $resourcegroupname = 'lobogovavdrg'
 $location = 'usgovarizona'
 $vnet = 'lobogovvnet'
 $Hostpoolname = 'lobogovavdhp2'
 ######################*********************#####################


     $subscription = Get-AzSubscription  -SubscriptionName $subscription
      set-azcontext -Subscription $subscription -Tenant $subscription.TenantId 
      $context = get-azcontext
       $context


  #########################################   
  $galleryParameters = @{
    GalleryName = "lobogovazgallery"
    ResourceGroupName = $resourceGroupName
    Location = $location
    Description = "Shared Image Gallery foraz gov"
}
$gallery = New-AzGallery @galleryParameters

     
 $GalleryContributor = New-AzAdGroup -DisplayName "Gallery Contributor" -MailNickname "GalleryContributor" -Description "This group had shared image gallery contributor permissions"

    $galleryRoleParameters = @{
        ObjectId = $GalleryContributor.Id
        RoleDefinitionName = "contributor"
        ResourceName = $gallery.Name
        ResourceType = "Microsoft.Compute/galleries" 
        ResourceGroupName = $gallery.ResourceGroupName
    }

    New-AzRoleAssignment @galleryRoleParameters

##################### 

     $imageDefinitionParameters = @{
        GalleryName = $gallery.Name
        ResourceGroupName = $gallery.ResourceGroupName
        Location = $gallery.Location
        Name = "lobogovavddefinition"
        OsState = "Generalized"
        OsType = "Windows"
        publisher = "MicrosoftWindowsDesktop"
        Offer = "windows-11"
        Sku =  "win11-21h2-avd"
        HyperVGeneration= "V2"
    }
    $imageDefinition = New-AzGalleryImageDefinition @imageDefinitionParameters

#Remove-AzGalleryImageDefinition -ResourceGroupName $gallery.ResourceGroupName -GalleryName $gallery.Name -Name "govavddefinition"
 
##################################################

$sessionHostCount = 5
$initialNumber = 1
$VMLocalAdminUser = "avdadmin"
$VMLocalAdminSecurePassword = ConvertTo-SecureString (Get-AzKeyVaultSecret -VaultName $keyVault.Vaultname -Name $secret.Name ) -AsPlainText -Force

$avdPrefix = "loboavd"
$VMSize = "Standard_D2s_v3"
$DiskSizeGB = 1028
$ImageOffer = "office-365"
$ImagePublisher = "MicrosoftWindowsDesktop"
$sku = "win11-21h2-avd-m365"

 
$domainUser = "avdadmin@lobogov.com"
$domain = $domainUser.Split("@")[-1]
$ouPath = "OU=Computers,OU=AVD,DC=lobogov,DC=com"
 
 $avdHostpools = Get-AzWvdHostPool -ResourceGroupName $Resourcegroupname -name $Hostpoolname | select-object -Property *


 foreach($avdhostpool in $avdHostpools)
 {
   $hostpoolsessionhosts =  Get-AzWvdSessionHost -HostPoolName $avdhostpool.Name -ResourceGroupName $Resourcegroupname
   
   $registrationToken = Get-AzWvdHostPoolRegistrationToken -ResourceGroupName $ResourceGroupName -HostPoolName $avdHostpool.name 

   $virtualNetwork = Get-AzVirtualNetwork -Name $vnet

      $registrationToken = Get-AzWvdRegistrationInfo -HostpoolName $avdHostpool.name -ResourceGroupName $Resourcegroupname -SubscriptionId $subscription.Id

       # $registrationToken =    Update-AvdRegistrationToken  -HostpoolName $avdHostpool.name  $Resourcegroupname

     
     $osdisk = Get-AzDisk -ResourceGroupName $resourceGroupName | select -first 1 name

        Do {
            $VMName = 'Loboavd' +"$initialNumber"
           # $ComputerName = $VMName
            $nicName = "nic-$vmName"

            $subnetid = $virtualNetwork.Subnets |  Where { $_.Name -eq "AVDsubnet" }| select ID

            $NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $location -SubnetId  $($subnetid).Id
           
            $Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

            $VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
            $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
            $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id

 
            $VirtualMachine = Set-AzVMOSDisk -Windows -VM $VirtualMachine -createoption "FromImage"   -DiskSizeInGB $DiskSizeGB
 
            $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName $ImagePublisher -Offer $ImageOffer -Skus $sku  -Version latest


            $sessionHost = New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine
        

         #############  APPLY license 
            $vm = Get-AzVM -ResourceGroup $ResourceGroupName  -Name  $VirtualMachine.Name 
            $vm.LicenseType = "Windows_Client"
            $vm.StorageProfile.OsDisk.EncryptionSettings = $null  
            Update-AzVM -ResourceGroupName $ResourceGroupName  -VM  $vm 
     

#########################
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
    #################################################

$moduleLocation = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration.zip"


    $avdDscSettings = @{
        Name               = "Microsoft.PowerShell.DSC"
        Type               = "DSC" 
        Publisher          = "Microsoft.Powershell"
        typeHandlerVersion = "2.73"
        SettingString      = "{
            ""modulesUrl"":'$ModuleLocation',
            ""ConfigurationFunction"":""Configuration.ps1\\AddSessionHost"",
            ""Properties"": {
                ""hostPoolName"": ""$($avdhostpool.Name)"",
                ""registrationInfoToken"": ""$($registrationToken.token)"",
                ""aadJoin"": true
            }
        }"
        VMName             = $VMName
        ResourceGroupName  = $resourceGroupName
        location           = $Location
    }
    
    Set-AzVMExtension @avdDscSettings

#############################


            $initialNumber++
            $sessionHostCount--
            Write-Output "$VMName deployed"

        } while ($sessionHostCount -ge $minimumSessions) {
            Write-Verbose "Session hosts are created"

            }

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







