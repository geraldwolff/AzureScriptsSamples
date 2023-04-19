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

#> 


param(

[String]$days = $(throw "Value days is incorrect or missing - use interger"),
[String]$subscription = $(throw "Value subscription name is missing")
)



try
{
    "Logging in to Azure..."
    ## use this connection for automation accounts
    Connect-AzAccount   -Identity

    ## use this connection for azure US gov 
  #Connect-AzAccount   #-Environment AzureUSGovernment

}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

 
 
     $subscription = Get-AzSubscription  -SubscriptionName $subscription
       set-azcontext -Subscription $subscription
      $context = get-azcontext
       $context

 $days = $days

 $Azureresourcedata = ''

 
        #get all vms in a resource group, but you can remove -ResourceGroupName "xxx" to get all the vms in a subscription
        $vms = Get-azVM 

         #get the last $days days data

         #end date
         $EndTime=Get-Date

         #start date
         $starttime  = $EndTime.AddDays(-$days)

         #define an array to store the infomation like vm name / resource group / cpu usage / network in / networkout
         

         foreach($vm in $vms)
         {
             
             write-host " $($vm.name) being checked " -foregroundcolor Cyan

             #percentage cpu usage
            $cpu = Get-azMetric -ResourceId $($vm.Id) -MetricName "Percentage CPU" -DetailedOutput -StartTime $starttime `
             -EndTime $EndTime -TimeGrain 12:00:00  -WarningAction SilentlyContinue


             #network in
             $in = Get-azMetric -ResourceId $($vm.Id) -MetricName "Network In" -DetailedOutput -StartTime $starttime `
             -EndTime $EndTime  -TimeGrain 12:00:00 -WarningAction SilentlyContinue


             #network out 
            $out = Get-azMetric -ResourceId $($vm.Id) -MetricName "Network Out" -DetailedOutput -StartTime $starttime `
             -EndTime $EndTime -TimeGrain 12:00:00  -WarningAction SilentlyContinue


             #Example  3 days == 72hours == 12*6hours
        
            

             
              
             $cpu_total=0.0
             $networkIn_total = 0.0
             $networkOut_total = 0.0

                 foreach($c in $cpu.Data.Average)
                 {
                  #this is a average value for 12 hours, so total = $c*12 (or should be $c*12*60*60)
                  $cpu_total += $c* 12
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

                $resouceobj = New-Object PSObject
                $resouceobj | Add-Member -MemberType NoteProperty -name VMNAme  -Value  $($VM.name)
                $resouceobj | Add-Member -MemberType NoteProperty -name ResourceGroupName  -Value  $($vm.ResourceGroupName)
                 $resouceobj | Add-Member -MemberType NoteProperty -name ID  -Value  "$($vm.Id)"
                $resouceobj | Add-Member -MemberType NoteProperty -name Tagvalue   "$($tags.Properties.TagsProperty[$tagkey])"
                $resouceobj | Add-Member -MemberType NoteProperty -name cpu_total  -Value  $($cpu_total)
                $resouceobj | Add-Member -MemberType NoteProperty -name networkIn_total -Value  $($networkIn_total)
                $resouceobj | Add-Member -MemberType NoteProperty -name networkOut_total -Value   $($networkOut_total)
                $resouceobj | Add-Member -MemberType NoteProperty -name StartTime -Value  $($starttime)
                $resouceobj | Add-Member -MemberType NoteProperty -name EndTime -Value   $($EndTime)



                   
             # add the above string to an array
             [array]$Azureresourcedata +=  $resouceobj
      
           }
 
      $shutdowntargets  = $Azureresourcedata |where-object  cpu_total -eq 0 | select VMNAme, ResourceGroupName,ID, Tag, Tagvalue, cpu_total, networkIn_total, networkOut_total, StartTime, EndTime

      foreach($shutdownitem in  $shutdowntargets )
      {
          write-host " $($shutdownitem.VMNAme) - $($shutdownitem.ResourceGroupName)" -ForegroundColor green

            try
            {

                          Write-host "Stopping the VM : $($shutdownitem.VMName) " -ForegroundColor green
                 
                                Write-Output "Stopping the VM : $($shutdownitem.VMName) "

                                $Status = get-azvm -Name $($shutdownitem.VMName) -Status | stop-azvm -force

                                    if($Status -eq $null)
                                    {
                                        Write-Output "Error occured while stopping the Virtual Machine."
                                    }
                                    else
                                {
                                    Write-Output "Successfully stopped the VM  $($shutdownitem.VMName) "
                                    $VMState = (get-azvm -Name $($shutdownitem.VMName) -Status) | select name, powerstate
                                    Write-Output "$($VMState.name) - $($vmstate.PowerState)  "
                                }
           
            
           

            }
            catch
            {

                    Write-Warning " $($shutdownitem.VMNAme) is not a session host - Skipping" 
            }
    

      }







