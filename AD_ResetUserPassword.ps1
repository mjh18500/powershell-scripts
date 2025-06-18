# Sets a new password for an AD user and does not ask to change.

$newPasswordtext = "Write Password Here"
$username = "UserNameHere"
$newPassword = ConvertTo-SecureString $newPasswordtext -AsPlainText -Force
Set-ADAccountPassword -Identity $username -NewPassword $newPassword -Reset
Set-ADUser -Identity "UsernameHere" -ChangePasswordAtLogon $false
