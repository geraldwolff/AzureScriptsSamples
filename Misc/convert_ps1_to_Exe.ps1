
Add-Type -AssemblyName System.Windows.Forms

###https://www.powershellgallery.com/packages/ps2exe/1.0.12
###Install-Module -Name ps2exe -allowclobber -force

import-module ps2exe 

Function Create_tempfolder
{
    if   ( !(  Test-Path  -path 'c:\temp')) {
    New-Item -ItemType Directory -path 'C:\temp' -verbose
   # write-host " Temp folder created " -ForegroundColor Green -BackgroundColor Black
    }


} 
 
create_tempfolder


 

function Get-FileName($InitialDirectory)
{
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
     # Define Title
    $OpenFileDialog.Title = "Select Source scripts"
    $OpenFileDialog.InitialDirectory = $InitialDirectory
    $OpenFileDialog.filter = "scripts (*.ps1) |*.ps1"
    $OpenFileDialog.ShowDialog(((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))) | Out-Null
    $OpenFileDialog.FileName
    
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

$sourcescriptfile = Get-FileName('c:\')

$targetfilename =  [System.IO.Path]::GetFileNameWithoutExtension("$sourcescriptfile")


$targetfolder =  Get-Folder('c:\')
<#
$certname = "avd_cert"    ## Replace {certificateName}
$cert = New-SelfSignedCertificate -Subject "CN=$certname" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256


 $cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert |
    Select-Object -First 1

Set-AuthenticodeSignature -FilePath "$targetfolder\$targetfilename.ps1"   -Certificate $cert -Force
#>
 Invoke-PS2EXE -inputFile $sourcescriptfile -outputFile "$targetfolder\$targetfilename.exe"   -noVisualStyles -X64   -requireAdmin   -noConsole  | out-null










# SIG # Begin signature block
# MIIFlAYJKoZIhvcNAQcCoIIFhTCCBYECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7ASBkGRgJPErwVYlEiu9V5RP
# GAegggMiMIIDHjCCAgagAwIBAgIQKqsA84kv7btM8F7chJSp3DANBgkqhkiG9w0B
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUMevk4WDaOVDQK2iSRwDI
# OHRtCAgwDQYJKoZIhvcNAQEBBQAEggEAhwEF2onITkk6eBYG6Q2uXBE30YtrQKB+
# ZehKZLq1JhTQJTZvRVp/ZeLwpklxuizAqicLch2dap6/R/JFTZqiN5y6bZUshAGP
# GeScC1eBH/bwSZv2CI3Q5hUUMR10NMSz6ckzC1FgFJLi1Q5Pk5xilIrN/00K7Wyu
# hTV+PgFd43OKrNv4OSYnewVIX4UOxsan25gHgZgGy3qFnjSacf3L+AN2KFkIJycH
# mAP5a5xiW8NAGnHNNugT5bx8nfjI/eqDqxk+3PiOkK+aHOIG0YLn3SA/GeqcgYoi
# ObaScbBsdEN0sWoG4VYCrpbH/YFzVmqLNTsfgelQnhjSBkCDdrXYtw==
# SIG # End signature block
