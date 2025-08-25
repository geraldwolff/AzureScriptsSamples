
Add-Type -AssemblyName System.Windows.Forms

###https://www.powershellgallery.com/packages/ps2exe/1.0.12
###Install-Module -Name ps2exe -allowclobber -force

import-module ps2exe 

Function Create_tempfolder
{
    if   ( !(  Test-Path  -path 'c:\temp')) {
    New-Item -ItemType Directory -path 'C:\temp' -verbose
    write-host " Temp folder created " -ForegroundColor Green -BackgroundColor Black
    }


} 
 
create_tempfolder


 

function Get-FileName($InitialDirectory)
{
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
     # Define Title
    $OpenFileDialog.Title = "Select Source scripts"
    $OpenFileDialog.InitialDirectory = $InitialDirectory
    $openFileDialog.Multiselect = $true

    $OpenFileDialog.filter = "scripts (*.ps1) |*.ps1"
    $OpenFileDialog.ShowDialog(((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))) | Out-Null
    $openFileDialog.FileNames
}

Function Get-Folder($initialDirectory)
{
    Add-Type -AssemblyName System.Windows.Forms
    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderBrowser.Description = 'Select the folder destination'
    $result = $FolderBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
    if ($result -eq [Windows.Forms.DialogResult]::OK){
    $FolderBrowser.SelectedPath
    } else {
    exit
    }
}

$sourcescriptfiles = Get-FileName('c:\')


$targetfolder =  Get-Folder('c:\')

 foreach($sourcescriptfile in $sourcescriptfiles)
 {
 $targetfilename =  [System.IO.Path]::GetFileNameWithoutExtension("$sourcescriptfile")


    Invoke-PS2EXE -inputFile $sourcescriptfile -outputFile "$targetfolder\$targetfilename.exe"   -noVisualStyles -X64   -requireAdmin -noconsole 

 }
