Remove-Item -Path "$env:LOCALAPPDATA\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\*.*" -Recurse -Force
#Type the following command to clear Chrome cache data:
Remove-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*.*" -Recurse -Force
#Type the following command to clear Firefox cache data:
#Remove-Item -Path "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2\entries\*.*" -Recurse -Force
#Type the following command to clear Internet Explorer cache data:
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
#Type the following command to clear Safari cache data:
#Remove-Item -Path "$env:LOCALAPPDATA\Apple Computer\Safari\Cache.db" -Force
#Type the following command to clear Opera cache data:
#Remove-Item -Path "$env:LOCALAPPDATA\Opera Software\Opera Stable\Cache" -Recurse -Force