clear-content  c:\temp\vmss_info.html
 $subscriptions = get-Azsubscription 

foreach($subscription in $subscriptions)
{
set-Azcontext -subscription "$($subscription.Name)"


 
 
 

         $vmscalesets = Get-AzVmss  


         foreach($vmss in $vmscalesets)
         {
          $vmssvms =     Get-AzVmssVM -ResourceGroupName $($vmss.ResourceGroupName)  -VMScaleSetName $($vmss.name) 
        
                foreach($vmssist in   $vmssvms )
                {
                   
                 $vmssinfo = get-AzVmssVM  -InstanceId $($vmssist.instanceid)  -ResourceGroupName $($vmssist.ResourceGroupName) -VMScaleSetName $($vmss.Name)

                 $vmsshostname = $vmssinfo.OsProfile.ComputerName
                 $vmsshostnamenic = Get-AzNetworkInterface -VirtualMachineScaleSetName $($vmss.Name) -ResourceGroupName $($vmssist.ResourceGroupName)  | where { $_.VirtualMachine.Id -eq $($vmssinfo.Id)}

                 $vmsshostnameprivateIP = ($vmsshostnamenic.IpConfigurations).PrivateIpAddress

                 $vmssinstanceview_info =  Get-AzVmssVM -InstanceView -InstanceId $($vmssist.instanceid)  -ResourceGroupName $($vmssist.ResourceGroupName) -VMScaleSetName $($vmss.Name)

                 $vmssinstance_info = Get-AzVmssVM -Verbose -InstanceId $($vmssist.instanceid)  -ResourceGroupName $($vmssist.ResourceGroupName) -VMScaleSetName $($vmss.Name)

                 $VMSSPIP = Get-AzPublicIpAddress -VirtualMachineScaleSetName $($vmss.Name)  -ResourceGroupName $($vmssist.ResourceGroupName) -NetworkInterfaceName $($vmsshostnamenic.Name)  | where { $_.ID -eq $($vmsshostnamenic.IpConfigurations.publicipaddress).id } | select  IpAddress
                 ################################################

                 $size = $vmssinstance_info.Sku.Name
                 $sku_tier = $vmssinstance_info.Sku.Tier
                 $sku_capacity = $vmssinstance_info.Sku.Capacity

                 $computer_admin = $vmssinstance_info.OsProfile.AdminUsername
                 $vmss_computer_update_status = $vmssinstance_info.OsProfile.WindowsConfiguration.EnableAutomaticUpdates
                 $vmss_computer_location = ($vmssinstance_info.Resources).location | select -First 1
                 $vmss_virtualMachineExtensionType = (($vmssinstance_info.Resources).VirtualMachineExtensionType)
                 $vmss_computer_image = $vmssinstance_info.StorageProfile.ImageReference.Id
                 $vmss_computer_Disk_size = $vmssinstance_info.StorageProfile.OsDisk.DiskSizeGB
                 $vmss_computer_Data_count = $vmssinstance_info.StorageProfile.DataDisks.Count
                 $vmss_osType = $vmssinstance_info.StorageProfile.OsDisk.OsType
                 $vmss_instanceID = $vmssinstance_info.InstanceId
                 $vmssStatus = (Get-AzVmssVM -ResourceGroupName $($vmss.ResourceGroupName) -VMScaleSetName $($vmss.Name)   -InstanceView -InstanceId "0").Statuses
                             
                 $VMSSRunstatus = $vmssStatus[1].DisplayStatus 

                 $vmss_Runningstate = $VMSSRunstatus




                 ##################################################

              #   write-host " $($vmsshostname) : $($vmsshostnameprivateIP) " -ForegroundColor green 

                   $VMScalesetdata = new-object PSObject 
 
                            $VMScalesetdata | add-member -MemberType NoteProperty -name   Computername -value  "$vmsshostname"
                            $VMScalesetdata | add-member  -MemberType NoteProperty -name  Private_IP  -value   "$vmsshostnameprivateIP "
                            
                            $VMScalesetdata | add-member -MemberType NoteProperty -name   Public_IP  -value   "$($VMSSPIP.ipaddress)"

                            $VMScalesetdata | add-member -MemberType NoteProperty -name   Size -value   "$size"
                            $VMScalesetdata | add-member  -MemberType NoteProperty -name  Tier  -value  "$sku_tier"
                            $VMScalesetdata | add-member -MemberType NoteProperty -name   Capacity -value   "$sku_capacity"
                            $VMScalesetdata | add-member -MemberType NoteProperty -name   Location  -value  "$vmss_computer_location"
                            $VMScalesetdata | add-member -MemberType NoteProperty -name   Image -value   "$vmss_computer_image"
                            $VMScalesetdata | add-member -MemberType NoteProperty -name   ExtensionType -value   "$vmss_virtualMachineExtensionType"
                            $VMScalesetdata | add-member -MemberType NoteProperty -name   Disk_size -value   "$vmss_computer_Disk_size"
                            $VMScalesetdata | add-member -MemberType NoteProperty -name   Data_Disk_Count  -value  "$vmss_computer_Data_count"
                            $VMScalesetdata | add-member -MemberType NoteProperty -name   OSType -value   "$vmss_osType"
                            $VMScalesetdata | add-member -MemberType NoteProperty -name   InstanceID -value   "$vmss_instanceID"
                            $VMScalesetdata  | add-member -MemberType NoteProperty -name  Resourcegroup -value  $($vmssist.ResourceGroupName)
                            $VMScalesetdata | add-member  -MemberType NoteProperty -name  Subscription -value  $($subscription.name)
                            $VMScalesetdata | add-member  -MemberType NoteProperty -name  Runningstate -value  $vmss_Runningstate

                        [array]$vmssdata +=    $VMScalesetdata




                  # Get-AzVmssVM -ResourceGroupName "myResourceGroup" -VMScaleSetName "myScaleSet" -InstanceId "1"
            }
        }
}


  

    $CSS = @"
<Title> VM Scale Sets in Use Report:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
<Style>
th {
       font: bold 11px "Trebuchet MS", Verdana, Arial, Helvetica,
       sans-serif;
       color:#F8F8FF;
       border-right: 1px solid #191970;
       border-bottom: 1px solid #191970;
       border-top: 1px solid #191970;
       letter-spacing: 2px;
       text-transform: uppercase;
       text-align: left;
       padding: 6px 6px 6px 12px;
       background: #5F9EA0;
}
td {
       font: 11px "Trebuchet MS", Verdana, Arial, Helvetica,
       sans-serif;
       border-right: 1px solid #191970;
       border-bottom: 1px solid #191970;
       background: #fff;
       padding: 6px 6px 6px 12px;
       color: #6D929B;
}
</Style>
"@




$vmss_report  = ($vmssdata | Select    Computername, Private_IP, Public_IP , Size, Tier, Capacity,Location,Image,ExtensionType,Disk_size,Data_Disk_Count,OSType,InstanceID,Resourcegroup,Subscription, Runningstate|`   
ConvertTo-Html -Head $CSS )  | out-file c:\temp\vmss_info.html 
invoke-item c:\temp\vmss_info.html 

 
 