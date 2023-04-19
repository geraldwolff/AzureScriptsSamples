 $account = connect-azaccount  #   -id #-Environment AzureUSGovernment 

 $subs = get-azsubscription # -SubscriptionName $($account.Context.Subscription.Name)


 $subscriptionlist = $subs | ogv -Title 'Select subscriptions as scope(s)'  -PassThru | select name,id, Tenantid



 foreach($subscription in $subscriptionlist)
 {

        # Set the Azure subscription ID, resource group name, and VM name
        $subscriptionId = "$($subscription.id)"
        
        Set-azcontext -subscription $($subscription.name)


        $vmlists = get-azvm 

        $vmselected  = $vmlists | ogv -Title "Select Vms to check" -PassThru 


        Foreach ($vm in $vmselected)
        {


                $resourceGroupName = "$($vm.resourcegroupname)"
                $vmName = "$($vm.name)"

                 # Get the VM object
                $vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

                # Get the current CPU usage and connected user count
                $vmresourceid = get-azresource -ResourceId $($vm.id) 

             #percentage cpu usage
             $cpu = Get-azMetric -ResourceId $vm.Id -MetricName "Percentage CPU" -DetailedOutput -StartTime (Get-Date).AddMinutes(-5)  `
             -EndTime (Get-Date) -TimeGrain 00:01:00  -WarningAction SilentlyContinue 


                $cpuUsage = $cpu  `
                    | Select-Object -ExpandProperty Data |
                    Select-Object -ExpandProperty Average |
                    Measure-Object -Average |
                    Select-Object -ExpandProperty Average

                  write-host " Average CPU usage in last hour: " -ForegroundColor cyan -NoNewline
                  Write-host " $cpuusage" -ForegroundColor white -BackgroundColor Blue
                

                $workspace = Get-AzWvdWorkspace -ResourceGroupName $($vm.ResourceGroupName) -SubscriptionId  $subscriptionId 

                $hostpool = Get-AzWvdHostPool -ResourceGroupName $($vm.ResourceGroupName) -SubscriptionId  $subscriptionId 
                $appgroup = Get-AzWvdApplicationGroup -ResourceGroupName $($vm.ResourceGroupName) -SubscriptionId  $subscriptionId 
                $sessionhost = Get-AzWvdSessionHost -HostPoolName $($hostpool.name) -ResourceGroupName $($vm.ResourceGroupName) -SubscriptionId  $subscriptionId 


                $connections =  Get-AzWvdSessionHost -ResourceGroupName $resourceGroupName -HostPoolName "$($hostpool.name)" `
                 -SubscriptionId $subscriptionId `
                     -Name $vmName

                   $usersessions =   Get-AzWvdUserSession -ResourceGroupName $ResourceGroupName -HostPoolName "$($hostpool.name)" | select -ExpandProperty sessionstate

                $connectedusernames = Get-AzWvdSessionHost -ResourceGroupName $resourceGroupName -HostPoolName "$($hostpool.name)" `
                 -SubscriptionId $subscriptionId `
                     -Name $vmName `
                    | Select-Object -ExpandProperty assigneduser


                $connectedUsers = Get-AzWvdSessionHost -ResourceGroupName $resourceGroupName -HostPoolName "$($hostpool.name)" `
                 -SubscriptionId $subscriptionId `
                     -Name $vmName `
                    | Select-Object -ExpandProperty session 

                $connectedUserCount = $connectedUsers | `
                    Measure-Object | `
                    Select-Object -ExpandProperty Count


                # Check if the conditions are met
                if ($connectedUsers -eq 0 -and $cpuUsage -lt 7) {
                  
                  write-host " Number of users still connected: " -ForegroundColor cyan -NoNewline
                  Write-host " $connecteduserCount" -ForegroundColor white -BackgroundColor Blue
                  Write-host " Assigned user: $($connectedusernames) - session status: $($usersessions)" -foregroundcolor green
                  
                    # If both conditions are true, deallocate the VM
                     Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force
                }
                else 
                {

                  write-host " Number of users still connected: " -ForegroundColor cyan -NoNewline
                  Write-host " $connecteduserCount" -ForegroundColor white -BackgroundColor Blue
                  Write-host " Assigned User $($connectedusernames) - session status:  $($usersessions)" -foregroundcolor green
                  Write-host " Will wait for users to disconnect " -ForegroundColor Red -BackgroundColor white

                }
    }


}

 

<#################################### Restapi assignment to session host 
 

 ######### working update

        $settings=@{
            Properties=@{
                assignedUser="$($account.Context.Account.id)"
                allowNewSession=$sessionHost.AllowNewSession
            }
        }            
        Invoke-AzRestMethod -Path "$($sessionHost.Id)?api-version=2022-09-09&force=true" -method 'PATCH' -Payload (ConvertTo-Json -InputObject $settings)


#>







