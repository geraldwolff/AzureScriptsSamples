<#
Scriptname: \MANAGE_SHUTDOWN_TimeBase_monitor.ps1

the script reads a registry key and monitor for a time set by the user to shutdown 


Description: 
    Script is typically storad in c:\prgramdata\jobs folder and is 
    added to the scheduled task manager under the folder AVD_maintenance
    
    Script is deployed using Deploy_audit_scheduled_tasks_intervals_15Minute_Azvault.PS1 accompnaying this 
    script or can be added manually in the task scheduler. 
    
     
script will read registry entry created by MANAGE_SHUTDOWN_TimeBased_set.ps1 run to set the time for the VM to shutdown 


              "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostop" -Value "$($timetostop)" 
              "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timecheck" -Value " $timecheck"  
              "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timeleft" -Value "$hoursleft" 


        Once the current time reaches the time set to shutdown 
        this script will ready the creadential from the AZ keyvault for the service principal/managed Identity
        with permissions to execute the shutdown and deallocation
        and execute an Azure Clean shutdown and deallocation 

        This script will ready the registry keys with the tmmestamp every 15 minutes to see if it has reached its time.
#>

<########  Azure module 
'Az.DesktopVirtualization','az.avd', 'az' ,'az.keyvault','nuget' | foreach-object {

install-module -name $_ -allowclobber
import-module -name $_ -force

 update-module $_ -force

}
  

#######>

 
$vmName = "$env:computername"

 
#############################
 $account = connect-azaccount     -id #-Environment AzureUSGovernment 

 $sub = get-azsubscription -SubscriptionName $($account.Context.Subscription.Name)

 set-azcontext -Subscription $($sub.Name)

<#  
 $keyvault = 'wolffentpkeyvault'
 $serviceprincipal = 'wwolffadmin'
 
    $keyvaultname = (get-azkeyvault -name $keyvault) 
     
 
 
# Get the secret object from the Key Vault
$secret = Get-AzKeyVaultSecret -VaultName $($keyVaultName.VaultName) -Name  $serviceprincipal

# Get the secret value as a plain text string
$secretValue = $($secret.SecretValue)
   
#$ptsecret =  [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secretValue)) 
 $username = $($secret.Name)

# Authenticate with Azure AD using the application credentials
$credential = New-Object System.Management.Automation.PSCredential($username, $secretValue )

################################>

New-EventLog -source manage_shutdown_monitor  -LogName Application  -ErrorAction Ignore



########################
 $vminfo = get-azvm -name $VMNAME

$resourceGroup = "$($vminfo.ResourceGroupName)"
$location =  "$($vminfo.Location)"



$date = (get-date)

 

$configured_time  =  Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostop","Timecheck","Timeleft","Timetostopset", "Timetostopsetdate" | select Timecheck, TimetoStop , Timeleft ,Timetostopset, Timetostopsetdate
 


$timetostop = $($configured_time.Timetostop)


 
            $timecheck = (get-date)

            if( ($timecheck.DateTime -ge $($timetostop)) -and ($($configured_time.Timetostopset) -eq 'YES') )
            {
                                
                   Write-Host "$timecheck has reached thte time to stop at $timetostop - , shutting down VM" -ForegroundColor white -BackgroundColor red
                   

                   ####################  follow up and reboot run protection  - critical or VM will shutdown if scheduled task is enabled
                   ###########################################################################################################################
                   #################  Do not remove this section #############################################

                    $Timetostop  = ($date).AddMonths(12)
                   Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostopset" -Value "NO" -Force | Out-Null

               msg * /time:300 /w    "Server Shutdown in 5 minutes. Please save your work. You will be logged off in in 5 Minutes."

                     start-sleep -Seconds 300
                   ###########################################################################################################


                # Get the VM object
                $vm = Get-AzVM -Name $vmName -ResourceGroupName $resourceGroup

                # Stop the VM
                write-host " Stopping " -ForegroundColor red -NoNewline
                write-host " $($vmname) " -ForegroundColor blue -BackgroundColor white 

                Write-EventLog -LogName "Application" -Source "Manage_shutdown_monitor" -EventID 6667 -EntryType Information `
             -Message "shutting down and deallocating $($vm.name)." -Category 1 -RawData 10,20

                # Deallocate the VM
                write-host " Deallocating " -ForegroundColor green -NoNewline
                write-host " $($vmname) " -ForegroundColor Cyan

                  Stop-AzVM -Name $vmName -ResourceGroupName $resourceGroup -Force

                # Wait for the VM to stop
                do {
                    Start-Sleep -Seconds 10
                    $vm = Get-AzVM -Name $vmName -ResourceGroupName $resourceGroup
                } while ($vm.PowerState -ne "VM deallocated")


                 Set-AzVM -Name $vmName -ResourceGroupName $resourceGroup -Location $location -Deallocate -Force
                 

            }
            else 
            {
                  $processlist = get-process 

                $processes  = $processlist  | Sort-Object CPU  -descending | select -first 5  name, cpu   

                $Timeleft =  New-TimeSpan -Start $timecheck -End $timetostop | select hours, minutes

                $hoursleft = "$($Timeleft.hours):$($Timeleft.minutes)"

                write-host " $timecheck - the following are still running" -ForegroundColor Cyan
                 $processes  
                
        Write-EventLog -LogName "Application" -Source "Manage_shutdown_monitor" -EventID 6666 -EntryType Information `
             -Message "$($processes) still running." -Category 1 -RawData 10,20

             # Update the registry key to indicate that the script is shutting down the VM
 
                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timecheck" -Value " $timecheck" -Force | Out-Null
                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timeleft" -Value "$hoursleft" -Force | Out-Null

                Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostop","Timecheck","Timeleft","Timetostopset", "Timetostopsetdate" | select Timecheck, TimetoStop , Timeleft ,Timetostopset, Timetostopsetdate
 

               
            }

 
         
 








