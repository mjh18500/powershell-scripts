#  Reads a list of device names from a txt file and adds each device to a Microsoft Entra ID security group.
#  Must install and connect to Microsoft Graph module. 


param (
    [string]$DeviceListFile = "devicelist.txt",  # File with device names, one per line
    [string]$GroupName = "GroupName"        # Target group name
)

# Connect to Microsoft Graph
Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "Group.ReadWrite.All", "Device.Read.All", "Directory.Read.All"

# Get Group ID by Display Name
Write-Host "Looking up group: $GroupName"
$group = Get-MgGroup -Filter "displayName eq '$GroupName'"

if (-not $group) {
    Write-Error "Group '$GroupName' not found. Exiting script."
    exit 1
}

$groupId = $group.Id
Write-Host "Group ID found: $groupId"

# Read device names from file
$deviceNames = Get-Content -Path $DeviceListFile
foreach ($deviceName in $deviceNames) {
    $deviceName = $deviceName.Trim()
    if (-not $deviceName) { continue }

    Write-Host "Looking up device: $deviceName"

    # Find device by displayName
    $device = Get-MgDevice -Filter "displayName eq '$deviceName'"

    if (-not $device) {
        Write-Warning "Device '$deviceName' not found in Entra ID."
        continue
    }

    $deviceId = $device.Id
    Write-Host "Adding device '$deviceName' (ID: $deviceId) to group..."

    # Add device to group
    try {
        New-MgGroupMember -GroupId $groupId -BodyParameter @{
            "@odata.id" = "https://graph.microsoft.com/v1.0/devices/$deviceId"
        }
        Write-Host "Successfully added '$deviceName' to group."
    } catch {
        Write-Warning "Failed to add '$deviceName' to group: $_"
    }
}

Write-Host "Script complete."
