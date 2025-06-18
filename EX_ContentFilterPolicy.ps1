# Adds domain or email address to Blocked Senders in Exchange Online.

Connect-ExchangeOnline -UserPrincipalName admin@domain.com

Set-HostedContentFilterPolicy -Identity "Default" -BlockedSenderDomains @{Add="","domain.com"}  # Add domain. Change identity if needed. Remove line if not needed

Set-HostedContentFilterPolicy -Identity "Default" -BlockedSenders @{Add="email@domain.com"}  # Add email address. Change identity if needed. Remove line if not needed


# Displays list of blocked entries in the Policy named 'Default'.

Get-HostedContentFilterPolicy -Identity "Default" | Format-List


# Grabs a list of domain names from a csv file (A1 named Recipients) and adds them as allowed senders to a content filter policy named 'SPAM BLOCK'. Exchange Online

Import-Csv “D:\path\file.csv” | foreach {Set-HostedContentFilterPolicy -Identity "SPAM BLOCK" –AllowedSenderDomains @{add=$_.Recipients}} # Change identity as needed.