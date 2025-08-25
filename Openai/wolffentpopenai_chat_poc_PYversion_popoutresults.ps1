 

Connect-AzAccount | out-null
######################################################## label



$logo = @'
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class WinAPI {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    }
"@

$process = Get-Process -id $pid
[WinAPI]::MoveWindow($process.MainWindowHandle, 5, 10, 55, 50, $true)
 
 $host.ui.rawui.windowsize = New-Object Management.Automation.Host.Size(55, 20)

start-sleep -seconds 2

write-host ""
write-host ""
write-host " _                _          _         ____    ____       " -ForegroundColor Green
write-host " \\      /\      // _____   | |       |____|  |____|      " -ForegroundColor Yellow
write-host "  \\    //\\    // |  _  |  | |       | |__   | |__       " -ForegroundColor Red
write-host "   \\  //  \\  //  | | | |  | |       | ___|  | ___|      " -ForegroundColor Cyan
write-host "    \\//    \\//   | |_| |  | |____   | |     | |      " -ForegroundColor DarkCyan
write-host "     \/      \/    |_____|  |______|  |_|     |_|      "-ForegroundColor Magenta
write-host "     "
write-host " This tool prompts for q&A  using GPT35.turbo" -ForegroundColor "Cyan"


 start-sleep -Seconds 10 
 
 $process = Get-Process -id $pid 
 stop-process $($process.id)

'@


Write-output "$logo" | out-file 'C:\temp\wolfflogo.ps1' -Encoding utf8



 
$logoproc = Start-Process PowerShell -ArgumentList  "-command powershell C:\temp\wolfflogo.ps1 "  -WindowStyle Normal -Wait  
 
 #############################################

$python = Get-Command python -ErrorAction SilentlyContinue
if ($python -eq $null) {
    $url = "https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe"
    $output = "C:\Python310\python-3.10.0-amd64.exe"
    Invoke-WebRequest -Uri $url -OutFile $output
    Start-Process -FilePath $output -ArgumentList "/quiet InstallAllUsers=0" -Wait -ErrorAction SilentlyContinue
}
else {
    Write-OUTPUT "Python is already installed on your machine." | Out-File c:\temp\openailog.txt -Encoding utf8 -Append 
}



$pythonExe = "C:\Users\jerrywolff\AppData\Local\Microsoft\WindowsApps\python.exe  "

#$prompt = Read-Host " what image do you want?" : 

function get_prompt()
{
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'describe the information you are looking for: type quit to exit'
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
    $label.Text = 'Describe the information you are looking for:'
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
        [parameter(Mandatory = $true, HelpMessage = "Responsfilename")]
        [ValidateNotNullOrEmpty()]
        [string]$responsefilname)
 
$textsresults = get-content "c:\temp\$responsefilname.txt" -raw| Where-Object {$_ -match $regex} | ForEach-Object {
  write-output "$_ `r `n"

   
}

$form1 = New-Object System.Windows.forms.form
$form1.Text = "Answer"
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

 

function Get-Completion {
    <#     
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, HelpMessage = "Your Azure OpenAI prompt")]
        [ValidateNotNullOrEmpty()]
        [string]$Prompt,
        [parameter(Mandatory = $true, HelpMessage = "Max number of tokens allowed to be used in this request")]
        [ValidateNotNullOrEmpty()]
        [int]$Maxtokens
        )

Process {
    $ErrorActionPreference = "Stop"
    $APIVersion = "2022-12-01"
    # Construct URI
    $uri = "https://$resourcename.openai.azure.com/openai/deployments/$deploymentname/completions?api-version=2023-03-15-preview"
    # Construct Body

if(($prompt.replace(' ','')).Length -gt 40)
{
  $responsefilname =  ((($prompt.replace(' ','').replace(',','')).replace('.',''))).Substring(0,40)
  }
  else 
  {
    $responsefilname = ((($prompt.replace(' ','').replace(',','')).replace('.','')))
  }

$pythonCode = @"
#Note: The openai-python library support for Azure OpenAI is in preview.
import os
import openai
import io
import json
openai.api_type = "azure"
openai.api_base = "https://wolffentpopenai.openai.azure.com/"
openai.api_version = "2023-09-15-preview"
openai.api_key = ("927843b5b7a74f3cbd320c13e166b2c0")

response = openai.Completion.create(
  engine="wolffentpopenidepl",
  prompt="$Prompt",
  temperature=1,
  max_tokens=$Maxtokens,
  top_p=0,
  frequency_penalty=0,
  presence_penalty=0,
  stop=None)

#print(response)
Answer = response["choices"][0]["text"]
#print (Answer)
 

file_name = open("c:/temp/$responsefilname.txt","w")

file_name.writelines(Answer)
 
 
 
 
"@

if(($prompt.replace(' ','')).Length -gt 40)
{
  $responsefilname =  ((($prompt.replace(' ','').replace(',','')).replace('.',''))).Substring(0,40)
  }
  else 
  {
    $responsefilname = ((($prompt.replace(' ','').replace(',','')).replace('.','')))
  }

Write-Output "$pythoncode" | Out-File "c:\temp\$responsefilname.py" -Encoding utf8

$pythonScriptPath = "c:\temp\$responsefilname.py"
 

    (& $pythonExe $pythonScriptPath)  >> C:\temp\answers.txt  

}

}
 
 
 
 
 cls
do
{
     
            

$prompt = get_prompt
  
  $Request =  Get-Completion   -Maxtokens 1000 -Prompt $Prompt | out-null
   
   
if(($prompt.replace(' ','')).Length -gt 40)
{
  $responsefilname =  ((($prompt.replace(' ','').replace(',','')).replace('.',''))).Substring(0,40)
  }
  else 
  {
    $responsefilname = ((($prompt.replace(' ','').replace(',','')).replace('.','')))
  }
     
    start-sleep -Seconds 10
  

  show_results -responsefilname "$responsefilname"
 

} until ($Prompt -eq 'quit')

"Token cost"
$Request.usage


#>













