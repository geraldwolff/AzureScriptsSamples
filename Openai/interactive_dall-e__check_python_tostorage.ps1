$python = Get-Command python -ErrorAction SilentlyContinue
if ($python -eq $null) {
    $url = "https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe"
    $output = "C:\Python310\python-3.10.0-amd64.exe"
    Invoke-WebRequest -Uri $url -OutFile $output
    Start-Process -FilePath $output -ArgumentList "/quiet InstallAllUsers=0" -Wait
}
else {
    Write-Host "Python is already installed on your machine."
}



$pythonExe = "C:\Users\jerrywolff\AppData\Local\Microsoft\WindowsApps\python.exe "

$prompt = Read-Host " what image do you want?" : 
$prompt = $prompt.trim()
 
$imagename = $prompt -replace(' ','_') 


$imagetypes = 'JPEG - (Joint Photographic Experts Group)',
'PNG - (Portable Network Graphics)',
'GIF -  (Graphics Interchange Format)',
'TIFF -  (Tagged Image File)',
'PSD - (Photoshop Document)',
'PDF - (Portable Document Format)',
'EPS - (Encapsulated Postscript)',
'AI - (Adobe Illustrator Document)'


$typeselected = $imagetypes | ogv -Title " select and image type to generate:" -PassThru | select -First 1

$imagetype = ($typeselected -split(' '))[0]

$imagefile = "c:/temp/$imagename.$imagetype"

$pythonCode = @"
#Note: The openai-python library support for Azure OpenAI is in preview.
import os
import requests
import openai
openai.api_type = "azure"
openai.api_base = "https://wolffentpopenai.openai.azure.com/"
openai.api_version = "2023-06-01-preview"
openai.api_key = "927843b5b7a74f3cbd320c13e166b2c0"

response = openai.Image.create(
    prompt='$prompt',
    size='1024x1024',
    n=3
)

image_url = response["data"][0]["url"]
print(image_url)
Image_response = requests.get(image_url)
Image_file = open('$imagefile',"wb")
Image_file.write(Image_response.content)
Image_file.close()

"@


 
$imagename
Write-Output "$pythoncode" | Out-File "c:\temp\$imagename.py" -Encoding utf8

$pythonScriptPath = "c:\temp\$imagename.py"

 

    & $pythonExe $pythonScriptPath 
  
     start-sleep -Seconds 15

     $image = $imagefile -replace('/','\')


    if(! (get-childitem -Path $image))
    {
    
      Write-Warning "No $image found by that $imagetype"    
     }
     else
     {
        invoke-item "$image"
     }

 
 Start-Sleep -Seconds 5
 
##### storage subinfo

$Region =  "West US"

 $subscriptionselected = 'wolffentpsub'



$resourcegroupname = 'wolffautomationrg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid



### end storagesub info

set-azcontext -Subscription $($subscriptioninfo.Name)  -Tenant $($TenantID.TenantId)

 #########################################################

#BEGIN Create Storage Accounts
 $storageaccountname = 'wolffautosa'
$storagecontainer = 'imagescripts'
 Write-Output "$pythoncode" | Out-File "$imagename.py" -Encoding utf8
$imagescripts = "$imagename.py"
 
 try
 {
     if (!(Get-AzStorageAccount -ResourceGroupName $resourcegroupname -Name $storageaccountname ))
    {  
        Write-Host "Storage Account Does Not Exist, Creating Storage Account: $storageAccount Now"

        # b. Provision storage account
        New-AzStorageAccount -ResourceGroupName $resourcegroupname  -Name $storageaccountname -Location $region -AccessTier Hot -SkuName Standard_LRS -Kind BlobStorage -Tag @{"owner" = "Jerry wolff"; "purpose" = "Az Automation storage write" } -Verbose
 
     
        Get-AzStorageAccount -Name   $storageaccountname  -ResourceGroupName  $resourcegroupname  -verbose
     }
   }
   Catch
   {
         WRITE-DEBUG "Storage Account Aleady Exists, SKipping Creation of $storageAccount"
   
   } 
        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  –StorageAccountName $storageaccountname).value | select -first 1
        $destContext = New-azStorageContext  –StorageAccountName $storageaccountname `
                                        -StorageAccountKey $StorageKey  


             #Upload user.csv to storage account

        try
            {
                  if (!(get-azstoragecontainer -Name $storagecontainer -Context $destContext))
                     { 
                         New-azStorageContainer $storagecontainer -Context $destContext | out-null
                        }
             }
        catch
             {
                Write-Warning " $storagecontainer container already exists" | out-null
             }
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $imagescripts  -File $imagescripts -Context $destContext -Force  -ErrorAction Ignore | out-null
 
 
 
 
 ##########################################################
 
 $imagestored = "$image"
 
 
 
 $storagecontainer = 'images'       
   
 try
 {
     if (!(Get-AzStorageAccount -ResourceGroupName $resourcegroupname -Name $storageaccountname ))
    {  
        Write-Host "Storage Account Does Not Exist, Creating Storage Account: $storageAccount Now"

        # b. Provision storage account
        New-AzStorageAccount -ResourceGroupName $resourcegroupname  -Name $storageaccountname -Location $region -AccessTier Hot -SkuName Standard_LRS -Kind BlobStorage -Tag @{"owner" = "Jerry wolff"; "purpose" = "Az Automation storage write" } -Verbose
 
     
        Get-AzStorageAccount -Name   $storageaccountname  -ResourceGroupName  $resourcegroupname  -verbose
     }
   }
   Catch
   {
         WRITE-DEBUG "Storage Account Aleady Exists, SKipping Creation of $storageAccount"
   
   } 
        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  –StorageAccountName $storageaccountname).value | select -first 1
        $destContext = New-azStorageContext  –StorageAccountName $storageaccountname `
                                        -StorageAccountKey $StorageKey  


             #Upload user.csv to storage account

        try
            {
                  if (!(get-azstoragecontainer -Name $storagecontainer -Context $destContext))
                     { 
                         New-azStorageContainer $storagecontainer -Context $destContext | out-null
                        }
             }
        catch
             {
                Write-Warning " $storagecontainer container already exists" | out-null
             }
       
  
  
  
  
  
  
        Set-azStorageBlobContent -Container $storagecontainer -Blob  $imagestored  -File  $imagestored   -Context $destContext -Force    -ErrorAction Ignore | out-null
 
 
     
 
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
write-host " This script prompts for Genrative AI images" -ForegroundColor "Green"


 start-sleep -Seconds 10 
 
 $process = Get-Process -id $pid 
 stop-process $($process.id)

'@


Write-output "$logo" | out-file 'C:\temp\wolfflogo.ps1' -Encoding utf8



 
$logoproc = Start-Process PowerShell -ArgumentList  "-command powershell C:\temp\wolfflogo.ps1 "  -WindowStyle Normal -Wait  
 
