# Reads a list of user principal names (UPNs) from a file and adds each user to an Assigned security group in Microsoft Entra ID.
# Must install and connect to Microsoft Graph module. 

param (
    [string]$UserListFile = "USERLIST.txt",  # File with UPNs, one per line
    [string]$GroupName = "GroupName"  # Target group name
)

# Connect to Microsoft Graph
Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "Group.ReadWrite.All", "User.Read.All", "Directory.Read.All"

# Get the group ID by name
Write-Host "Looking up group: $GroupName"
$group = Get-MgGroup -Filter "displayName eq '$GroupName'"

if (-not $group) {
    Write-Error "Group '$GroupName' not found. Exiting script."
    exit 1
}

$groupId = $group.Id
Write-Host "Group ID found: $groupId"

# Read UPNs from file
$userUPNs = Get-Content -Path $UserListFile
foreach ($upn in $userUPNs) {
    $upn = $upn.Trim()
    if (-not $upn) { continue }

    Write-Host "Looking up user: $upn"

    # Find user by UPN
    $user = Get-MgUser -Filter "userPrincipalName eq '$upn'"

    if (-not $user) {
        Write-Warning "User '$upn' not found."
        continue
    }

    $userId = $user.Id
    Write-Host "Adding user '$upn' (ID: $userId) to group..."

    try {
        New-MgGroupMember -GroupId $groupId -BodyParameter @{
            "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$userId"
        }
        Write-Host "Successfully added '$upn' to group."
    } catch {
        Write-Warning "Failed to add '$upn' to group: $_"
    }
}

Write-Host "Script complete."
