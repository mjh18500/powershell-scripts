#  Detect & Clear Stuck RunCommand Extension for Azure VM



# === CONFIGURATION ===
$resourceGroup = "ResourceGroupName"
$vmName = "VmName"
$extensionName = "ExtensionName"

# === STEP 1: Check extension status ===
$extension = Get-AzVMExtension -ResourceGroupName $resourceGroup -VMName $vmName -Name $extensionName -ErrorAction SilentlyContinue

if ($null -eq $extension) {
    Write-Host "RunCommand extension is not currently installed."
} else {
    $provisioningState = $extension.ProvisioningState
    Write-Host "Extension state: $provisioningState"

    if ($provisioningState -ne "Succeeded") {
        Write-Warning "Extension may be stuck. Attempting to remove..."

        # === STEP 2: Remove the stuck extension ===
        Remove-AzVMExtension -ResourceGroupName $resourceGroup -VMName $vmName -Name $extensionName -Force
        Write-Host "Extension removed."

        # === STEP 3: Optional reboot (uncomment if needed) ===
        # Write-Warning "Rebooting the VM to clear any residual lock..."
        # Restart-AzVM -ResourceGroupName $resourceGroup -Name $vmName
    } else {
        Write-Host "Extension is in a healthy state. No action taken."
    }
}
