# Uninstalls Teamviewer Application.



if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))

{

    echo "ERROR: Must run as administrator.";

    return;

}

echo "Attempting to remove Teamviewer."

# Stops TeamViewer process

$tvProcess = Get-Process -Name "teamviewer" -ErrorAction SilentlyContinue

if ($tvProcess) {

    Stop-Process -InputObject $tvProcess -Force

}

# Call uninstaller - 32/64-bit (if exists)

$tv64Uninstaller = Test-Path ${env:ProgramFiles(x86)}"\TeamViewer\uninstall.exe"

if ($tv64Uninstaller) {

    & ${env:ProgramFiles(x86)}"\TeamViewer\uninstall.exe" /S | out-null

}

$tv32Uninstaller = Test-Path ${env:ProgramFiles}"\TeamViewer\uninstall.exe"

if ($tv32Uninstaller) {

    & ${env:ProgramFiles}"\TeamViewer\uninstall.exe" /S | out-null

}

# Ensure all registry keys have been removed - 32/64-bit (if exists)

$tvRegKey64 = Test-Path HKLM:\SOFTWARE\WOW6432Node\TeamViewer

if ($tvRegKey64) {

    Remove-Item -path HKLM:\SOFTWARE\WOW6432Node\TeamViewer -Recurse

}

$tvInstallTempRegKey64 = Test-Path HKLM:\SOFTWARE\WOW6432Node\TVInstallTemp

if ($tvInstallTempRegKey64) {

    Remove-Item -path HKLM:\SOFTWARE\WOW6432Node\TVInstallTemp -Recurse

}

$tvRegKey32 = Test-Path HKLM:\SOFTWARE\TeamViewer

if ($tvRegKey32) {

    Remove-Item -path HKLM:\SOFTWARE\TeamViewer -Recurse

}

$tvInstallTempRegKey32 = Test-Path HKLM:\SOFTWARE\TeamViewer

if ($tvInstallTempRegKey32) {

    Remove-Item -path HKLM:\SOFTWARE\TVInstallTemp -Recurse

}
