Invoke-WebRequest -Uri https://aka.ms/downloadazcopy-v10-windows -OutFile azcopy.msi


Start-Process msiexec.exe -Wait -ArgumentList '/I azcopy.msi /quiet'





 Clear-Host
$AddedLocation ="C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy"
$Reg = "Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
$OldPath = (Get-ItemProperty -Path "$Reg" -Name PATH).Path
$NewPath= $OldPath + ’;’ + $AddedLocation
 Set-ItemProperty -Path "$Reg" -Name PATH –Value $NewPath
 $env:path = $NewPath





