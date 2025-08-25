<#

the script creates a registry key indicating that the script is 
starting up by using the New-ItemProperty cmdlet to create a new registry 
value in the HKLM:\SOFTWARE\MANAGE_SHUTDOWN key. The script then updates the value 
of the registry key to indicate that the script
 is ready to monitor the process using the Set-ItemProperty cmdlet.

Use Case: User runs this script to set the time whn the VM can be shutdown 
Selection will make an entry in the registry and a secondary scheduled task will read the entries and monitor 
for when to shut down

Registry setting can be viewed by running:
  ps1>: Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostop","Timecheck","Timeleft"  | select Timecheck, TimetoStop , Timeleft 
 
#>

<########  Azure modules  uncommenct and run if this is the firt time executed
'Az.DesktopVirtualization','az.avd', 'az' ,'az.keyvault','nuget' | foreach-object {

install-module -name $_ -allowclobber
import-module -name $_ -force

 update-module $_ -force

}


#######>

 
 
$vmName = "$env:computername"

 
$timelist = ''

$timepoint = (get-date)
$timeend = (get-date).AddDays(1)
$i = 0

do
{   

    [array]$timelist += $timepoint.AddHours($i)
   $i = ($i + 1)
 # $i
 # $timelist
} until ($timepoint.AddHours($i) -ge $($timeend) )
 


$timetostop = $($timelist.datetime)   | OGV -Title "Please pick a time to Stop/Complete work" -PassThru | Select -First 1 
 
 
 
      
            $timecheck = (get-date)
 
                $processlist = get-process 
                     $processes  = $processlist  | Sort-Object CPU  -descending | select -first 5  name, cpu   

                $Timeleft =  New-TimeSpan -Start $timecheck -End $timetostop | select hours, minutes

                $hoursleft = "$($Timeleft.hours):$($Timeleft.minutes)"

                write-host " $timecheck - the following are still running" -ForegroundColor Cyan
                 write-host " " 

                $processes | ft -auto

             # create  the registry key to indicate when the script is shutting down the VM
             
                New-Item -Path "HKLM:\Software" -Name "MANAGE_SHUTDOWN" -Force


                New-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostop" -Value "time to be set" -Force #| Out-Null

                New-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timecheck" -Value "time to be set" -Force #| Out-Null
                
                New-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timeleft" -Value " " -Force #| Out-Null

                New-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostopset" -Value "YES" -Force #| Out-Null


                New-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostopsetdate" -Value "$timecheck" -Force #| Out-Null

                "Timetostopset", "Timetostopsetdate"
                ################################ Update the registry key
 
                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostop" -Value "$($timetostop)" -Force | Out-Null

                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timecheck" -Value " $timecheck" -Force | Out-Null
                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timeleft" -Value "$hoursleft" -Force | Out-Null

                Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostop","Timecheck","Timeleft", "Timetostopset", "Timetostopsetdate"  | select Timecheck, TimetoStop , Timeleft , Timetostopset, Timetostopsetdate
 
                Write-EventLog -LogName "Application" -Source "Manage_shutdown_monitor" -EventID 6666 -EntryType Information `
             -Message "Set time to Timetostop  Registry for monitor $timecheck" -Category 1 -RawData 10,20








