<#


      Add-Type -AssemblyName PresentationCore,PresentationFramework
      $Result = [System.Windows.MessageBox]::Show(MessageBody,Title,ButtonType,Image)

#>   
      $Reg_settings  =   Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart","Timetostop","Timecheck","Timeleft", "Timetostopset", "Timetostopsetdate" , "daysleft","hoursleft","minutesleft" ,"Resettime"
 
            

    
          Add-Type -AssemblyName PresentationCore,PresentationFramework
 
      #  import-module az -force | out-null
 
   
          $account  = connect-azaccount   -id
          $subscription = (get-azcontext).Subscription
          $subscriptionid = $subscription.Id

          
           $azcontext =     Set-azcontext -subscription $($subscription.name) | out-null


                $vm = get-azvm -Name "$env:computername"

          $hostpools = Get-AzWvdHostPool 
  
 
          foreach($hostpool in $hostpools)
          {

           $sessionhost = Get-AzWvdSessionHost -HostPoolName  "$($hostpool.name)" -ResourceGroupName "$($vm.ResourceGroupName)" -SubscriptionId  "$subscriptionId" | Where-Object {$_.name -like "*$($vm.name)*"}
 
  
          }
  
         $sessionhost = Get-AzWvdSessionHost -HostPoolName  $($hostpool.name) -ResourceGroupName $($vm.ResourceGroupName) -SubscriptionId  $subscriptionId 


                        $connections =  Get-AzWvdSessionHost -ResourceGroupName $($vm.ResourceGroupName) -HostPoolName "$($hostpool.name)" `
                         -SubscriptionId $subscriptionId `
                             -Name $($vm.name)
     
                           $usersessions =   Get-AzWvdUserSession -ResourceGroupName $($vm.ResourceGroupName) -HostPoolName "$($hostpool.name)" | select -ExpandProperty sessionstate
       
                        $connectedusernames = Get-AzWvdSessionHost -ResourceGroupName $($vm.ResourceGroupName)  -HostPoolName "$($hostpool.name)" `
                         -SubscriptionId $subscriptionId `
                             -Name $($vm.name) `
                            | Select-Object -ExpandProperty assigneduser
  
           
  
   
  
  ###############################################################


    $RawOuput = (quser) -replace '\s{2,}', ',' | ConvertFrom-Csv
    
   # $RawOuput 
    $sessionID = $null


    Foreach ($session in $RawOuput) 
    {  
 
                     if($session.STATE -eq "Active"){      
                        $sessionName = $($session.sessionname)
                        $sessionid = $($session.id)
    #    $sessionID  



         Send-AzWvdUserSessionMessage -ResourceGroupName $($vm.ResourceGroupName) `
                                             -HostPoolName $($hostpool.name) `
                                             -SessionHostName $($vm.Name) `
                                             -UserSessionId $sessionid `
                                             -MessageBody 'You have reached the end of your grace time to setup a shutdown estimated time' `
                                             -MessageTitle 'Friendly Reminder !!!!!!'  `
                                             -erroraction Ignore


    }
 
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
 
        New-EventLog -source manage_shutdown_monitor  -LogName Application  -ErrorAction Ignore 
 
        $vmName = $($vm.Name)

 
        $timelist = ''
 

 function set_stop_time
  {

            $form = New-Object System.Windows.Forms.Form
            $form.Text = 'Select Date and Time for the shutdown'
            $form.Size = New-Object System.Drawing.Size(370,200)
            $form.StartPosition = 'CenterScreen'
            $form.TopMost = $true

            $dateTimePicker = New-Object System.Windows.Forms.DateTimePicker
            $dateTimePicker.Format = [System.Windows.Forms.DateTimePickerFormat]::Custom
            $dateTimePicker.CustomFormat = 'MM/dd/yyyy hh:mm'
            $dateTimePicker.MinDate = (get-date).AddMinutes(15)
            $dateTimePicker.MaxDate = (Get-Date).AddDays(2)
            $dateTimePicker.ShowUpDown = $true
            $dateTimePicker.Location = New-Object System.Drawing.Point(20,20)
            $dateTimePicker.Width = 300

            $okButton = New-Object System.Windows.Forms.Button
            $okButton.Location = New-Object System.Drawing.Point(100,100)
            $okButton.Size = New-Object System.Drawing.Size(75,23)
            $okButton.Text = 'OK'
            $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK

            $form.AcceptButton = $okButton


            #Setup and handle the cancel button
             $Cancel_button = New-Object System.Windows.Forms.Button
            $Cancel_button.Location = New-Object System.Drawing.Point(200,100)
            $Cancel_button.Size = New-Object System.Drawing.Size(75,23)
            $Cancel_button.Text = 'Leave as Is'
            $Cancel_button.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $Cancel_button.Add_Click({$form.Close() })

            $form.Controls.Add($Cancel_button)
 
            $form.Controls.Add($dateTimePicker)
            $form.Controls.Add($okButton)
            $form.Controls.Add($Cancel_button)
            $form.ControlBox = $false


            $form.Add_Closing({param($sender,$e)

                    $result = [System.Windows.Forms.MessageBox]::Show(`
                        "Are you sure you want to exit?", `
                        "Close", [System.Windows.Forms.MessageBoxButtons]::YesNoCancel)

                    if ($result -ne [System.Windows.Forms.DialogResult]::Yes)
                    {
                        $e.Cancel= $true
                        

                    }

                   if ($result -eq [System.Windows.Forms.DialogResult]::Yes -and $okButton.DialogResult -eq 'OK')
                  {
                        $selectedDateTime = $dateTimePicker.Value


                    }
                })
    



           # $result = $form.ShowDialog(((New-Object System.Windows.Forms.Form -Property @{TopMost = $true })))
            
            while($form.showdialog(((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))) -eq [System.Windows.Forms.DialogResult]::OK)
            {
 
                if  ($okButton.DialogResult -eq [System.Windows.Forms.DialogResult]::OK )
                 {
                          $selectedDateTime = $dateTimePicker.Value
                        #Write-Output "Selected Date and Time: $($selectedDateTime.ToString('MM/dd/yyyy hh:mm'))"
                           
                   } 
          
                          return($selectedDateTime)

            }
 
 }




 ####################################################################################

if( $($reg_settings.Resettime) -NE 'No')
{

                $msgBoxInput =  [System.Windows.MessageBox]::Show("Do you wish to extend your time or just continue with shutdown @ $($olddate.timetostop) ?",'Extend??','YesNoCancel','Error')

              switch  ($msgBoxInput) {

                      'Yes' {
                           
                            
                              $selectedDateTime = set_stop_time

                              $reset = 'Yes'

                           }

                      'No' {
  
                                  $reset = 'No'
                                  

                            } 

                      'Cancel'
                      {
 
         
                                  $reset = 'No'
                      }  
                }

       

   
        
        ####################################################################


                        [datetime]$timecheck = (get-date)
 
 


                             if($selectedDateTime)
                             {

                                  $Timeleft =  New-TimeSpan -Start $timecheck -End $selectedDateTime 

                                 $daysleft  = New-TimeSpan -Start $timecheck -End $selectedDateTime| select days 
                                 $hoursleft = New-TimeSpan -Start $timecheck -End $selectedDateTime | select  hours 
                                 $minutesleft = New-TimeSpan -Start $timecheck -End $selectedDateTime | select  minutes

                                 $timelefttxt = "$($daysleft.Days) Days $($hoursleft.Hours) Hours $($minutesleft.Minutes) Minutes"

                                ################################ Update the registry key

                                set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart" -Value "$timecheck" -Force  | Out-Null

        
                                set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Resettime" -Value "Yes" -Force  | Out-Null

                                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostopset" -Value "YES" -Force  | Out-Null
 
                                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostop" -Value $selectedDateTime -Force | Out-Null

                                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timecheck" -Value "$timecheck" -Force | Out-Null

                                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timeleft" -Value "$timeleft" -Force | Out-Null


                                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Daysleft" -Value "$($Daysleft.Days)" -Force  | Out-Null

                                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Hoursleft" -Value "$($hoursleft.Hours)" -Force  | Out-Null                                                        

                                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Minutesleft" -Value "$($Minutesleft.Minutes)" -Force  | Out-Null
                             }
                             else
                             {
                             
                             $old_settings =   Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart","Timetostop","Timecheck","Timeleft", "Timetostopset", "Timetostopsetdate" , "daysleft","hoursleft","minutesleft" ,"Resettime"
 
                  

                              $old_settingstimetostop = $($old_settings.Timetostop)
                              $old_settingshoursleft = $($old_settings.hoursleft) 
                              $old_settingsdaysleft = $($old_settings.daysleft) 
                              $old_settingsminutesleft = $($old_settings.minutesleft)


                                set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Resettime" -Value "No" -Force  | Out-Null
    
                                set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart" -Value "$($old_settings.timecheck)" -Force  | Out-Null

        
                                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostopset" -Value "$($old_settings.Timetostopset)" -Force  | Out-Null
 
                                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timetostop" -Value $old_settingstimetostop -Force | Out-Null

                                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timecheck" -Value "$timecheck" -Force | Out-Null

                                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Timeleft" -Value "$($old_settings.timeleft)" -Force | Out-Null


                                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Daysleft" -Value "$old_settingsdaysleft" -Force  | Out-Null

                                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Hoursleft" -Value "$old_settingshoursleft" -Force  | Out-Null                                                        

                                Set-ItemProperty -Path "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "Minutesleft" -Value "$old_settingsminutesleft" -Force  | Out-Null


                             }
         
}  ### ifreset end 

                    #######################################################

      $confirmation_settings =   Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart","Timetostop","Timecheck","Timeleft", "Timetostopset", "Timetostopsetdate" , "daysleft","hoursleft","minutesleft" ,"Resettime"
 
                  

                      $msgtimetimetostop = $($confirmation_settings.Timetostop)
                      $msgtimehoursleft = $($confirmation_settings.hoursleft) 
                      $msgtimedaysleft = $($confirmation_settings.daysleft) 
                      $msgtimeminutesleft = $($confirmation_settings.minutesleft)

                      $resetmessage ="Time has been reset to: $($msgtimetimetostop) with   $($msgtimedaysleft) days : $($msgtimehoursleft) hours $($msgtimeminutesleft) Minutes left"

                      $leaveasismsg = "Time not reset to: $($msgtimetimetostop) with   $($msgtimedaysleft) days : $($msgtimehoursleft) hours $($msgtimeminutesleft) Minutes left"

                      If ($reset -eq 'yes')
                      {
                        $message = $resetmessage
                      }
                      Else
                      {
                         $message = $leaveasismsg
                                              }
 

    
               #   msg $env:USERNAME /time:10 /w    "$message"


                                 Send-AzWvdUserSessionMessage -ResourceGroupName $($vm.ResourceGroupName) `
                                             -HostPoolName $($hostpool.name) `
                                             -SessionHostName $($vm.Name) `
                                             -UserSessionId $sessionid `
                                             -MessageBody "$message" `
                                             -MessageTitle 'Settings confirmed !'  `
                                             -erroraction Ignore

 


                      #  Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart","Timetostop","Timecheck","Timeleft", "Timetostopset", "Timetostopsetdate"  | select InitialStart, Timecheck, TimetoStop , Timeleft , Timetostopset, Timetostopsetdate
 
                        Write-EventLog -LogName "Application" -Source "Manage_shutdown_monitor" -EventID 6666 -EntryType Information `
                     -Message "Set time to $Timetostop  Registry for monitor $timecheck" -Category 1 -RawData 10,20

                            Start-Sleep -seconds 30 

                            $timecheck = (get-date)


                    $recordedtime =   Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart","Timetostop","Timecheck","Timeleft", "Timetostopset", "Timetostopsetdate" , "daysleft","hoursleft","minutesleft" 
                    $Timeleft = $($recordedtime.Timeleft)

                if($recordedtime.Timetostopset -ne 'No')
                {
                      $Timeleftcheck  =  New-TimeSpan -Start $timecheck -End $($recordedtime.Timetostop)  
                }
                     $warningtime = New-TimeSpan -minutes 15 

                    if( $Timeleft -gt $warningtime)
                    {

                          try
                          {
                            $countdown = get-process -name countdown_clock -ErrorAction Ignore  | Stop-Process -force -ErrorAction Ignore      | Out-Null
                          }
                          catch
                          {}
           
                       }
}
            
 
























