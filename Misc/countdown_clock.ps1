<#

Scriptname: AVd_Shutdown Countdown Clock 

Description: Count down clock for manage Shutdown to pop up a visible countdown clock when time remaining is 15 minutes or less 
             Once the countdown is down to seconds, the color of the time will become larger and red. 
             Once the countdown is zero or a few seconds less, the script will produce a message stating it is shutting down and will 
             will make a call to azure shd shut down the VM

 

#>


$vmName = "$env:computername"

 
#############################
 $account = connect-azaccount     -id #-Environment AzureUSGovernment 

 $sub = get-azsubscription -SubscriptionName $($account.Context.Subscription.Name)

 set-azcontext -Subscription $($sub.Name) | out-null

  
########################
 $vminfo = get-azvm -name $VMNAME

$resourceGroup = "$($vminfo.ResourceGroupName)"
$location =  "$($vminfo.Location)"

$date = (get-date)

Function shutdown_vm 
{

         ##########################################

                            Write-EventLog -LogName "Application" -Source "Manage_shutdown_monitor" -EventID 6668 -EntryType Information `
                -Message "Shutdowun Executed @  $Timecheck " -Category 1 -RawData 10,20
                                         
            #       Write-Host "$timecheck has reached the time to stop at $timetostop - , shutting down VM" -ForegroundColor white -BackgroundColor red
                   
                   $shuttingdownmessage = "$timecheck has reached the time to stop at $timetostop 
                   ******* shutting down VM $VMNAME ******"

                     msg * /time:900  $shuttingdownmessage

                     $timecheck = (get-date)

                     $Timetostop  = ($date).AddMonths(12)
    
                    $stopresettime =  New-TimeSpan -Start $timecheck -End $Timetostop

                    $hoursminutesleft = "$($Timeleft.hours):$($Timeleft.minutes)"


                
                             $daysleft  = New-TimeSpan -Start $date -End $Timetostop| select days 
                             $hoursleft = New-TimeSpan -Start $date  -End $Timetostop | select  hours 
                             $minutesleft = New-TimeSpan -Start $date  -End $Timetostop | select  minutes

 

                 # Update the registry key to indicate that the script is shutting down the VM

                    ####################  follow up and reboot run protection  - critical or VM will shutdown if scheduled task is enabled
                   ###########################################################################################################################
                   #################  Do not remove this section #############################################

                  
                   Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostop" -Value "$Timetostop" -Force | Out-Null
                   Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostopset" -Value "NO" -Force | Out-Null
                   Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart" -Value "" -Force | Out-Null

 
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timecheck" -Value "$date" -Force | Out-Null
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timeleft" -Value "$stopresettime" -Force | Out-Null

                    Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Daysleft" -Value "$($Daysleft.Days)" -Force  | Out-Null

                    Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Hoursleft" -Value "$($hoursleft.Hours)" -Force  | Out-Null                                                        

                    Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Minutesleft" -Value "$($Minutesleft.Minutes)" -Force  | Out-Null

                   Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Resettime" -Value "Yes" -Force  | Out-Null

                 #   Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart", "Timetostop","Timecheck","Timeleft","Timetostopset", "Timetostopsetdate" , "GraceTime",  "Daysleft","Hoursleft","Minutesleft" 
                         


         ###########################################################################################################


                # Get the VM object
                $vm = Get-AzVM -Name $vmName -ResourceGroupName $resourceGroup

                # Stop the VM
             #   write-host " Stopping " -ForegroundColor red -NoNewline

             #   write-host " $($vmname) " -ForegroundColor blue -BackgroundColor white 

                Write-EventLog -LogName "Application" -Source "Manage_shutdown_monitor" -EventID 6668 -EntryType Information `
                -Message "shutting down.-- $configured_time " -Category 1 -RawData 10,20

                 Stop-AzVM -Name $vmName -ResourceGroupName $resourceGroup -Force | out-null

                # Wait for the VM to stop
                do {
                    Start-Sleep -Seconds 10
                    $vm = Get-AzVM -Name $vmName -ResourceGroupName $resourceGroup
                } while ($vm.PowerState -ne "VM deallocated")

                # Deallocate the VM
             #   write-host " Deallocating " -ForegroundColor green -NoNewline
              #  write-host " $($vmname) " -ForegroundColor Cyan

                 Set-AzVM -Name $vmName -ResourceGroupName $resourceGroup -Location $location -Deallocate -Force | out-null



}
 
 #################################################################

