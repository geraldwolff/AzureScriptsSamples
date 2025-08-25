 ##########################################################################

# Created:  6_22_2023

# Modified:  

# Author: J Wolff  
 
# Requires: Powershell v2

# datagrid_evnts_monitor
# Updates 
#############################################################################
 

 $ErrorActionPreference = "silentlycontinue"
#-----------------------------------------------------------------------------------



Function Contact_me {
$author = "c:\temp\author.txt"
  Write-output "

            Gerald Wolff  | ME
             
            " |Format-Table|out-file $author
            gc  $author |Out-GridView 
 

}


#$ErrorActionPreference = "silentlycontinue"

function get_events {

      
    $events = get-eventlog  -logname application -Source Manage_shutdown_monitor -newest 6  | select TimeGenerated, InstanceId, message       

 
 foreach($event in $events)
 {
       $obj=New-Object PSobject 
       

               $obj | Add-Member Noteproperty TimeGenerated  $($event.TimeGenerated)
               $obj | Add-Member Noteproperty InstanceId  $($event.InstanceId)
               $obj | Add-Member Noteproperty message  $($event.message)

               [array]$eventlist += $obj
        
        $array = New-Object System.Collections.ArrayList
        $array.clear()
        $Script:CMDinfo =  $eventlist
        $array.AddRange($CMDinfo)
        $dataGrid1.DataSource = $array
        $stBar1 = "Row counts " + $array.count
        $form1.refresh()
    }

}




$path = Split-Path $psISE.CurrentFile.FullPath 

 sl $path

$icon = (get-childitem -Path $path -Recurse -file   'wolfftools_events_trracker.ico').FullName
  

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
     get_events
     $datagrid1.Refresh()
    start-sleep -Seconds 30

    }until ($i = 1)
}
# Get Information
$button2_OnClick= 
{

get_events
 
 
 
}

#initial load and GEt Source
$OnLoadForm_UpdateGrid=
{

get_events
}

#----------------------------------------------
#region Generated Form Code
$form1.Text ="Event Monitor Tool  Ver.1.15 - by J Wolff 6/2023" 
$form1.Name = "form1"
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 1200
$System_Drawing_Size.Height = 500
$form1.ClientSize = $System_Drawing_Size
#$form1.backcolor = [System.Drawing.Color]::FromArgb(96,179,247,0)
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
$System_Drawing_Point.X = 415
$System_Drawing_Point.Y = 15
$button9.Location = $System_Drawing_Point
$button9.DataBindings.DefaultDataSourceUpdateMode = 0
$button9.add_Click($button9_OnClick)

$form1.Controls.Add($button9)




<## Button8
$button8.TabIndex = 9
$button8.Name = "button8"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 125
$System_Drawing_Size.Height = 23
$button8.Size = $System_Drawing_Size
$button8.UseVisualStyleBackColor = $True
 #>

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

$button2.Text = "Get Events"

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



$pictureBox1.BackgroundImage = [System.Drawing.Image]::FromFile("$icon")
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
$dataGrid1.TabIndex = 0
$dataGrid1.AutoSize = $true
  
 $dataGrid1.PreferredColumnWidth = 300
$dataGrid1.AutoSize = $true
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUvl0s/xBvFuiD34JGdAuniHHo
# htegggMiMIIDHjCCAgagAwIBAgIQKqsA84kv7btM8F7chJSp3DANBgkqhkiG9w0B
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUXxioFBE4x2ZNNmiyFLec
# d0LqfJ8wDQYJKoZIhvcNAQEBBQAEggEAOQ3fV1ZpysAq3hd3H8ZWnUrp4IMHoNUM
# oFRilyZ7AQk6H9I2ZGLr9zZylyqnYSAZBs+7I9N4QxU3h7RokMmNhirz2vkgPVuy
# e2OdBNsNLJ8PUzUeM6Xi1rpN1fbx1UsiQVwJxO4McTg9CWNn2YfHxrqnGsyUHdgR
# ijfJiGrXgcBohKXv4kUscNhgQ1cAh4VlU7r8Y69CJIAKnujoxlRrnGC642wI3K+W
# SqtwqyGrObmfPLSNWEEEnVitwUAeN0NnwixmK/2+YoCkQqhSFbw+E0Ohvz42pq07
# BRl5tGO2jzKlhReZEQWARY1ZUi3wdx9B+iWH96kwdRHIwp4UK3GjXQ==
# SIG # End signature block