# SIG # Begin signature block
# MIIFlAYJKoZIhvcNAQcCoIIFhTCCBYECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUd/WvoX9rk3xXm5sJAGajFtBY
# L0CgggMiMIIDHjCCAgagAwIBAgIQKqsA84kv7btM8F7chJSp3DANBgkqhkiG9w0B
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUBqzXQsO6PGOquQLn2XZK
# E8FAuFkwDQYJKoZIhvcNAQEBBQAEggEAbuEJHqUOb/vNSpLLOrlKqamDx4mmVDdf
# SOIYedo+oecBxs5+mAO6Rvu3iZsDd49BzAlm9FM4oyBRT8YCPoAVTzSl1yYQ9gzB
# c9PGW3Sqv5RNkJ3JSw4ES3sdLuCyIOpfP2MjMErZAmLaAKDHD7VWYAoHSsJo/Pgs
# y/K+Pt5XYVapi2nLfBASSnSx7vZD5HWRspBhz6WfiKolOqMJcqW4mTIqQf+d4F8n
# tNyrVQ+uC+tHfiNGDZYBPhB0/IozPAyBJBY+NTXZqVwkAzAMSIVDaT0jC2oRb3nf
# inM2jSN8Z56VuC6vhy7NYbneBdOBZtyw419+ok5t/dp7+zQl2rlHNg==
# SIG # End signature block
