
try
{
    "Logging in to Azure..."
   Connect-AzAccount   -Identity
  
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

 

 $days = 35

 $Azureresourcedata = ''
   
 
        #get all vms in a resource group, but you can remove -ResourceGroupName "xxx" to get all the vms in a subscription
        $vms = Get-azVM 

         #get the last 3 days data
         #end date
         $EndTime=Get-Date

         #start date
         $starttime  = $EndTime.AddDays(-$days)

         #define an array to store the infomation like vm name / resource group / cpu usage / network in / networkout
         

         foreach($vm in $vms)
         {
             #define a string to store related infomation like vm name etc. then add the string to an array
             $s = ""
             write-host " $($vm.name) being checked " -foregroundcolor Cyan

             #percentage cpu usage
            $cpu = Get-azMetric -ResourceId $vm.Id -MetricName "Percentage CPU" -DetailedOutput -StartTime $starttime `
             -EndTime $EndTime -TimeGrain 12:00:00  -WarningAction SilentlyContinue


             #network in
             $in = Get-azMetric -ResourceId $vm.Id -MetricName "Network In" -DetailedOutput -StartTime $starttime `
             -EndTime $EndTime  -TimeGrain 12:00:00 -WarningAction SilentlyContinue


             #network out 
            $out = Get-azMetric -ResourceId $vm.Id -MetricName "Network Out" -DetailedOutput -StartTime $starttime `
             -EndTime $EndTime -TimeGrain 12:00:00  -WarningAction SilentlyContinue


             #Example  3 days == 72hours == 12*6hours
             # 30 days == 720 hours == 60*6 hours
             $trimseg = $days/2

             $avghours =   $days *24 /$trimseg 
              
             $cpu_total=0.0
             $networkIn_total = 0.0
             $networkOut_total = 0.0

                 foreach($c in $cpu.Data.Average)
                 {
                  #this is a average value for 12 hours, so total = $c*12 (or should be $c*12*60*60)
                  $cpu_total += $c* $avghours
                 }

                 foreach($i in $in.Data.total)
                 {
                 $networkIn_total += $i 
                 }

                 foreach($t in $out.Data.total)
                 {
                 $networkOut_total += $t
                 }

    
 
                $resourcedata =  Get-AzResource -ResourceId    $($Vm.id)
                $tags = get-aztag -ResourceId  $($Vm.id)
                $tagkey = "$($tags.Properties.TagsProperty.keys)"

                  $newguid = New-Guid



                $resouceobj = New-Object PSObject
                $resouceobj | add-member -MemberType NoteProperty -name   ID -value  "$newguid"
                $resouceobj | Add-Member -MemberType NoteProperty -name VMNAme  -Value  $($VM.name)
                $resouceobj | Add-Member -MemberType NoteProperty -name ResourceGroupName  -Value  $($vm.ResourceGroupName)
                $resouceobj | Add-Member -MemberType NoteProperty -name Tag  -Value  "$($tags.Properties.TagsProperty.keys)"
                $resouceobj | Add-Member -MemberType NoteProperty -name Tagvalue   "$($tags.Properties.TagsProperty[$tagkey])"
                $resouceobj | Add-Member -MemberType NoteProperty -name cpu_total  -Value  $($cpu_total)
                $resouceobj | Add-Member -MemberType NoteProperty -name networkIn_total -Value  $($networkIn_total)
                $resouceobj | Add-Member -MemberType NoteProperty -name networkOut_total -Value   $($networkOut_total)
                $resouceobj | Add-Member -MemberType NoteProperty -name StartTime -Value  $($starttime)
                $resouceobj | Add-Member -MemberType NoteProperty -name EndTime -Value   $($EndTime)

                   
             # add the above string to an array
             [array]$Azureresourcedata +=  $resouceobj
      
           
        }
  
         #check the values in the array
 $date = Get-Date -Format MMddyyyy


         ## Convert to Json for anomaly detection 
         $anomalydatafile = 'cpuanomalydata.csv'
         $Azureresourcedata | ConvertTo-Json | Out-File $anomalydatafile

         $anomalydatafile

########### Prepare for storage account export

$csvresults = $Azureresourcedata| Select   id, VMNAme, ResourceGroupName, Tag , Tagvalue, cpu_total, networkIn_total,networkOut_total,StartTime,EndTime 

 $resultsfilename = "cpu_usage$date.csv"

$csvresults  | export-csv $resultsfilename  -NoTypeInformation   



  $anomalydatafile = "cpuanomalydata$date.csv"
         $Azureresourcedata | ConvertTo-Json | Out-File $anomalydatafile

         $anomalydatafile
# end vmss data 


##### storage subinfo

$Region = "<location/Region>"

 $subscriptionselected = '<Subscription>'



$resourcegroupname = '<resourcegroup>'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | select tenantid
$storageaccountname = '<StorageAccountName>'
$storagecontainer = 'automationresults'
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
 
 
     
 
 






      