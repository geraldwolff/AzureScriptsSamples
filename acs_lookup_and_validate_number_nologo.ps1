$packages = @(
    @{ id = "Neovim.Neovim"; name = "Neovim" },
    @{ id = "Python.Python.3.13"; name = "Python 3.13" },
    @{ id = "Microsoft.VCRedist.2013.x64"; name = "Microsoft Visual C++ 2013 Redistributable (x64)" },
    @{ id = "Microsoft.VisualStudio.2022.BuildTools"; name = "Microsoft Visual Studio 2022 Build Tools"; override = "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --passive --norestart" },
    @{ id = "OpenJS.NodeJS.LTS"; name = "Node.js LTS" }
)

foreach ($package in $packages) {
    $installed = winget list --id $package.id
    if (-not $installed) {
        if ($package.ContainsKey("override")) {
            winget install --id $package.id --source winget --override $package.override
        } else {
            winget install --id $package.id
        }
    } else {
        Write-Output "$($package.name) is already installed."
    }
}


Connect-AzAccount -identity | out-null
######################################################## label

set-azcontext -Subscription wolffentpsub

 
 <#############################################

$python = Get-Command python -ErrorAction SilentlyContinue
if ($python -eq $null) {
    $url = "https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe"
    $output = "C:\Python310\python-3.10.0-amd64.exe"
    Invoke-WebRequest -Uri $url -OutFile $output
    Start-Process -FilePath $output -ArgumentList "/quiet InstallAllUsers=0" -Wait -ErrorAction SilentlyContinue
}
else {
    Write-OUTPUT "Python is already installed on your machine." | Out-File c:\temp\python.txt -Encoding utf8 -Append 
}


# make sure c:\temp exists

if (-Not (Test-Path -Path "C:\temp")) {
    New-Item -Path "C:\temp" -ItemType Directory | Out-Null
}

#>

python -m venv venv

$pythonExe = "C:\Users\jerrywolff\AppData\Local\Microsoft\WindowsApps\python.exe  "

        $responseFileName = "lookup_number_result_{0:yyyyMMdd_HHmmss}" -f (Get-Date) 

function get_number()
{
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'enter nuber to send sms to: type quit to exit'
    $form.Size = New-Object System.Drawing.Size(600,200)
    $form.StartPosition = 'CenterScreen'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,120)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
    <#
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(150,120)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)
    
 #>

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = 'Enter the phone number to Lookup :'
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10,40)
    $textBox.Size = New-Object System.Drawing.Size(560,50)
    $form.Controls.Add($textBox)

    $form.Topmost = $true

    $form.Add_Shown({$textBox.Select()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $x = $textBox.Text
        $x
    }

 if ($x -eq 'quit' -or $x -eq 'Cancel'){
         $form.close()
  
         exit
         }

        
}

function show_results
{
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, HelpMessage = "Results")]
        [ValidateNotNullOrEmpty()]
        [string]$results)
 
$textsresults = get-content "$results" -raw| Where-Object {$_ -match $regex} | ForEach-Object {
  write-output "$_ `r `n"

   
}

$form1 = New-Object System.Windows.forms.form
$form1.Text = "Results"
$form1.Size = New-Object System.Drawing.Size(700,700)
$form1.StartPosition = "CenterScreen"
$form1.MaximizeBox = $false
$form1.MinimizeBox = $false
$form1.ControlBox = $true
$form1.TopMost = $true

$TextBox = New-Object System.Windows.forms.TextBox
$TextBox.Location = New-Object System.Drawing.Point(10,10)
$TextBox.Size = New-Object System.Drawing.Size(650,500)
$TextBox.Multiline = $true
$TextBox.ScrollBars = "Vertical"
 
$TextBox.ReadOnly = $true
$TextBox.Text = "$textsresults"
$TextBox.AutoSize = $true
 
$form1.Controls.Add($TextBox)

$form1.ShowDialog()



}



function lookup_number {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, HelpMessage = "Enter the phone number to look up:")]
        [ValidateNotNullOrEmpty()]
        [string]$number
    )

    Process {
        $ErrorActionPreference = "Continue"


        $pythonExe = "python"  # Adjust if your Python executable path is different

        $pythonCode = @"
import os
import json
from azure.communication.phonenumbers import PhoneNumbersClient

connection_string = " $connectionString"
try:
    client = PhoneNumbersClient.from_connection_string(connection_string)
    result = client.search_operator_information("$number")
    operator_info = result.values[0]
    answer = json.dumps(operator_info.serialize(), indent=4)
except Exception as ex:
    answer = str(ex)

with open("C:/temp/$responseFileName.txt", "w+") as file:
    file.write(answer)
"@

        $scriptPath = "C:\temp\$responseFileName.py"
        $pythonCode | Out-File -FilePath $scriptPath -Encoding utf8

        & $pythonExe $scriptPath #>> "C:\temp\$responseFileName.txt"
    }
    
}

 
 
########## Get connection string form ACS
try {
    
    # Retrieve the connection string from the ACS instance
    $acsResourceName = "wolffacs"
    $resourceGroupName = "wolffcommsvcsrg"

    $keys = Get-AzCommunicationServiceKey -ResourceGroupName $resourceGroupName -CommunicationServiceName $acsResourceName

    if ($keys.PrimaryKey) {
        $connectionString = "endpoint=https://$($acsResourceName).communication.azure.com/;accesskey=$($keys.PrimaryKey)"
        Write-Output "Connection string retrieved successfully:"
       # Write-Output $connectionString
    } else {
        Write-Output "Failed to retrieve connection string."
    }
} catch {
    Write-Output "An error occurred while retrieving the connection string: $_"
}


 #cls
 
$number = get_number
  
  $Request =  lookup_number   -number $number   #| out-null
    $Request 
   

 
 show_results -results "c:\temp\$responseFileName.py" 

  show_results -results "c:\temp\$responseFileName.txt" 















