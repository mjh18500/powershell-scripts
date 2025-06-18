
# Adds Domain Users group to local Administrators Group.

Add-LocalGroupMember -Group "Administrators" -member "domain\Domain Users"

# Turns off Windows Firewall on the Domain and Private profiles

Set-NetFirewallProfile -Profile Domain,Private -Enabled False

# Allows remote desktop connections to workstation.

Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0

# Disables UAC on workstation.

New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force


# Changes the power plan to High Performance. So to never sleep.

$p = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'High Performance'"      

powercfg /setactive ([string]$p.InstanceID).Replace("Microsoft:PowerPlan\{","").Replace("}","")