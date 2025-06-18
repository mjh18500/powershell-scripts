# Variables. Change as needed
$firstName = "FirstName"
$lastName = "LastName"
$samAccountName = "accountname"
$userPrincipalName = "$samAccountName@$domainName"
$ouPath = "OU=OU NAME,OU=OU NAME,DC=domain,DC=local"  # Modify this for each domain structure
$password = "PasswordHere"  # Change as needed
$domainName = "domain.local"  # Change for other domains

# Convert password to secure string
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Create the user
New-ADUser `
    -Name "$firstName $lastName" `
    -GivenName $firstName `
    -Surname $lastName `
    -SamAccountName $samAccountName `
    -UserPrincipalName $userPrincipalName `
    -Path $ouPath `
    -AccountPassword $securePassword `
    -PassThru `
    -Enabled $true
