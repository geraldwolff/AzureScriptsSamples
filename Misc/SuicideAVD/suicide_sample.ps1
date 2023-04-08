$processName = "notepad.exe"
$vmName = "my-vm-name"
$resourceGroup = "my-resource-group"
$location = "eastus"

# Authenticate with Azure
Connect-AzAccount

while ($true) {
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

    if ($process) {
        Write-Host "$processName is running"
    } else {
        Write-Host "$processName is not running, shutting down VM"

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







