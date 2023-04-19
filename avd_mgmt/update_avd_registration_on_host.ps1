

'Az.DesktopVirtualization','az.avd' | foreach-object {

install-module -name $_ -allowclobber
import-module -name $_ -force
}



$registrationToken = Update-AvdRegistrationToken -HostpoolName $avdHostpool.name   
 


