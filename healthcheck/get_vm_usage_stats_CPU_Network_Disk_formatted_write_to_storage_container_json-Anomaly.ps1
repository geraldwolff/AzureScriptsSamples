
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


            $osdiskIopsread = Get-azMetric -ResourceId $vm.Id -MetricName "OS Disk Used Burst IO Credits Percentage" -DetailedOutput -StartTime $starttime `
             -EndTime $Today -TimeGrain 12:00:00  -WarningAction SilentlyContinue



            $datadiskIopswrite = Get-azMetric -ResourceId $vm.Id -MetricName "Data Disk Used Burst IO Credits Percentage" -DetailedOutput -StartTime $starttime `
             -EndTime $Today -TimeGrain 12:00:00  -WarningAction SilentlyContinue



             #Example  3 days == 72hours == 12*6hours
             # 30 days == 720 hours == 60*6 hours
             $trimseg = $days/2

             $avghours =   $days *24 /$trimseg 
              
             $cpu_total=0.0
             $networkIn_total = 0.0
             $networkOut_total = 0.0

                 foreach($c in $cpu.Data)
                 {
                  #this is a average value for 12 hours, so total = $c*12 (or should be $c*12*60*60)
                   
                     $CPU_timestamp = $($c.timestamp) 
                     if($($c.average) -ne $null)
                         {
                             $Cpu =   $($c.average) 
                          }
                          else
                          {
                           $Cpu =  0
                          }

                 

                     foreach($i in $in.Data| Where-Object timestamp -eq $CPU_timestamp)
                     {
                      $networkin_timestamp = $($i.timestamp) 
                       if($($i.total) -ne $null)
                         {
                                   $networkin =   $($i.total) 
                          }
                            else
                            {
                                 $networkin = 0
                            }


                         foreach($t in $out.Data | Where-Object timestamp -eq $CPU_timestamp)
                         {
                              if($($t.total) -ne $null)
                                 {
                                  $networkout_timestamp = $($t.timestamp) 
                                           $networkout =   $($t.total) 
                                  }
                                  else
                                  {
                                     $networkout = 0
                                 }
                 
                                      




                                        $resouceobj = New-Object PSObject
                                        $resouceobj | Add-Member -MemberType NoteProperty -name VMNAme  -Value  "$($VM.name)"                            
                                        $resouceobj | add-member -MemberType NoteProperty -name Timestamp -value  "$CPU_timestamp"
                                        $resouceobj | Add-Member -MemberType NoteProperty -name ResourceGroupName  -Value  $($vm.ResourceGroupName)
                                        $resouceobj | Add-Member -MemberType NoteProperty -name Tag  -Value  "$($tags.Properties.TagsProperty.keys)"
                                        $resouceobj | Add-Member -MemberType NoteProperty -name Tagvalue   "$($tags.Properties.TagsProperty[$tagkey])"
                                        $resouceobj | Add-Member -MemberType NoteProperty -name cpu  -Value  $($Cpu)
                                        $resouceobj | Add-Member -MemberType NoteProperty -name networkIn -Value  $($networkin)
                                        $resouceobj | Add-Member -MemberType NoteProperty -name networkOut -Value   $($networkout)
                                        $resouceobj | Add-Member -MemberType NoteProperty -name StartTime -Value  "$($starttime)"
                                        $resouceobj | Add-Member -MemberType NoteProperty -name EndTime -Value   "$($Today)"
                                        $resouceobj | add-member -MemberType NoteProperty -name ID -value  "$newguid"
                                       # add the above string to an array
                                         [array]$Azureresourcedata +=  $resouceobj



                              



                                        $resnetworkinobj = New-Object PSObject
                                        $resnetworkinobj | Add-Member -MemberType NoteProperty -name VMNAme  -Value  "$($VM.name)"                            
                                        $resnetworkinobj | add-member -MemberType NoteProperty -name Timestamp -value  "$CPU_timestamp"
                                        $resnetworkinobj | Add-Member -MemberType NoteProperty -name ResourceGroupName  -Value  $($vm.ResourceGroupName)
                                        $resnetworkinobj | Add-Member -MemberType NoteProperty -name Tag  -Value  "$($tags.Properties.TagsProperty.keys)"
                                        $resnetworkinobj | Add-Member -MemberType NoteProperty -name Tagvalue   "$($tags.Properties.TagsProperty[$tagkey])"
                                        $resnetworkinobj | Add-Member -MemberType NoteProperty -name networkIn -Value  $($networkin)
                                        $resnetworkinobj | Add-Member -MemberType NoteProperty -name StartTime -Value  "$($starttime)"
                                        $resnetworkinobj | Add-Member -MemberType NoteProperty -name EndTime -Value   "$($Today)"
                                        $resnetworkinobj | add-member -MemberType NoteProperty -name ID -value  "$newguid"
                                       # add the above string to an array
                                         [array]$Azurenetworkindata +=  $resnetworkinobj


                             



                                        $resnetworkoutobj = New-Object PSObject
                                        $resnetworkoutobj | Add-Member -MemberType NoteProperty -name VMNAme  -Value  "$($VM.name)"                            
                                        $resnetworkoutobj | add-member -MemberType NoteProperty -name Timestamp -value  "$CPU_timestamp"
                                        $resnetworkoutobj | Add-Member -MemberType NoteProperty -name ResourceGroupName  -Value  $($vm.ResourceGroupName)
                                        $resnetworkoutobj | Add-Member -MemberType NoteProperty -name Tag  -Value  "$($tags.Properties.TagsProperty.keys)"
                                        $resnetworkoutobj | Add-Member -MemberType NoteProperty -name Tagvalue   "$($tags.Properties.TagsProperty[$tagkey])"
                                        $resnetworkoutobj | Add-Member -MemberType NoteProperty -name networkOut -Value   $($networkout)
                                        $resnetworkoutobj | Add-Member -MemberType NoteProperty -name StartTime -Value  "$($starttime)"
                                        $resnetworkoutobj | Add-Member -MemberType NoteProperty -name EndTime -Value   "$($Today)"
                                        $resnetworkoutobj | add-member -MemberType NoteProperty -name ID -value  "$newguid"
                                       # add the above string to an array
                                         [array]$Azurenetworkoutdata +=  $resnetworkoutobj

                        

                                        $resoucecpuobj = New-Object PSObject
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name VMNAme  -Value  "$($VM.name)"                            
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name Timestamp -value  "$CPU_timestamp"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name ResourceGroupName  -Value  $($vm.ResourceGroupName)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tag  -Value  "$($tags.Properties.TagsProperty.keys)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tagvalue   "$($tags.Properties.TagsProperty[$tagkey])"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Value  -Value  $($Cpu)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name StartTime -Value  "$($starttime)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name EndTime -Value   "$($Today)"
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name ID -value  "$newguid"
                                       # add the above string to an array
                                         [array]$AzureCPUdata +=  $resoucecpuobj
 

 
  
        } # t
    } # In
  } #c


                 #################### Disk
                    
         
                     foreach($odr in $osdiskopsread.Data| Where-Object timestamp -eq $CPU_timestamp)
                     {
                           $CPU_timestamp = $($odrc.timestamp) 
         
                        $osdiskread =    [math]::Round($($odr.average))  
    


                       $odw = $datadiskopswrite.Data | Where-Object timestamp -eq $CPU_timestamp 
 
                         $datadiskwrite =    [math]::Round($odw.average)  
                                            $datadiskwrite
                                             $odw    
     
 

                       $opsdr =  $osdiskopsread.Data| Where-Object timestamp -eq $CPU_timestamp
  
                         $opsdiskread =    [math]::Round($($opsdr.average))  
              

                        $opsdiskw = $osdiskopswrite.Data | Where-Object timestamp -eq $CPU_timestamp
              
                       $opsdiskwrite =    [math]::Round($opsdiskw.average)  
               


            ###############  Disk IOPS

                  $oiopsdr = $osdiskIopsread.Data| Where-Object timestamp -eq $CPU_timestamp
    
       
                                   $osdiskIopsread =    [math]::Round($($oiopsdr.average))  
                                             
               


                        $diopsdw = $datadiskIopswrite.Data | Where-Object timestamp -eq $CPU_timestamp
     
                          $datadiskIops =    [math]::Round($diopsdw.average)  
                            $datadiskIops
                            $diopsdw    
 
 
                                 $resoucecpuobj = New-Object PSObject
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name VMNAme  -Value  "$($VM.name)"                            
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name Timestamp -value  "$CPU_timestamp"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name ResourceGroupName  -Value  $($vm.ResourceGroupName)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tag  -Value  "$($tags.Properties.TagsProperty.keys)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name Tagvalue   "$($tags.Properties.TagsProperty[$tagkey])"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name diskread  $($diskread)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name diskwrite $($diskwrite)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name opsdiskread  $($opsdiskread)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name opsdiskwrite $($opsdiskwrite)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name datadiskread  $($datadiskread)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name datadiskwrite $($datadiskwrite)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name osdiskIopsread   $($osdiskIopsread)
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name datadiskIops $($datadiskIops)


                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name StartTime -Value  "$($starttime)"
                                        $resoucecpuobj | Add-Member -MemberType NoteProperty -name EndTime -Value   "$($Today)"
                                        $resoucecpuobj | add-member -MemberType NoteProperty -name ID -value  "$newguid"
                                       # add the above string to an array
                                         [array]$diskreadwriteresults +=  $resoucecpuobj
            }
  

} #VMS
  $date = Get-Date -Format MMddyyyymmss

