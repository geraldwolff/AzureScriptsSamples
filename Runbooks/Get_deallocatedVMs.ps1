try
{
    "Logging in to Azure..."
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$subscription = "MSUSHPC2022"

#$Sub_Name = (Get-azAutomationVariable -Name "MSUSHPC2022" -ResourceGroupName 'wolffautorg' –AutomationAccountName "wolffautoadmin").value
set-azcontext -Subscription $subscription
  Get-azSubscription –SubscriptionName $subscription | Select-azSubscription

$RGs = Get-azResourceGroup 

foreach($RG in $RGs)
{
    $VMs = Get-azVM -ResourceGroupName $RG.ResourceGroupName

        foreach($VM in $VMs)
            {
                $date =Get-Date
                $hour=$date.Hour
                $VMstatus=(Get-azVM -Name $VM.Name -ResourceGroupName $RG.ResourceGroupName -Status).Statuses | where Code -like "PowerState*"
          
                $status=$VMstatus.displaystatus
                      write-host " $($vm.name) - $status" -ForegroundColor Green

                     if( $status -eq "VM deallocated")
                          {
                             ## Starting VM
                             get-azvm -ResourceGroupName $RG.ResourceGroupName -Name $VM.Name
                       # Start-azVM -ResourceGroupName $RG.ResourceGroupName -Name $VM.Name
                        }
                if($VM.Tags.Keys -contains "VMStartTimeinUTC")
                  {
                        $tag_value=$VM.Tags.VMStartTimeinUTC
                        $tag_time=$tag_value.Split(":")
                        $tag_hour=$tag_time[0]
  
                          $tag_hour_int=[int]$tag_hour
                     #   if($tag_hour_int -eq $hour -and $status -eq "VM deallocated")
                     if( $status -eq "VM deallocated")
                          {
                             ## Starting VM
                             get-azvm -ResourceGroupName $RG.ResourceGroupName -Name $VM.Name
                       # Start-azVM -ResourceGroupName $RG.ResourceGroupName -Name $VM.Name
                        }
   
                  }
       }
  }