# Copies Azure 365 Groups from one user to another.

#Connect to Azure AD
Connect-MgGraph

# Parameters
$SourceUserAccount = "email@domain.com"
$TargetUserAccount = "email@domain.com"

# Get the Source and Target users
$SourceUser = Get-MgUser -Filter "UserPrincipalName eq '$SourceUserAccount'"
$TargetUser = Get-MgUser -Filter "UserPrincipalName eq '$TargetUserAccount'"

# Check if source and target users are valid
If ($SourceUser -ne $null -and $TargetUser -ne $null) {
    # Get all memberships of the source user
    $SourceMemberships = Get-MgUserMemberOf -UserId $SourceUser.Id

    # Loop through each membership
    ForEach ($Object in $SourceMemberships) {
        # Get detailed group information, including DisplayName
        $Group = Get-MgGroup -GroupId $Object.Id

        # Get members of the group and check if the target user is already a member
        $GroupMembers = Get-MgGroupMember -GroupId $Group.Id | Select-Object -ExpandProperty Id

        If ($GroupMembers -notcontains $TargetUser.Id) {
            # Add target user to the source user's group
            New-MgGroupMember -GroupId $Group.Id -DirectoryObjectId $TargetUser.Id
            Write-Host "Added user to Group:" $Group.DisplayName
        }
    }
} Else {
    Write-Host "Source or Target user is invalid!" -ForegroundColor Yellow
}

