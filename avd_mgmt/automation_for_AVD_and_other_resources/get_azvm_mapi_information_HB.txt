 <# 
 
.SYNOPSIS  
 Wrapper script for get_azvm_mapi_information_HB.ps1
.DESCRIPTION  
Script to collect all information from Virtual machines and see Hybrid Benefit assignment
.EXAMPLE  
       get_azvm_mapi_information_HB.ps1
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

#> 
 
 $DirectoryToCreate = 'C:\temp'

 if (-not (Test-Path -LiteralPath $DirectoryToCreate)) {
    
    try {
        New-Item -Path $DirectoryToCreate -ItemType Directory -ErrorAction Stop | Out-Null #-Force
    }
    catch {
        Write-Error -Message "Unable to create directory '$DirectoryToCreate'. Error was: $_" -ErrorAction Stop
    }
    "Successfully created directory '$DirectoryToCreate'."

}
else {
    "Directory already existed"
}
 
 
 Connect-AzAccount  -EnvironmentName AzureUSGovernment

 
 get-azsubscription 

$ErrorActionPreference = 'silentlyContinue'

### get the list of subscriptions accessible by the credentials requested to Secret server 

Clear-Content "c:\temp\vm_mapi_information_II.csv" 


$Subs =  Get-azSubscription | select Name, ID,TenantId


 
 
 foreach($Subscription in  $subs)
    {

                             $SubscriptionName =  $Subscription.name

                             
                           $azcontext = (set-azcontext -SubscriptionName $SubscriptionName  -ErrorAction SilentlyContinue )

                       write-host "$SubscriptionName" -foregroundcolor yellow
                    $rgs = get-azresourcegroup

                    foreach($rgname in $rgs)
                    {
            
                            
                             $vms = get-azvm -ResourceGroupName  $rgname.resourcegroupname 
                            
                               Foreach($vm in $vms) 
                      
                                {   
 
                                  $vmname = "$($VM.Name)"
                                 # $vmfillid = ("$($vm.vmid)" -split '/')[2] 
                                  $vmid = "$($vm.vmid)"

                                  $vmloc = (get-azvm  -ResourceGroupName  $rgname.resourcegroupname -name $vmname).Location

                                  $vmtags = (get-azvm  -ResourceGroupName  $rgname.resourcegroupname -name $vmname).Tags
                                  $VMDetail = Get-azVM -ResourceGroupName $rgname.resourcegroupname  -Name $($VM.Name) -Status  -erroraction silentlycontinue 
                                   
 
  
                                        $VMStatusDetail = $VMdetail.statuses.DisplayStatus
                                        $vmdiskcount = $vmdetail.disks.Count
                                        $vmOSdiskcapacity =  (get-azdisk | Where-Object {($_.ManagedBy).Split("/")[-1] -like "$vmname"}).DiskSizeGB
                                
                                        $VMosConfig_automatic_updates = $vm.OSProfile.WindowsConfiguration.EnableAutomaticUpdates
                                        $VMosConfig_WinRM = $vm.OSProfile.WindowsConfiguration.Winrm
                                        $VMostype=  $vm.StorageProfile.OsDisk.OsType
                                        $skudetail =     Get-azvmSize -Location "$($vm.location)" | Where-Object Name -EQ "$vmSku"   
                                        $vmcores = $skudetail.NumberOfCores
                                        $vmmemoryMB =  $skudetail.MemoryInMB
                                        $vmMaxDisks = $skudetail.MaxDataDiskCount
                                        $vmSku = $vm.HardwareProfile.VmSize
                                        $vmnics = $vm.NetworkProfile.NetworkInterfaces
                                        $vmlicensetype = $vm.LicenseType
                                       

                                   $nics = get-aznetworkinterface -ResourceGroupName  $rgname.resourcegroupname   | Where-Object {($_.VirtualMachine.id).Split("/")[-1] -like "$vmname"}

                        foreach($nic in $nics)
                            {

                                $pipip = $null
                                 $pipallocation = $null
                                $prv  = $null
                                $alloc = $null
                                $VMStatusDetail = $null

                                $PublicIPS =  Get-azPublicIpAddress -ResourceGroupName $rgname.resourcegroupname |    Where-Object {($_.id).Split("/")[-1] -like "$vmname*" }
 

                        
                                 $vm = $vms | where-object -Property Id -EQ $nic.VirtualMachine.id

                                 $VMDetail = Get-azVM -ResourceGroupName $rgname.resourcegroupname  -Name $($VM.Name) -Status  -erroraction silentlycontinue 

                                foreach ($VMStatus in $VMDetail.Statuses)
                                { 
  
                                        $VMStatusDetail = $VMStatus.DisplayStatus
                                 }
            
                                         $PIP = $PublicIPS.Where({$_.Id -eq $nic.IpConfigurations.publicipaddress.id})
 
 
                                
                                            $pipallocation = $pip.PublicIpAllocationMethod 
                                            $pipip   =  $pip.ipaddress 
                                            $prv =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
                                            $alloc =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod
                                            $MacAddress = $nic.MacAddress
                                }
                                    
                                     $vmip = (Get-azNetworkInterface | Where-Object {($_.VirtualMachine.id).Split("/")[-1] -like $vmname}).IpConfigurations.PrivateIpAddress
 
                                          $block = {  param($vmname)
       
                                               $adapterS = Get-NetAdapter | where-object InterfaceDescription -like '*Microsoft Hyper-V Network Adapter*' 
                                               # $adapterS
                                                  $nicinfo  = Get-DnsClientServerAddress -InterfaceIndex "$($adapterS.ifIndex)"
                                                   $nicinfo 
                                           }
    
    
                                      $nicdata =  Invoke-Command -ComputerName $vmname  -ScriptBlock $block -ArgumentList $vmname 
 
                                 $block = {  param($vmname)
       
                                     
                                                  $dhcpserver  = (Get-DhcpServer -Server $vmname ) | select serverName , address
                                                   $dhcpserver 
                                           }
    
    
                                      $dhcpdata =  Invoke-Command -ComputerName $vmname  -ScriptBlock $block -ArgumentList $vmname                       
   
                          

                                    $vmobj = new-object PSObject 

                                        $vmobj | add-member  -membertype NoteProperty -name   SubscriptionName  -value "$SubscriptionName"                                                                                    
                                        $vmobj | add-member  -membertype NoteProperty -name   resourcegroupname  -value "$($rgname.resourcegroupname)"         
                                        $vmobj | add-member  -membertype NoteProperty -name   VMName  -value "$vmname"
                                        $vmobj | add-member  -membertype NoteProperty -name   VMID  -value "$vmid"
                                        $vmobj | add-member  -membertype NoteProperty -name   vmloc -Value "$vmloc"
                                        $vmobj | add-member  -membertype NoteProperty -name   VMStatusDetail -Value "$VMStatusDetail"
                                        $vmobj | add-member  -membertype NoteProperty -name   vmdiskcount -value "$vmdiskcount"
                                        $vmobj | add-member  -membertype NoteProperty -name   vmOSdiskcapacity -value "$vmOSdiskcapacity"
                                        $vmobj | add-member  -membertype NoteProperty -name  VMosConfig_automatic_updates -value "$VMosConfig_automatic_updates"
                                        $vmobj | add-member  -membertype NoteProperty -name  VMosConfig_winrm -value "$VMosConfig_winrm"
                                        $vmobj | add-member  -membertype NoteProperty -name  VMostype  -value "$VMostype"
                                        $vmobj | add-member  -membertype NoteProperty -name  vmcores -value "$vmcores"
                                        $vmobj | add-member  -membertype NoteProperty -name  vmmemoryMB -value "$vmmemoryMB"
                                        $vmobj | add-member  -membertype NoteProperty -name   vmMaxDisks -value "$vmMaxDisks"
                                        $vmobj | add-member  -membertype NoteProperty -name   vmSku -value "$vmSku"
                                        $vmobj | add-member  -membertype NoteProperty -name   Pip -value "$pipip"
                                        $vmobj | add-member  -membertype NoteProperty -name   pipallocation -value "$pipallocation"
                                        $vmobj | add-member  -membertype NoteProperty -name   alloc -value "$alloc"
                                        $vmobj | add-member  -membertype NoteProperty -name   vmip -value "$vmip"
                                        $vmobj | add-member  -membertype NoteProperty -name    MAcAddress -value "$MacAddress"
                                        $vmobj | add-member  -membertype NoteProperty -name  DNSServers -value "$($nicdata)"
                                        $vmobj | add-member  -membertype NoteProperty -name  DHCPSERVERS -value "$($dhcpdata.Address)" 
                                        $vmobj | add-member  -membertype NoteProperty -name  Tags -value "$($vmtags.Values)" 
                                        $vmobj | add-member  -membertype NoteProperty -name  HybridBenefittype -value "$($vmlicensetype)"   
                                        $vmobj | export-csv "c:\temp\vm_mapi_information_II.csv" -append -notypeinformation

                            }

                                  
                      }
                    

}