$jsonBase = @{}

  $jsonbase.add("maxAnomalyRatio", 0.25)
  $jsonbase.add("sensitivity", 95)
  $jsonbase.add("granularity", "monthly")
  $jsonbase.add("imputeMode", "fixed")
  $jsonbase.add("imputeFixedValue", 800)
  

 $jsonbase.add("series",($AzureCPUdata | Where-Object VMNAME -ne $null| Select-Object timestamp,cpu ))
 $jsonbase.add("NetworkIn", ($Azurenetworkindata | Where-Object VMNAME -ne $null | Select-Object timestamp, networkin )) 
 $jsonbase.add("Networkout", ($Azurenetworkoutdata | Where-Object VMNAME -ne $null | Select-Object timestamp, netrworkout))


 
$jsonbasecheck = $jsonBase | ConvertTo-Json -Depth 10  
 
 $jsonbasecheckfile = $jsonBase | convertto-json -Depth 10  | Out-File C:\temp\cpuanomalydata.json

 $jsonBase   | convertto-json -Depth 10 


          
         ## Convert to Json for anomaly detection 
         $anomalydatafile = "cpuanomalydata$date.json"

         $jsonBase |  Where-Object VMNAME -ne $null  | convertto-json -Depth 10 | Out-File $anomalydatafile

          $anomalydatafile     
  
         #check the values in the array



########### Prepare for storage account export

$csvresults = $Azureresourcedata| Select-object   id, VMNAme, ResourceGroupName, Tag , Tagvalue, cpu, networkIn,networkOut,StartTime,EndTime 

 $resultsfilename = "cpu_usage$date.csv"

$csvresults  | export-csv $resultsfilename  -NoTypeInformation   

$csvresults  | select-object  timestamp,cpu  | export-csv c:\temp\cpuanomanlydat.csv  -NoTypeInformation  

 $resultsfilename2 = "disk_data.csv"

 
 $diskreadwriteresults | select id, VMNAme, ResourceGroupName, Tag , Tagvalue, diskread, diskwrite, opsdiskread, opsdiskwrite, datadiskread, datadiskwrite, osdiskIopsread, datadiskIops, StartTime, EndTime | `
 export-csv $resultsfilename2  -NoTypeInformation 
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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfile  -File $resultsfilename -Context $destContext
        
        Set-azStorageBlobContent -Container $storagecontainer -Blob $anomalydatafile  -File $anomalydatafile  -Context $destContext
 
         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename2  -File $resultsfilename2  -Context $destContext

     
 
 






      