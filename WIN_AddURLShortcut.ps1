# Creates URL shortcut and adds to Public Desktop




# Define the path to the Public Desktop
$publicDesktop = "$env:PUBLIC\Desktop"

# Define the shortcut path
$shortcutPath = Join-Path $publicDesktop "Name of Shortcut.url"

# Create a WScript.Shell COM object
$WshShell = New-Object -ComObject WScript.Shell

# Create the shortcut
$shortcut = $WshShell.CreateShortcut($shortcutPath)

# Set the target URL
$shortcut.TargetPath = "https://URLWebsite.com/"

# Save the shortcut
$shortcut.Save()
