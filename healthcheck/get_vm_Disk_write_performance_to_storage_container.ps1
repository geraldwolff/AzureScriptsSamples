
try
{
    "Logging in to Azure..."
   Connect-AzAccount  #-Identity
  
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

 

 $days = 35

 $Azureresourcedata = ''
 $Azurenetworkoutdata = ''
 $Azurenetworkindata = ''
 $AzureCPUdata  = ''
 $diskreadwriteresults = ''




 $subscriptions = get-azsubscription 
 foreach($sub in $subscriptions)
 {
 set-azcontext -Subscription $($sub.name)
 
        #get all vms in a resource group, but you can remove -ResourceGroupName "xxx" to get all the vms in a subscription
        $vms = Get-azVM 

         #get the last 3 days data
         #end date
         $Today = Get-Date  

         #start date
         $starttime  = $Today.AddDays(-$days)

         #define an array to store the infomation like vm name / resource group / cpu usage / network in / networkout
         

         foreach($vm in $vms)
         {

                                        $resourcedata =  Get-AzResource -ResourceId    $($Vm.id)
                                        $tags = get-aztag -ResourceId  $($Vm.id)
                                        $tagkey = "$($tags.Properties.TagsProperty.keys)"
                                        $tagvalues = $($tags.Properties.TagsProperty[$tagkey])
                                          $newguid = New-Guid

                    

             #define a string to store related infomation like vm name etc. then add the string to an array
             $s = ""
             write-host " $($vm.name) being checked " -foregroundcolor Cyan

             #percentage cpu usage
            $cpu = Get-azMetric -ResourceId $vm.Id -MetricName "Percentage CPU" -DetailedOutput -StartTime $starttime `
             -EndTime $Today -TimeGrain 12:00:00  -WarningAction SilentlyContinue


             #network in
             $in = Get-azMetric -ResourceId $vm.Id -MetricName "Network In" -DetailedOutput -StartTime $starttime `
             -EndTime $Today  -TimeGrain 12:00:00 -WarningAction SilentlyContinue


             #network out 
            $out = Get-azMetric -ResourceId $vm.Id -MetricName "Network Out" -DetailedOutput -StartTime $starttime `
             -EndTime $Today -TimeGrain 12:00:00  -WarningAction SilentlyContinue

            #disk
            $osdiskopsread = Get-azMetric -ResourceId $vm.Id -MetricName "OS Disk Read Operations/Sec" -DetailedOutput -StartTime $starttime `
             -EndTime $Today -TimeGrain 12:00:00  -WarningAction SilentlyContinue

            $osdiskopswrite = Get-azMetric -ResourceId $vm.Id -MetricName "OS Disk Write Bytes/Sec" -DetailedOutput -StartTime $starttime `
             -EndTime $Today -TimeGrain 12:00:00  -WarningAction SilentlyContinue


            $datadiskopsread = Get-azMetric -ResourceId $vm.Id -MetricName "Data Disk Read Bytes/Sec" -DetailedOutput -StartTime $starttime `
             -EndTime $Today -TimeGrain 12:00:00  -WarningAction SilentlyContinue



            $datadiskopswrite = Get-azMetric -ResourceId $vm.Id -MetricName "Data Disk Write Bytes/Sec" -DetailedOutput -StartTime $starttime `
             -EndTime $Today -TimeGrain 12:00:00  -WarningAction SilentlyContinue


            $osdiskIopsread = Get-azMetric -ResourceId $vm.Id -MetricName "VM Cached IOPS Consumed Percentage" -DetailedOutput -StartTime $starttime `
             -EndTime $Today -TimeGrain 12:00:00  -WarningAction SilentlyContinue



            $datadiskIopswrite = Get-azMetric -ResourceId $vm.Id -MetricName "VM uncached IOPS Consumed Percentage" -DetailedOutput -StartTime $starttime `
             -EndTime $Today -TimeGrain 12:00:00  -WarningAction SilentlyContinue




            $vmcachediopsconsumedpercent = Get-azMetric -ResourceId $vm.Id -MetricName "VM Cached IOPS Consumed Percentage" -DetailedOutput -StartTime $starttime `
             -EndTime $Today -TimeGrain 12:00:00  -WarningAction SilentlyContinue



             

            $vmuncachediopsconsumedpercent = Get-azMetric -ResourceId $vm.Id -MetricName "VM uncached IOPS Consumed Percentage" -DetailedOutput -StartTime $starttime `
             -EndTime $Today -TimeGrain 12:00:00  -WarningAction SilentlyContinue




 
 $timeseries = $cpu.Timeseries.data.GetEnumerator() | select timestamp

        foreach ($cpu_timestamp in $timeseries)
        {


     
                 #################### Disk
         $disk = get-azdisk | where managedby -eq $($vm.id)
         
                     foreach($odr in $osdiskopsread.Data| Where-Object timestamp -eq $($CPU_timestamp.timestamp))
                     {
                      $diskread_timestamp = $($odr.timestamp) 
 
                                   $osdiskread =    [math]::Round($($odr.average))  
 

                                        $resoucecpuobj = New-Object PSObject
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name VMNAme  -Value  "$($VM.name)"                            
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name Timestamp -value  "$diskread_timestamp"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name ResourceGroupName  -Value  $($vm.ResourceGroupName)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tag  -Value  "$($tags.Properties.TagsProperty.keys)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tagvalue   "$($tags.Properties.TagsProperty[$tagkey])"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name diskread  $($osdiskread)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Metric  $($osdiskopsread.name.Value)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Diskname  $($disk.name)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name StartTime -Value  "$($starttime)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name EndTime -Value   "$($Today)"
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name ID -value  "$newguid"
                                       # add the above string to an array
                                         [array]$diskreadwriteresults +=  $resoucecpuobj
                        }

                  foreach($odw in $osdiskopswrite.Data| Where-Object timestamp -eq $($CPU_timestamp.timestamp))
                     {
                      $diskwrite_timestamp = $($odw.timestamp) 
                           $osdiskwrite =    [math]::Round($($odw.average))  
                                             
 
                                        $resoucecpuobj = New-Object PSObject
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name VMNAme  -Value  "$($VM.name)"                            
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name Timestamp -value  "$CPU_timestamp"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name ResourceGroupName  -Value  $($vm.ResourceGroupName)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tag  -Value  "$($tags.Properties.TagsProperty.keys)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tagvalue   "$($tags.Properties.TagsProperty[$tagkey])"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name diskwrite  $($osdiskwrite)
 
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Metric  $($osdiskopswrite.name.Value)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name StartTime -Value  "$($starttime)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name EndTime -Value   "$($Today)"
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name ID -value  "$newguid"
                                       # add the above string to an array
                                         [array]$diskreadwriteresults +=  $resoucecpuobj
                        }




                         foreach($ddw in $datadiskopswrite.Data | Where-Object timestamp -eq $($CPU_timestamp.timestamp))
                         {
                            
                                  $datadiskwrite_timestamp = $($ddw.timestamp) 
                                           $datadiskwrite =    [math]::Round($odw.average)  
 
                               
                                        $resoucecpuobj = New-Object PSObject
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name VMNAme  -Value  "$($VM.name)"                            
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name Timestamp -value  "$datadiskwrite_timestamp"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name ResourceGroupName  -Value  $($vm.ResourceGroupName)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tag  -Value  "$($tags.Properties.TagsProperty.keys)"
 
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name diskwrite $($datadiskwrite)
       

                                       $resoucecpuobj | Add-Member -MemberType NoteProperty -name Diskname  $($disk.name)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Metric  $($datadiskopswrite.name.Value)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name StartTime -Value  "$($starttime)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name EndTime -Value   "$($Today)"
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name ID -value  "$newguid"
                                       # add the above string to an array
                                         [array]$diskreadwriteresults +=  $resoucecpuobj
                         }

                     foreach($opsdr in $osdiskopsread.Data| Where-Object timestamp -eq $($CPU_timestamp.timestamp))
                     {
                      $opsdiskread_timestamp = $($opsdr.timestamp) 
                    
                                   $opsdiskread =    [math]::Round($($opsdr.average))  
                                             
       
                              $resoucecpuobj = New-Object PSObject
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name VMNAme  -Value  "$($VM.name)"                            
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name Timestamp -value  "$opsdiskread_timestamp"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name ResourceGroupName  -Value  $($vm.ResourceGroupName)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tag  -Value  "$($tags.Properties.TagsProperty.keys)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tagvalue   "$($tags.Properties.TagsProperty[$tagkey])"
 
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name opsdiskread  $($opsdiskread)
 
                                         $resoucecpuobj | Add-Member -MemberType NoteProperty -name Diskname  $($disk.name)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Metric  $($osdiskopsread.name.Value)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name StartTime -Value  "$($starttime)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name EndTime -Value   "$($Today)"
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name ID -value  "$newguid"
                                       # add the above string to an array
                                         [array]$diskreadwriteresults +=  $resoucecpuobj
                         }


                         foreach($opsdiskw in $osdiskopswrite.Data | Where-Object timestamp -eq $($CPU_timestamp.timestamp))
                         {
               
                                  $opsdiskwrite_timestamp = $($opsdiskw.timestamp) 
                                           $opsdiskwrite =    [math]::Round($opsdiskw.average)  
                           
     

                             $resoucecpuobj = New-Object PSObject
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name VMNAme  -Value  "$($VM.name)"                            
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name Timestamp -value  "$opsdiskwrite_timestamp"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name ResourceGroupName  -Value  $($vm.ResourceGroupName)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tag  -Value  "$($tags.Properties.TagsProperty.keys)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tagvalue   "$($tags.Properties.TagsProperty[$tagkey])"
 
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name opsdiskwrite $($opsdiskwrite)
 
                                         $resoucecpuobj | Add-Member -MemberType NoteProperty -name Diskname  $($disk.name)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Metric  $($osdiskopswrite.name.Value)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name StartTime -Value  "$($starttime)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name EndTime -Value   "$($Today)"
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name ID -value  "$newguid"
                                       # add the above string to an array
                                         [array]$diskreadwriteresults +=  $resoucecpuobj
                         }


###############  Disk IOPS

                     foreach($oiopsdr in $osdiskIopsread.Data| Where-Object timestamp -eq $($CPU_timestamp.timestamp))
                     {
                      $diskiopsread_timestamp = $($oiopsdr.timestamp) 
 
                                   $osdiskIopsread =    [math]::Round($($oiopsdr.average))  
                                             
 

                         $resoucecpuobj = New-Object PSObject
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name VMNAme  -Value  "$($VM.name)"                            
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name Timestamp -value  "$diskiopsread_timestamp"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name ResourceGroupName  -Value  $($vm.ResourceGroupName)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tag  -Value  "$($tags.Properties.TagsProperty.keys)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tagvalue   "$($tags.Properties.TagsProperty[$tagkey])"
 
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name vmcachediopsconsumedpercent   $($osdiskIopsread)
 

                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Diskname  $($disk.name)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Metric  $($osdiskIopsread.name.Value)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name StartTime -Value  "$($starttime)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name EndTime -Value   "$($Today)"
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name ID -value  "$newguid"
                                       # add the above string to an array
                                         [array]$diskreadwriteresults +=  $resoucecpuobj
                         }


                         foreach($diopsdw in $datadiskIopswrite.Data | Where-Object timestamp -eq $($CPU_timestamp.timestamp))
                         {
                         
                                  $diskiopswrite_timestamp = $($oiopsdw.timestamp) 
                                           $datadiskIops =    [math]::Round($diopsdw.average)  
 
                                        $resoucecpuobj = New-Object PSObject
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name VMNAme  -Value  "$($VM.name)"                            
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name Timestamp -value  "$diskiopswrite_timestamp"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name ResourceGroupName  -Value  $($vm.ResourceGroupName)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tag  -Value  "$($tags.Properties.TagsProperty.keys)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tagvalue   "$($tags.Properties.TagsProperty[$tagkey])"
 
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name vmuncachediopsconsumedpercent $($datadiskIops)

                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Diskname  $($disk.name)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Metric  $($datadiskIopswrite.name.Value)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name StartTime -Value  "$($starttime)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name EndTime -Value   "$($Today)"
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name ID -value  "$newguid"
                                       # add the above string to an array
                                         [array]$diskreadwriteresults +=  $resoucecpuobj
                         }

     }
 
           $diskreadwriteresults | select id,Timestamp, VMNAme, ResourceGroupName, Tag , Tagvalue,Diskname, diskread, diskwrite, opsdiskread, opsdiskwrite, datadiskread, datadiskwrite, vmcachediopsconsumedpercent, vmuncachediopsconsumedpercent,metric, StartTime, EndTime     

          # ($VMNAme,$ResourceGroupName,$Tag,$Tagvalue,$diskread,$diskwrite,$opsdiskread,$opsdiskwrite,$datadiskread,$datadiskwrite,$osdiskIopsread,$datadiskIops,$StartTime,$EndTime)


    } #VMS
} # Subs
  $date = Get-Date -Format MMddyyyymmss
 
    



########### Prepare for storage account export

 

 $resultsfilename = "disk_data.csv"

 
 $diskreadwriteresults | select id, VMNAme, ResourceGroupName, Tag , Tagvalue,diskname, diskread, diskwrite, opsdiskread, opsdiskwrite, datadiskread, datadiskwrite, vmcachediopsconsumedpercent, vmuncachediopsconsumedpercent,Metric, StartTime, EndTime | `
 export-csv $resultsfilename  -NoTypeInformation 
# end vmss data 


##### storage subinfo

$Region = "west us"

 $subscriptionselected = 'wolffentpsub'



$resourcegroupname = 'wolffautomationrg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = 'wolffautosa'
$storagecontainer = 'vmnetworkdiskperformance'


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
       
        
 
         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename  -File $resultsfilename  -Context $destContext -force

     
 
 






      