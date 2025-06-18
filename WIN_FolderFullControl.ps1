# Grants Full Control of folder to User or Group


# Path to root user folder
$BasePath = "\\folder\path"

# Define the user or group to grant access
$identity = "username"

# Get all folders in the base path
$Folders = Get-ChildItem -Path $BasePath -Directory

foreach ($Folder in $Folders) {
    $FolderPath = $Folder.FullName
    Write-Host "Granting Full Control to '$identity' on $FolderPath"

    # Grant Full Control with inheritance for files and subfolders
    icacls $FolderPath /grant "${identity}:(OI)(CI)F" /T

}
