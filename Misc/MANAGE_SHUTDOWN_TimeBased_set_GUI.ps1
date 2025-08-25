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
 


########  Azure modules  uncommenct and run if this is the firt time executed
  'az', 'Az.network','az.avd','az.keyvault','nuget','ps2exe' | foreach-object {


  if((Get-InstalledModule -name $_))
  { 
    Write-Host " Module $_ exists  - will import" -ForegroundColor Green
       #  update-module $_ -force
    }
    else
    {
    write-host "module $_ does not exist - installing" -ForegroundColor red -BackgroundColor white
     
        install-module -name $_ -allowclobber -force | out-null
       
    }
     import-module -name $_ -force | out-null
   #  Get-InstalledModule
}

########>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
 
New-EventLog -source manage_shutdown_monitor  -LogName Application  -ErrorAction Ignore 
 
$vmName = "$env:computername"

 
$timelist = ''

 


function set_stop_time
{

        $form = New-Object System.Windows.Forms.Form
        $form.Text = 'Select Date and Time for the shutdown'
        $form.Size = New-Object System.Drawing.Size(300,200)
        $form.StartPosition = 'CenterScreen'

        $dateTimePicker = New-Object System.Windows.Forms.DateTimePicker
        $dateTimePicker.Format = [System.Windows.Forms.DateTimePickerFormat]::Custom
        $dateTimePicker.CustomFormat = 'MM/dd/yyyy hh:mm'
        $dateTimePicker.MinDate = Get-Date
        $dateTimePicker.MaxDate = (Get-Date).AddDays(2)
        $dateTimePicker.ShowUpDown = $true
        $dateTimePicker.Location = New-Object System.Drawing.Point(20,20)
        $dateTimePicker.Width = 260

        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Location = New-Object System.Drawing.Point(100,100)
        $okButton.Size = New-Object System.Drawing.Size(75,23)
        $okButton.Text = 'OK'
        $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK

        $form.AcceptButton = $okButton

        $form.Controls.Add($dateTimePicker)
        $form.Controls.Add($okButton)

        $result = $form.ShowDialog(((New-Object System.Windows.Forms.Form -Property @{TopMost = $true })))

        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            $selectedDateTime = $dateTimePicker.Value
            #Write-Output "Selected Date and Time: $($selectedDateTime.ToString('MM/dd/yyyy hh:mm'))"
        }
        return($selectedDateTime)
}

 

 $selectedDateTime = set_stop_time
 
 #$selectedDateTime


#####################################################################
 $selectedDateTime =   $selectedDateTime
      
            $timecheck = (get-date)
 
                $processlist = get-process 
                     $processes  = $processlist  | Sort-Object CPU  -descending | select -first 5  name, cpu   

                $Timeleft =  New-TimeSpan -Start $timecheck -End $selectedDateTime | select hours, minutes

                $hoursleft = "$($Timeleft.hours):$($Timeleft.minutes)"

 


             # create  the registry key to indicate when the script is shutting down the VM
             
               # New-Item -Path "HKLM:\Software" -Name "MANAGE_SHUTDOWN" -Force

                ###  Get old registry settings 
                if (!($configured_time  =  Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart", "Timetostop","Timecheck","Timeleft","Timetostopset", "Timetostopsetdate","resettime" | select InitialStart, Timecheck, TimetoStop , Timeleft ,Timetostopset, Timetostopsetdate,Resettime ) )
                {


                #############  Set new times
                
                New-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart" -Value "$($configured_time.InitialStart)" -Force #| Out-Null

                New-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostop" -Value "time to be set" -Force #| Out-Null

                New-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timecheck" -Value "time to be set" -Force #| Out-Null
                
                New-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timeleft" -Value " " -Force #| Out-Null

                New-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostopset" -Value "YES" -Force #| Out-Null


                New-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostopsetdate" -Value "$timecheck" -Force #| Out-Null
            }

        

                ################################ Update the registry key

                set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart" -Value "$timecheck" -Force #| Out-Null

        
                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostopset" -Value "YES" -Force #| Out-Null
 
                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostop" -Value "$($selectedDateTime)" -Force | Out-Null

                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timecheck" -Value "$timecheck" -Force | Out-Null

                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timeleft" -Value "$hoursleft" -Force | Out-Null


                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Resettime" -Value "Yes" -Force | Out-Null


           $settings = Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart","Timetostop","Timecheck","Timeleft", "Timetostopset", "Timetostopsetdate","resettime"  | select InitialStart, Timecheck, TimetoStop , Timeleft , Timetostopset, Timetostopsetdate.resettime
 
                Write-EventLog -LogName "Application" -Source "Manage_shutdown_monitor" -EventID 6666 -EntryType Information `
             -Message "Set time to Timetostop  Registry for monitor $timecheck" -Category 1 -RawData 10,20




              [datetime]$timestostop = get-date    $($settings.Timetostop)

                $Timeleft =  New-TimeSpan -Start $timecheck -End $timestostop  

                $hoursminutesleft = "$($Timeleft.hours):$($Timeleft.minutes)"


                
                         $daysleft  = New-TimeSpan -Start $timecheck -End $timestostop | select days 
                         $hoursleft = New-TimeSpan -Start $timecheck -End $timestostop | select  hours 
                         $minutesleft = New-TimeSpan -Start $timecheck -End $timestostop | select  minutes


                    Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Daysleft" -Value "$($Daysleft.Days)" -Force  | Out-Null

                    Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Hoursleft" -Value "$($hoursleft.Hours)" -Force  | Out-Null                                                        

                    Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Minutesleft" -Value "$($Minutesleft.Minutes)" -Force  | Out-Null


             $confirmationmsg = "Confirmation time set to $timestostop  $($daysleft.Days) Days $($hoursleft.hours) Hours $($minutesleft.Minutes) Minutes "




              msg $env:USERNAME /time:300 /w $confirmationmsg

              Start-Sleep -seconds 30 


              try
              {
                $countdown = get-process -name countdown_clock -ErrorAction Ignore  | Stop-Process -force -ErrorAction Ignore      | Out-Null
              }
              catch
              {}
            


