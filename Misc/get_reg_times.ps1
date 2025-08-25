########################################################################
######################################################################

# Created: 10/27/2014

# Modified: 3/2/2015 

# Author: J Wolff  
 ########################################################################
######################################################################

# Created:  4/23/2014

# Modified:  

# Author: J Wolff  
 
# Requires: Powershell v2

# datagrid_live_update_deployments_check_sql_itsm_DB_Select_XXI.ps1
# Updates: 5/1/2014
#        added drop down for DBSERVERS
#        Added GRoup membership output to All_workers
#        Added Get SQL admin users  to All_workers
#        5/5/2014 
#        added Drop down selection of DB serversfor source data
#        added corrected filter for Cloud based computers
#        changed query scope for displays
#        changed background image to BT Image
#        8/21/2014 - Change Queries to view Provisining and Migrationsview in MigrationWiz DB
#        10/27/2014 - Modified SQL source servers to fit ENTICE project. Functions and Buttons will be changed as well
#        3/2/2015 - modified to work in ENIAT [audit].[DBO].{Server_Information] table
#                    added column for [ip-Address]
#####################################################################################
 

 $ErrorActionPreference = "Continue"
#-----------------------------------------------------------------------------------
# setup SQL snapin and assembly
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
 
#$compinfinfo = "c:\temp\computer_Info.txt"
#$Dbinstance = ''
# $Archive =  "c:\temp\"
 $timersettings = ''
 #Copy-Item C:\Users\geral_000\Documents\Projects\EnTice\powershell\tool_logo_bt.jpg c:\temp\ -force


<#-- Check for existence of the archive path if not create it 
#-- Check files meeting the age requirement older than $old
 
   if (-not (Test-path $Archive ))
   {
        New-Item $Archive  -Type Directory
 
   }
    
$compinfinfo = "c:\temp\computer_Info.txt"
#>
Function Contact_me {
$author = "c:\temp\author.txt"
  Write-output "

            Gerald Wolff  | ME
             
            " |Format-Table|out-file $author
            gc  $author |Out-GridView 
 

}


$ErrorActionPreference = "silentlycontinue"

