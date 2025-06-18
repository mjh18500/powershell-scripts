# Set Folder Permissions Based on Username. Gives each user full control of their user Folder.


# Set the path to the user folders
$BasePath = "\\path\users"

# Import all domain users (filter or refine this list as needed)
$Users = Get-ADUser -Filter * -Properties SamAccountName

foreach ($User in $Users) {
    $UserName = $User.SamAccountName
    $FolderPath = Join-Path -Path $BasePath -ChildPath $UserName

    if (Test-Path $FolderPath) {
        Write-Host "Setting permissions for $UserName on $FolderPath"

        # Grant Full Control to the specific user
        icacls $FolderPath /grant "${UserName}:(OI)(CI)F" /T
    } else {
        Write-Warning "Folder not found: $FolderPath"
    }
    }
