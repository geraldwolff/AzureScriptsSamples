
<# 

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


$ErrorActionPreference = 'silentlyContinue'

Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

$VMStats = ''

         $subscriptions = Get-azSubscription 

 foreach($subscription in $subscriptions)
 {
            Set-azcontext -Subscription $Subscription.Name

            $vms = get-azvm -status

                foreach($vm in $vms)
                {
                


                     $Network =  Get-azMetric -ResourceId $($vm.id) -TimeGrain 00:01:00   -MetricNames "Network in"
                     $CPU_Remaining =   Get-azMetric -ResourceId $($vm.id) -TimeGrain 00:01:00   -MetricNames "CPU Credits Remaining"
                     $CPU_Credits_Remaining =    Get-azMetric -ResourceId $($vm.id) -TimeGrain 00:01:00   -MetricNames "CPU Credits Consumed"
                     $Percentage_CPU =   Get-azMetric -ResourceId $($vm.id) -TimeGrain 00:01:00   -MetricNames "Percentage CPU"
                    
 
 
                       $total_network_In =  ($network.Data | select -first 1  total)


                        $Total_CPU_Remaining = ($CPU_Remaining.data | select -first 1  total)

                        $Total_CPU_Credits_Remaining =  ($CPU_Credits_Remaining.Data | select -first 1  total)

    
                        $Total_Percentage_CPU =   ($Percentage_CPU.Data | select -first 1  total)

                        $vmmetricsobj = New-object PSObject 

                        $vmmetricsobj | Add-Member -MemberType NoteProperty -Name  VMNAME -Value    $($VM.name)
                        $vmmetricsobj | Add-Member -MemberType NoteProperty -Name  total_network_In -Value    $($total_network_In.Total)
                        $vmmetricsobj | Add-Member -MemberType NoteProperty -Name  averageNetwork -Value    $($total_network_In.Average)
                        $vmmetricsobj | Add-Member -MemberType NoteProperty -Name  Total_CPU_Remaining -Value    $($Total_CPU_Remaining.Total)
                        $vmmetricsobj | Add-Member -MemberType NoteProperty -Name  Total_CPU_Credits_Remaining -Value    $($Total_CPU_Credits_Remaining.Total)
                        $vmmetricsobj | Add-Member -MemberType NoteProperty -Name  Total_Percentage_CPU -Value    $($Total_Percentage_CPU.Total)
                        $vmmetricsobj | Add-Member -MemberType NoteProperty -Name  Powerstate -Value   $($vm.PowerState)
                        $vmmetricsobj | Add-Member -MemberType NoteProperty -Name  Subscription -Value  $($subscriptionname)
                        $vmmetricsobj | Add-Member -MemberType NoteProperty -Name  ResourceGroup -Value    $($VM.ResourceGroupName)
              

                      [array]$VMStats += $vmmetricsobj


                    }


 

 }


 $VMStats
