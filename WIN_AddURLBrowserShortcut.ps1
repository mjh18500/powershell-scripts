#Adds Shortcut to URL and opens in Chrome.
#Adds to Public Desktop



# Define variables
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"  #Path to browser exe
$url = "https://websiteurl.com" 
$shortcutPath = "$env:Public\Desktop\Shortcut Name.lnk"    #Path to desired location

# Ensure Chrome exists
if (-Not (Test-Path $chromePath)) {
    Write-Error "Google Chrome not found at $chromePath"
    exit 1
}

# Create WScript.Shell COM object
$WshShell = New-Object -ComObject WScript.Shell

# Create shortcut
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $chromePath
$shortcut.Arguments = $url
$shortcut.WindowStyle = 1
$shortcut.Description = "Shortcut Description" #Description for Shortcut
$shortcut.IconLocation = "$chromePath, 0"
$shortcut.Save()

Write-Output "Shortcut created at: $shortcutPath"
