# Creates Shortcuts for Microsoft Office Apps on Public Desktop

# Shortcut output folder (Public Desktop)
$desktopPath = "$env:Public\Desktop"

# COM object for creating shortcuts
$WshShell = New-Object -ComObject WScript.Shell

# List of Office applications with their expected paths
$apps = @(
    @{
        Name = "Microsoft Outlook"
        Path = "c:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
        Icon = "c:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE, 0"
    },
    @{
        Name = "Microsoft Word"
        Path = "c:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"
        Icon = "c:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE, 0"
    },
    @{
        Name = "Microsoft Excel"
        Path = "c:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"
        Icon = "c:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE, 0"
    },
    @{
        Name = "OneDrive"
        Path = "c:\Program Files\Microsoft OneDrive\OneDrive.exe"
        Icon = "c:\Program Files\Microsoft OneDrive\OneDrive.exe, 0"
    }
)

# Create each shortcut
foreach ($app in $apps) {
    if (Test-Path $app.Path) {
        $shortcutFile = Join-Path $desktopPath ("$($app.Name).lnk")
        $shortcut = $WshShell.CreateShortcut($shortcutFile)
        $shortcut.TargetPath = $app.Path
        $shortcut.WindowStyle = 1
        $shortcut.Description = $app.Name
        $shortcut.IconLocation = $app.Icon
        $shortcut.Save()
        Write-Output "Created shortcut for $($app.Name)"
    } else {
        Write-Warning "Executable not found for $($app.Name): $($app.Path)"
    }
}