$configured_time  =  Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart", "Timetostop","Timecheck","Timeleft","Timetostopset", "Timetostopsetdate" ,"GraceTime", "daysleft","hoursleft","minutesleft" ,"Resettime"

   $timecheck = (get-date)
            $Timeleft =  New-TimeSpan -Start $timecheck -End $($configured_time.Timetostop)  

    $path = Split-Path $psISE.CurrentFile.FullPath 

 sl $path

$icon = (get-childitem -Path $path -Recurse -file   'wolfftools_events_trracker.ico').FullName

    


if($($configured_time.Timetostopset) -eq 'Yes') 
{


         [int]$delay =  $Timeleft.totalseconds 

        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        [System.Windows.Forms.Application]::EnableVisualStyles()

        $monitor = [System.Windows.Forms.Screen]::PrimaryScreen

        [void]::$monitor.WorkingArea.Width

        $form = New-Object System.Windows.Forms.Form
        $form.Text = 'Shutdown Counter'
        $form.ClientSize = ‘350,180’
        $form.Height = 150
        $form.Width = 550
        $form.StartPosition = "manual"
        $form.Left = $monitor.WorkingArea.Width - $form.Width
        $form.Top = 0
        #$form.Location = New-Object System.Drawing.Point(1000,0)
        $form.AutoSize = $true
        $form.TopMost = $true
        $Image = [system.drawing.image]::FromFile("$icon")
        $form.BackgroundImage = $Image

        $form.BackgroundImage = $Image
        $Counter_Label = New-Object System.Windows.Forms.Label
        $Counter_Label.AutoSize = $true
        $Counter_Label.ForeColor = "Green"
        $normalfont = New-Object System.Drawing.Font("Times New Roman",14)
        $Counter_Label.Font = $normalfont
        $Counter_Label.Left = 20
        $Counter_Label.Top = 20

        $form.Controls.Add($Counter_Label)
 

         $timecheck = (get-date)

        $configured_time  =  Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart", "Timetostop","Timecheck","Timeleft","Timetostopset", "Timetostopsetdate" ,"GraceTime", "daysleft","hoursleft","minutesleft" ,"Resettime"

         $timecheck = get-date -Format "dddd MM/dd/yyyy HH:mm"
         $Timeleft =  New-TimeSpan -Start $timecheck -End $($configured_time.Timetostop) 
         $delaytime =  New-TimeSpan -Start $timecheck -End $($configured_time.Timetostop)

                    Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Daysleft" -Value "$($Daysleft.Days)" -Force  | Out-Null

                    Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Hoursleft" -Value "$($hoursleft.Hours)" -Force  | Out-Null                                                        

                    Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Minutesleft" -Value "$($Minutesleft.Minutes)" -Force  | Out-Null

                    Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timeleft" -Value "$Timeleft" -Force  | Out-Null
                     

        if($delay -le 0 -and $Timeleft -le 0)

        {

             shutdown_vm 

        }

        while ($delay -ge 0)
        {
    
   
           ###########################################
      
              $form.show()  

          $Counter_Label.Text = "Time Remaining: $delaytimelabel"


          if ($delay -lt 5)
          { 
             $Counter_Label.ForeColor = "Red"
             $fontsize = 20-$delay
             $warningfont = New-Object System.Drawing.Font("Times New Roman",$fontsize,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Underline))
             $Counter_Label.Font = $warningfont
          } 

          if ($delay -le 0 -and $($configured_time.Timetostopset) -eq 'Yes')
          { 

                shutdown_vm 
        
          }


  
          start-sleep -seconds 1

         $delay  = $delay -1

  
          $delayminutes = $delay/60

        $configured_time  =  Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart", "Timetostop","Timecheck","Timeleft","Timetostopset", "Timetostopsetdate" , "daysleft","hoursleft","minutesleft" 

         $timecheck = (get-date)
         $Timeleft =  New-TimeSpan -Start $timecheck -End $($configured_time.Timetostop)
          $delaytime =  New-TimeSpan -Start $timecheck -End $($configured_time.Timetostop)   
          $delaytimelabel  =  " $($delaytime.Days) Days  $($delaytime.hours) - Hours $($delaytime.minutes) Minutes - $($delaytime.seconds) Seconds"
            # $delaytimelabel
          $delayminutes =    $delaytime.TotalMinutes 
  

          }

}
else
{
$countdownmsg = "A Time to Shutdown has not been set - Countdown not triggered  $Timecheck" 
 

     msg * /time:900  $countdownmsg 

            Write-EventLog -LogName "Application" -Source "Manage_shutdown_monitor" -EventID 6669 -EntryType Information `
                -Message "Countdown not Initiated as a shutdown was never set : $Timecheck " -Category 1 -RawData 10,2

}




# SIG # Begin signature block
# MIIFlAYJKoZIhvcNAQcCoIIFhTCCBYECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUo4DiLgDnlgfOWUX7dQB8H9af
# zwOgggMiMIIDHjCCAgagAwIBAgIQKqsA84kv7btM8F7chJSp3DANBgkqhkiG9w0B
# AQsFADAnMSUwIwYDVQQDDBxQb3dlclNoZWxsIENvZGUgU2lnbmluZyBDZXJ0MB4X
# DTIzMDYyMjE2MDUwMFoXDTI0MDYyMjE2MjUwMFowJzElMCMGA1UEAwwcUG93ZXJT
# aGVsbCBDb2RlIFNpZ25pbmcgQ2VydDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
# AQoCggEBANZxKQTSq89x5Q5X3K8a55tdHRQD4vf/1HKIm3P65jWyvLDcA52SF3Im
# 2k8tb3+pFG7II3nT/wGOHd2rJHYPekujGHGx52khzhDqzLNm9E1Vw2Ug/zgBZY7q
# /yIDsW/ubdrW5pRnULkKZI6kSrDfX/qYjhZ9yygKW2ssRRaMwNTUDbEcqQKHygGa
# WM3AfFE7HPqe2i2EgatJqLmVis+tdi2znxY2ywHPY+1xcEe4WT5Sz1UcMzQyMJoJ
# saXdfP0Oz8b5rtrlnu6OnHf1wYF5BhsJD1o2kZSPDFGO5YivdbVFZcc/+3WMMgs6
# CdFOTjnAoWnxbzYchjr+GYZZVVZd6c0CAwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeA
# MBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBR8lk3isXfG9kYVZgqZLmrn
# OaMT5TANBgkqhkiG9w0BAQsFAAOCAQEAXtoPobBq8Ai43yWgWUh4CEq+FQGToKr5
# hjGUsOgz9diXralI8NRlTbAhNRTxDbCiMsLuYuTiDpCAjv9AAjFyH6SOQN9Lxg60
# FtiyYdOsaCtyyGFplHSo7OWU26oZmxbyeoZAvGeRx9I2nkRNvhUYklvyuHG+WsQw
# BO4zPPLBFFfys3IDDLCp8upAgQZBZYGETnVe2l39vC+Zc0kaxuOwGH0Q8pcZFSLz
# EIj2/DaBJaE4dKZD9hAo4XlZzqGFq7AZslAK64XyLhMYKOCCWjSVNMFtPurEGGw/
# E3Ph4A8A5cb4BX1sh7B0P1MC4T0fJX7yjpkRzkzI9QJWClphxnrMAzGCAdwwggHY
# AgEBMDswJzElMCMGA1UEAwwcUG93ZXJTaGVsbCBDb2RlIFNpZ25pbmcgQ2VydAIQ
# KqsA84kv7btM8F7chJSp3DAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUXOGu2xwsVx2GG+lW51Yb
# pB373IkwDQYJKoZIhvcNAQEBBQAEggEAFETZpAdheGuAWMVCYodZo13fnUOLZzN4
# 2KNRQJ61uHOucpvlvS93pbbr++7iZuDzcRktftT1B0scxobPxu0Sj0NroPe4mBJ/
# EnxlfNPmC3H2sJDdx32lGITBYpYMwFvlXnmj5//gfrLxGWLk+T4XiAyslFBvCm1I
# DAtXylxW5ztw3XXCMg90hnM8aGqwV0ATN1Tv4eM+0/m/NIkS8J7SW+crAzhVhsh8
# LnRlXhn3ow3Grddq7O69MEys2SodHZLZihkBPXqxPnsw2Uf4ThwCGN4E6loY+K/p
# su7pGsOP7pzvNVUeALo1cq5CcHMX44c8OrPP3WeR8ig6KlBheM208w==
# SIG # End signature block
