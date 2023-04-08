<#
the script retrieves the credentials from the Azure Key Vault specified in $keyVaultName 
and $secretName using the Get-AzKeyVaultSecret cmdlet. It then converts the secret to a 
secure string using the ConvertTo-SecureString cmdlet and creates a PSCredential object 
using the New-Object cmdlet.

The script then uses the retrieved credentials to authenticate with Azure using the
 Connect-AzAccount cmdlet. The script then proceeds to check if the specified process 
 is running and shuts down the virtual machine if it's not running.

You can customize this script by changing the values for $processName, $vmName,
 $resourceGroup, $location, $keyVaultName, and $secretName to match the process,
  VM, and Key Vault that you want to monitor and shut down.
#>



 







$processName = "notepad.exe"
$vmName = "my-vm-name"
$resourceGroup = "my-resource-group"
$location = "eastus"
$keyVaultName = "my-key-vault"
$secretName = "my-secret-name"

# Authenticate with Azure
$credential = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName | ConvertTo-SecureString

# Get the plain text credential from the secure string
$credentialPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential))

# Create a PSCredential object using the retrieved credentials
$cred = New-Object System.Management.Automation.PSCredential("username", $credential)

while ($true) {
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

    if ($process) {
        Write-Host "$processName is running"
    } else {
        Write-Host "$processName is not running, shutting down VM"

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
