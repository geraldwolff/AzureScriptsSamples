install-WindowsFeature -Name RDS-RD-Server -Restart

$uris = @(
    "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv"
    "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH"
)

$installers = @()
foreach ($uri in $uris) {
    $download = Invoke-WebRequest -Uri $uri

    $fileName = ($download.Headers.'Content-Disposition').Split('=')[1].Replace('"','')
    $output = [System.IO.FileStream]::new("$pwd\$fileName", [System.IO.FileMode]::Create)
    $output.write($download.Content, 0, $download.RawContentLength)
    $output.close()
    $installers += $output.Name
}

foreach ($installer in $installers) {
    Unblock-File -Path "$installer"
}

msiexec /i Microsoft.RDInfra.RDAgent.Installer-x64-<version>.msi /quiet REGISTRATIONTOKEN=<RegistrationToken>


msiexec /i Microsoft.RDInfra.RDAgentBootLoader.Installer-x64.msi /quiet








