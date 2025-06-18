# Copies distribution groups of one user to another in Exchange Online.

#Connect to Exchange Online
Connect-ExchangeOnline

# Define the email addresses of the source and target users
$sourceUserEmail = "email@domain.com"
$targetUserEmail = "email@domain.com"

# Get the source and target users
$sourceUser = Get-Mailbox -Identity $sourceUserEmail
$targetUser = Get-Mailbox -Identity $targetUserEmail

# Check if both user objects are found
if ($sourceUser -and $targetUser) {
    # Get all distribution groups that the source user is a member of using a more precise filter
    $groups = Get-DistributionGroup | Where-Object {
        (Get-DistributionGroupMember -Identity $_.PrimarySmtpAddress | Where-Object {
            $_.PrimarySmtpAddress -eq $sourceUserEmail
        })
    }

    # Add the target user to each group
    if ($groups) {
        foreach ($group in $groups) {
            try {
                Add-DistributionGroupMember -Identity $group.PrimarySmtpAddress -Member $targetUserEmail
                Write-Output "Added $targetUserEmail to $($group.DisplayName)"
            } catch {
                Write-Output "Failed to add $targetUserEmail to $($group.DisplayName): $_"
            }
        }
    } else {
        Write-Output "No distribution groups found for the user $sourceUserEmail."
    }
} else {
    if (-not $sourceUser) {
        Write-Output "Source user $sourceUserEmail not found."
    }
    if (-not $targetUser) {
        Write-Output "Target user $targetUserEmail not found."
    }
}
