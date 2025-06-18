# Set a new user password & sign out everywhere in 365.
# Does not ask to change password.

# Import Microsoft Graph module and connect
Connect-MgGraph -Scopes "Directory.AccessAsUser.All"

# Get signed-in user's info
$me = Get-MgUser -Filter "startsWith(UserPrincipalName, 'username')" -Top 1 # Change username to desired user. 
$userId = $me.Id
$userPrincipalName = $me.UserPrincipalName

# Define new password
$newPassword = "NewPasswordHere"  # Change this to a secure password

# Reset your own password
Update-MgUser -UserId $userId -PasswordProfile @{
   ForceChangePasswordNextSignIn = $false
    Password = $newPassword
}


# Invalidate refresh tokens to sign out from all devices
Revoke-MgUserSignInSession -UserId $userId

Disconnect-MgGraph

Write-Host "Password has been reset for: $userPrincipalName"
