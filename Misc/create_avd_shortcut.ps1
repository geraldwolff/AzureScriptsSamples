$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\$ENV:Username\Desktop\AVD_Shutdown_Time_Set.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$Shortcut.Arguments = "-ExecutionPolicy bypass C:\programdata\avd_tools\MANAGE_SHUTDOWN_TimeBased_set_GUI.ps1 -WindowStyle Hidden"
$shortcut.IconLocation="C:\temp\icons\wolfftools_events_trracker.ico , 0"
$Shortcut.Save()