$CSS = @"
<Title>VM MAPI  Report:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
<Header>
 
"<B>Company Confidential</B> <br><I>Report generated from {3} on $env:computername {0} by {1}\{2} as a scheduled task</I><br><br>Please contact $contact with any questions "$(Get-Date -displayhint date)",$env:userdomain,$env:username
 </Header>

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





$mapi_results = import-csv "c:\temp\vm_mapi_information_II.csv" 
 

(($mapi_results   | Sort-Object -Property SubscriptionName,resourcegroupname,VMName,VMID ,vmloc,VMStatusDetail,vmdiskcount,vmOSdiskcapacity,VMosConfig_automatic_updates,VMostype -unique |`
Select SubscriptionName,resourcegroupname,  Tags, VMName,VMID ,vmloc,@{Name='VMosConfig_winrm';E={IF ($($_.VMosConfig_winrm) -eq ''){'not enabled'}Else{$_.VMosConfig_winrm}}},`
VMStatusDetail,vmdiskcount,vmOSdiskcapacity,VMosConfig_automatic_updates,VMostype,vmcores,vmmemoryMB,vmMaxDisks,vmSku,@{Name='Pip';E={IF ($_.pip -eq ''){'not provisioned'}Else{$_.pip}}},pipallocation,Alloc,vmip,MacAddress,DNSServers,DHCPSERVERS, Tags, HybridBenefittype |`
ConvertTo-Html -Head $CSS ).replace('not enabled','<font color=red>not enabled</font>')).replace('not provisioned','<font color=blue>not provisioned</font>')   | Out-File "c:\temp\vm_mapi_information_II.html"
 Invoke-Item "c:\temp\vm_mapi_information_II.html"
