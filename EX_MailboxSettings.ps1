# Grabs a list of email address in txt file and configures client access settings for each mailbox. This specifically enables Outlook on Web. Exchange Online

Get-Content "c:\path\file.txt" | foreach {Set-CasMailbox $_ -OWAEnabled $true} # Change paramaters as needed.

# Modifys settings of existing mailboxes. This specifically sets quotas for a group mailbox in Exchange Online

Set-Mailbox -GroupMailbox GroupMailboxName -ProhibitSendQuota 98GB -ProhibitSendReceiveQuota 99GB -IssueWarningQuota 97GB # Change GroupMailboxName and parameters/quota size as needed.

# Checks the Group mailbox to confirm Quota sizes.

Get-Mailbox -GroupMailbox <GroupMailBoxName> |ft ProhibitSendReceiveQuota,ProhibitSendQuota,IssueWarningQuota

