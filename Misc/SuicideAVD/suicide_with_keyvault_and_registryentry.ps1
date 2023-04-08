<#

the script creates a registry key indicating that the script is 
starting up by using the New-ItemProperty cmdlet to create a new registry 
value in the HKLM:\SOFTWARE\MyScript key. The script then updates the value 
of the registry key to indicate that the script
 is ready to monitor the process using the Set-ItemProperty cmdlet.

You can customize this script by changing the values for $processName, 
$vmName, $resourceGroup, $location, $keyVaultName, and $secretName to 
match the process, VM, and Key Vault that you want to monitor and shut down.

 You can also change the registry key path and name to match your desired path and name.
#>



$processName = "notepad.exe"
$vmName = "my-vm-name"
$resourceGroup = "my-resource-group"
$location = "eastus"
$keyVaultName = "my-key-vault"
$secretName = "my-secret-name"

# Create a registry key indicating that the script is starting up
New-ItemProperty -Path "HKLM:\SOFTWARE\MyScript" -Name "Ready" -Value "Starting up" -Force | Out-Null

# Authenticate with Azure
$credential = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName | ConvertTo-SecureString
$credentialPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential))
$cred = New-Object System.Management.Automation.PSCredential("username", $credential)

while ($true) {
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

    if ($process) {
        # Update the registry key to indicate that the script is ready to monitor the process
        Set-ItemProperty -Path "HKLM:\SOFTWARE\MyScript" -Name "Ready" -Value "Ready to monitor $processName" -Force | Out-Null

        Write-Host "$processName is running"
    } else {
        Write-Host "$processName is not running, shutting down VM"

        # Update the registry key to indicate that the script is shutting down the VM
        Set-ItemProperty -Path "HKLM:\SOFTWARE\MyScript" -Name "Ready" -Value "Shutting down VM" -Force | Out-Null

        # Authenticate with Azure using the retrieved credentials
        Connect-AzAccount -Credential $cred

        # Get the VM object
        $vm = Get-AzVM -Name $vmName -ResourceGroupName $resourceGroup

        # Stop the VM
        Stop-AzVM -Name $vmName -ResourceGroupName $resourceGroup -Force

        # Wait for the VM to stop
        do {
            Start-Sleep -Seconds 10
            $vm = Get-AzVM -Name $vmName -ResourceGroupName $resourceGroup
        } while ($vm.PowerState -ne "VM deallocated")

        # Deallocate the VM
        Set-AzVM -Name $vmName -ResourceGroupName $resourceGroup -Location $location -Deallocate -Force
    }

    Start-Sleep -Seconds 5
}
