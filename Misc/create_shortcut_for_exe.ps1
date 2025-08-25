$Shell = New-Object -ComObject ("WScript.Shell")
$ShortCut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\avd_shutdown_time_set.lnk")
$ShortCut.TargetPath="C:\programdata\AVD_Tools\MANAGE_SHUTDOWN_TimeBased_set_GUI.exe"
#$ShortCut.Arguments="-arguementsifrequired"
$ShortCut.WorkingDirectory = "C:\programdata\AVD_Tools";
$ShortCut.WindowStyle = 1;
$ShortCut.Hotkey = "CTRL+SHIFT+F";
$ShortCut.IconLocation = "C:\programdata\AVD_Tools\MANAGE_SHUTDOWN_TimeBased_set_GUI.exe, 0";
$ShortCut.Description = "Your Custom Shortcut Description";

$ShortCut.save()