function get_timersettings {



   
 $settings =  Get-ItemProperty -Path  "HKLM:\SOFTWARE\MANAGE_SHUTDOWN" -Name "InitialStart","Timetostop","Timecheck","Timeleft", "Timetostopset", "Timetostopsetdate", "graceTime", "daysleft","hoursleft","minutesleft" ,"Resettime"  |`
select InitialStart,Timetostop,Timecheck,Timeleft, Timetostopset, Timetostopsetdate, GraceTime, daysleft,hoursleft,minutesleft , Resettime
    
   

       $obj=New-Object PSobject
          Write-Debug "Adding Registry Entries"
       

               $obj | Add-Member Noteproperty InitialStart  $($settings.InitialStart)
               $obj | Add-Member Noteproperty Timetostop  $($settings.Timetostop)
               $obj | Add-Member Noteproperty Timecheck  $($settings.Timecheck)
               $obj | Add-Member Noteproperty Timeleft  $($settings.Timeleft)
               $obj | Add-Member Noteproperty Timetostopset  $($settings.Timetostopset)
               $obj | Add-Member Noteproperty Timetostopsetdate  $($settings.Timetostopsetdate)
               $obj | Add-Member Noteproperty GraceTime  $($settings.GraceTime)
               $obj | Add-Member Noteproperty daysleft  $($settings.daysleft)
               $obj | Add-Member Noteproperty hoursleft  $($settings.hoursleft)
               $obj | Add-Member Noteproperty minutesleft  $($settings.minutesleft)
               $obj | Add-Member Noteproperty Resettime  $($settings.Resettime)
 
               [array]$timersettings += $obj
        
        $array = New-Object System.Collections.ArrayList
        $array.clear()
        $Script:CMDinfo =  $timersettings
        $array.AddRange($CMDinfo)
        $dataGrid1.DataSource = $array
        $stBar1.text = "Row counts " + $array.count
        $form1.refresh()


}


  

#################################################

#Generated Form Function
function GenerateForm {


#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
#endregion

#region Generated Form Objects
$form1 = New-Object System.Windows.Forms.Form
$pictureBox1 = New-Object System.Windows.Forms.PictureBox
$label1 = New-Object System.Windows.Forms.Label
 $button9 = New-Object System.Windows.Forms.Button
<#$button8 = New-Object System.Windows.Forms.Button
$button7 = New-Object System.Windows.Forms.Button
$button6 = New-Object System.Windows.Forms.Button
$button5 = New-Object System.Windows.Forms.Button
$button4 = New-Object System.Windows.Forms.Button   #>
$button3 = New-Object System.Windows.Forms.Button
$button2 = New-Object System.Windows.Forms.Button
$button1 = New-Object System.Windows.Forms.Button
$dataGrid1 = New-Object System.Windows.Forms.DataGrid
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------
#Provide Custom Code for events specified in PrimalForms.

#Contact author
$button9_OnClick= 
{
Contact_me
}

 
# Close
$button3_OnClick= 
{
$Form1.Close()
}


# Refresh List
$button1_OnClick= 
{

    do
    {
      get_timersettings
     $datagrid1.Refresh()
    start-sleep -Seconds 30

    }until ($i = 1)
}
# Get Information
$button2_OnClick= 
{

 get_timersettings
 
 
 
}

#initial load and GEt Source
$OnLoadForm_UpdateGrid=
{

get_timersettings
}


$path = Split-Path $psISE.CurrentFile.FullPath 

 sl $path

$icon = (get-childitem -Path $path -Recurse -file   'wolfftools_events_trracker.ico').FullName



#----------------------------------------------
#region Generated Form Code
$form1.Text ="Timesettings retrieval Tool  Ver.1.15 - by J Wolff 6/2023" 
$form1.Name = "form1"
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 1200
$System_Drawing_Size.Height = 200
$form1.ClientSize = $System_Drawing_Size
$form1.backcolor = [System.Drawing.Color]::FromArgb(255,255,5,0)
$form1.forecolor = [System.Drawing.Color]::FromArgb(255,0,0,0)
 
$Image = [system.drawing.image]::FromFile("$icon")
$form1.BackgroundImage = $Image
$Form1.BackgroundImageLayout = "Tile"
# None, Tile, Center, Stretch, Zoom
###############################################################
# Buttons

## Button9
$button9.TabIndex = 10
$button9.Name = "button9"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 125
$System_Drawing_Size.Height = 23
$button9.Size = $System_Drawing_Size
$button9.UseVisualStyleBackColor = $True

$button9.Text = "Contact Author"

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 1115
$System_Drawing_Point.Y = 15
$button9.Location = $System_Drawing_Point
$button9.DataBindings.DefaultDataSourceUpdateMode = 0
$button9.add_Click($button9_OnClick)

$form1.Controls.Add($button9)




## Button8
$button8.TabIndex = 9
$button8.Name = "button8"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 125
$System_Drawing_Size.Height = 23
$button8.Size = $System_Drawing_Size
$button8.UseVisualStyleBackColor = $True
 
$button3.TabIndex = 3
$button3.Name = "button3"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 75
$System_Drawing_Size.Height = 23
$button3.Size = $System_Drawing_Size
$button3.UseVisualStyleBackColor = $True

$button3.Text = "Close"

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 340
$System_Drawing_Point.Y = 15
$button3.Location = $System_Drawing_Point
$button3.DataBindings.DefaultDataSourceUpdateMode = 0
$button3.add_Click($button3_OnClick)

$form1.Controls.Add($button3)

$button2.TabIndex = 2
$button2.Name = "button2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 120
$System_Drawing_Size.Height = 23
$button2.Size = $System_Drawing_Size
$button2.UseVisualStyleBackColor = $True

$button2.Text = "Get Times"

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 220
$System_Drawing_Point.Y = 15
$button2.Location = $System_Drawing_Point
$button2.DataBindings.DefaultDataSourceUpdateMode = 0
$button2.add_Click($button2_OnClick)

$form1.Controls.Add($button2)

$button1.TabIndex = 1
$button1.Name = "button1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 75
$System_Drawing_Size.Height = 23
$button1.Size = $System_Drawing_Size
$button1.UseVisualStyleBackColor = $True

$button1.Text = "Refresh List"

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 540
$System_Drawing_Point.Y = 15
$button1.Location = $System_Drawing_Point
$button1.DataBindings.DefaultDataSourceUpdateMode = 0
$button1.add_Click($button1_OnClick)

$form1.Controls.Add($button1)



$pictureBox1.BackgroundImage = [System.Drawing.Image]::FromFile('C:\temp\icons\wolfftools_reg_times.ico')
$pictureBox1.DataBindings.DefaultDataSourceUpdateMode = 0


$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 1850
$System_Drawing_Size.Height = 900
$pictureBox1.Location = $System_Drawing_Point
$pictureBox1.Name = "pictureBox1"
$dataGrid1.Size = $System_Drawing_Size
$dataGrid1.DataBindings.DefaultDataSourceUpdateMode = 0
$dataGrid1.HeaderForeColor = [System.Drawing.Color]::FromArgb(255,1,95,0)
$dataGrid1.Name = "dataGrid1"
$dataGrid1.DataMember = ""
$dataGrid1.AutoSize = $true
$dataGrid1.PreferredColumnWidth = 90
$dataGrid1.TabIndex = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 70
$System_Drawing_Point.Y = 58
$pictureBox1.Size = $System_Drawing_Size
$pictureBox1.TabIndex = 0
$pictureBox1.TabStop = $False
$dataGrid1.Location = $System_Drawing_Point

$form1.Controls.Add($dataGrid1)
#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $form1.WindowState

#Add Form event
$form1.add_Load($OnLoadForm_UpdateGrid)

#Show the Form
$form1.ShowDialog()| Out-Null
$form.dispose()
} #End Function

#Call the Function
 
 
#########################################################################################################
 
 

########################################################################

#invoke-command  $grab_times
#$timersettings


GenerateForm 




# SIG # Begin signature block
# MIIFlAYJKoZIhvcNAQcCoIIFhTCCBYECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0ddV2LLr0B8Z4UZgQ2PeJCq2
# sPCgggMiMIIDHjCCAgagAwIBAgIQKqsA84kv7btM8F7chJSp3DANBgkqhkiG9w0B
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUrwdV/m9g+cn7ac5Incw0
# JoB5q6owDQYJKoZIhvcNAQEBBQAEggEAIzQyM9X0qOkJTLusWg30trHBTzy0HUtL
# CI2CW76gNSF0pjL3m14yQzoK15OvETSM7HtpYv4lhx7IYcxVZJZko5MKVpe1tPHb
# fBF5EvwnzVk2KOdG2eV/oSSje6bj+RVt/mabswuA41sIQi4L1RqA78SCsCjsvZZI
# wIVRo7cQ/5DgZE+BMI4SVhA0U5VJxap4Mp+UO2sS5MNJ2SagTxH28EOJNToiD18n
# +d29Pvz1urMO4HaLMo4T2Xk4/hond4QdPxT6VKGtRvK9zdRBeURFs/WUNvPJDjG0
# tht2Zz77zs1F18DCkiG/KchJxAB9aoYQ4YiF+4d5mieDPaPm9dB/sg==
# SIG # End signature block
