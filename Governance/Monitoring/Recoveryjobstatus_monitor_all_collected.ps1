 <##########################################################################

# Created:  8_16_2023

# Modified:  

# Author: J Wolff  
 
# Requires: Powershell v2

# datagrid_recovery_jobs_monitor
# Updates 
# Description : This PowerShell script is a tool for monitoring recovery jobs in Azure. 
                It defines functions for connecting to an Azure account,
                retrieving recovery service vaults, and retrieving backup job events. 
                The script then generates a form with buttons for refreshing and retrieving job events,
                as well as an embedded data grid for displaying job information. The form is displayed 
                to the user, who can interact with the buttons to retrieve and display job information.
Detailed Description:
            This PowerShell script is designed to help users monitor recovery jobs in Azure. The script begins
             by setting the $ErrorActionPreference variable to "continue", which allows the script to continue running even if errors occur.

            The script then defines a function called Contact_me, which creates a text file with the 
            author's name and displays it in a pop-up window using Out-GridView.

            The script then connects to the Azure account using the Connect-AzAccount function.

            Next, the script defines a function called get_events, which retrieves a list of recovery
             service vaults using Get-AzRecoveryServicesVault. For each vault, the function sets the vault 
             context using Get-AzRecoveryServicesVault and Set-AzRecoveryServicesVaultContext. 
            The function then retrieves backup job events for the vault using Get-AzRecoveryServicesBackupJob
             and adds them to an array of PS objects. The function then selects the desired job properties 
             and stores them in a variable called $eventreport. The $eventreport variable is then converted 
             to an ArrayList and displayed in a data grid using New-Object System.Collections.ArrayList, Clear(), and DataSource.

            The script also defines a function called GenerateForm, which creates a graphical user interface
             (GUI) form using the .NET framework. The form includes buttons for refreshing and retrieving job events,
              as well as an embedded data grid for displaying job information.

            The script then sets the $path variable to the path of the current script and uses Set-Location to 
            navigate to that directory. The script then sets the $icon variable to the path of an icon file used in the GUI form.

            Finally, the script calls the GenerateForm function, which generates the GUI form and displays 
            it to the user. The form allows the user to interact with the buttons to refresh and retrieve job events,
             as well as to close the form. The data grid displays the job information retrieved by the get_events function.
              The user can use this information to monitor recovery jobs in Azure.

#############################################################################>
 

 $ErrorActionPreference = "continue"
#-----------------------------------------------------------------------------------



Function Contact_me {
$author = "c:\temp\author.txt"
  Write-output "

            Gerald Wolff  | ME
             
            " |Format-Table|out-file $author
            gc  $author |Out-GridView 
 

}


#$ErrorActionPreference = "silentlycontinue"

 
connect-azaccount 

      
 

function get_events 
 {
     $eventlist = ''

    $recoveryservicesvaults = Get-AzRecoveryServicesVault
  
        foreach($vault in  $recoveryservicesvaults)
        {

            $vaultcontext = Get-AzRecoveryServicesVault  -name  $($vault.name)

            Set-AzRecoveryServicesVaultContext -Vault  $vaultcontext

      
            $Recoveryjobs = Get-AzRecoveryServicesBackupJob  -VaultId $($vault.ID) -From ((get-date).AddDays(-10)).ToUniversalTime() -To (get-date).ToUniversalTime()

 
             foreach($event in $Recoveryjobs) # | Where-Object {$_.Operation  -eq 'Restore'})
             {
                   $obj=New-Object PSobject 
       

                           $obj | Add-Member Noteproperty WorkloadName  $($event.WorkloadName)
                           $obj | Add-Member Noteproperty Operation  $($event.Operation)
                           $obj | Add-Member Noteproperty Status  $($event.Status)
                           $obj | Add-Member Noteproperty StartTime  $($event.StartTime)
                           $obj | Add-Member Noteproperty Vault  $($vault.Name)

                         [array]$eventlist += $obj
               }

                   
        }

        $eventreport = $eventlist | select Vault, WorkloadName, Operation, Status, StartTime

        $array = New-Object System.Collections.ArrayList
        $array.clear()
        $Script:CMDinfo =   $eventreport
        $array.AddRange($CMDinfo)
        $dataGrid1.DataSource = $array
        $stBar1 = "Row counts " + $array.count
        $form1.refresh()
    

}




$path = Split-Path $psISE.CurrentFile.FullPath 

 sl $path

$icon = (get-childitem -Path $path -Recurse -file   'wolfftools_events_trracker.ico').FullName | out-null
  

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
$button5 = New-Object System.Windows.Forms.Button#>
#$button4 = New-Object System.Windows.Forms.Button   
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

<#switch vaults

$button4_OnClick= 
{
$vaultinfo = switchvaults
get_events


}
#>
 
# Close

$button3_OnClick= 
{
 
$Form1.Close()
$Form1.dispose()
}


# Refresh List

$button1_OnClick= 
{

    do
    {
     get_events -vault $vault
     
     $datagrid1.Refresh()
    start-sleep -Seconds 20
    $i = $i +1
    }until ($i = 10)

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
$form1.Text ="Recovery services jobs Monitor Tool  Ver.1.0 - by J Wolff 8/2023" 
$form1.Name = "form1"
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 1600
$System_Drawing_Size.Height = 900
$form1.ClientSize = $System_Drawing_Size
#$form1.backcolor = [System.Drawing.Color]::FromArgb(96,179,247,0)
$form1.forecolor = [System.Drawing.Color]::FromArgb(255,0,0,0)
$Image = [system.drawing.image]::FromFile("$icon")
$form1.BackgroundImage = $Image
$Form1.BackgroundImageLayout = "Tile"
# None, Tile, Center, Stretch, Zoom
###############################################################
# Buttons

<## Button4
$button4.TabIndex = 4
$button4.Name = "button4"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 125
$System_Drawing_Size.Height = 23
$button4.Size = $System_Drawing_Size
$button4.UseVisualStyleBackColor = $True

$button4.Text = "Switch vaults"

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 415
$System_Drawing_Point.Y = 15
$button4.Location = $System_Drawing_Point
$button4.DataBindings.DefaultDataSourceUpdateMode = 0
$button4.add_Click($button4_OnClick)

$form1.Controls.Add($button4)

#>


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
################
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
#####################
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

##########################################

$pictureBox1.BackgroundImage = [System.Drawing.Image]::FromFile("$icon")
$pictureBox1.DataBindings.DefaultDataSourceUpdateMode = 0


$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 1850
$System_Drawing_Size.Height = 800
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
$form1.dispose()
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
