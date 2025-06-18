# Updates Multiple Users' Password Settings via Microsoft Graph
# This specifically disables a force password change and expiration for 365 users.


# Import the Microsoft Graph Users module
Import-Module Microsoft.Graph.Users

# Connect to Microsoft Graph with the appropriate scopes
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Path to the text file with user email addresses (one per line)
$emailListPath = "c:\path\to\file.txt"

# Read email addresses from the file
$emailAddresses = Get-Content -Path $emailListPath

# Loop through each email address
foreach ($email in $emailAddresses) {
    $email = $email.Trim()

    Write-Host "Updating user: $email"

    # Create the body parameter to update passwordProfile and passwordPolicies
    $params = @{
        passwordProfile = @{
            forceChangePasswordNextSignIn = $false
            forceChangePasswordNextSignInWithMfa = $false
        }
    }

    {
        # Apply the update
        Update-MgUser -UserId $email -BodyParameter $params      
    }

Update-MgUser -UserId "$email" -PasswordPolicies DisablePasswordExpiration #Additional policy

Write-Host "Successfully updated $email" -ForegroundColor Green
    
    
}
