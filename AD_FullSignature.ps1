# Grabs AD info of logged in user and create and adds a signture to Outlook.


[CmdletBinding()]
param (
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]
    $CompanyName,
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]
    $Website,
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("ascii", "utf8", "unicode", "utf32")]
    [string]
    $Encoding = "unicode"
)

# Configuration

$fileExists = Test-Path -Path "\\path\to\signaturepic2.jpg" # Check to see if a signature picture is available. Change or remove if an additional picture is not used.
if ($fileExists) {
$logo2 = "\\path\to\signaturepic2.jpg"
}

$logo = "\\path\to\signaturepic.jpg"    # Primary signature pic. Change or Remove if not needed.
$folderLocation = Join-Path -Path $Env:appdata -ChildPath 'Microsoft\signatures' # Location of where user signature files are stored.
$fileName = 'Full Signature'     #  Name of signture that will display in Outlok signature settings.
$file  = Join-Path -Path $folderLocation -ChildPath $fileName

# Creates a class named 'UserAccount' to define properties for an object.

class UserAccount {
    [string]$Name
    [string]$DistinguishedName
    [string]$UserPrincipalName
    [string]$DisplayName
    [string]$GivenName
    [string]$Initials
    [string]$Surname
    [string]$Description
    [string]$JobTitle
    [string]$Department
    [string]$Company
    [string]$EmailAddress
    [string]$StreetAddress
    [string]$City
    [string]$State
    [string]$PostalCode
    [string]$Country
    [string]$TelephoneNumber
    [string]$Mobile
    [string]$Pager
    [string]$Fax
    [string]$HomePhoneNumber
    [string]$OtherHomePhoneNumber
    [string]$HomeFax
    [string]$OtherFax
    [string]$IPPhone
    [string]$OtherIPPhone
    [string]$WebPage
    [string]$ExtensionAttribute1
    [string]$ExtensionAttribute2
    [string]$ExtensionAttribute3
    [string]$ExtensionAttribute4
    [string]$ExtensionAttribute5
    [string]$ExtensionAttribute6
    [string]$ExtensionAttribute7
    [string]$ExtensionAttribute8
    [string]$ExtensionAttribute9
    [string]$ExtensionAttribute10
    [string]$ExtensionAttribute11
    [string]$ExtensionAttribute12
    [string]$ExtensionAttribute13
    [string]$ExtensionAttribute14
    [string]$ExtensionAttribute15
}

# Uses the UserAccount class to create a new object with the defined properties. Change or add as needed. Grabs the details of the logged in user.

function Get-UserDetails {
    [CmdletBinding()]
    param ()

    try {
        $user = (([adsisearcher]"(&(objectCategory=User)(samaccountname=$env:username))").FindOne().Properties)
        Write-Verbose "User found for $($env:username)"

        $userAccount = New-Object UserAccount
        $userAccount.Name = $user['name'] -join ''
        $userAccount.DistinguishedName = $user['distinguishedname'] -join ''
        $userAccount.UserPrincipalName = $user['userprincipalname'] -join ''
        $userAccount.DisplayName = $user['displayname'] -join ''
        $userAccount.GivenName = $user['givenname'] -join ''
        $userAccount.Initials = $user['initials'] -join ''
        $userAccount.Surname = $user['sn'] -join ''
        $userAccount.Description = $user['description'] -join ''
        $userAccount.JobTitle = $user['title'] -join ''
        $userAccount.Department = $user['department'] -join ''
        $userAccount.EmailAddress = $user['mail'] -join ''
        $userAccount.StreetAddress = $user['streetaddress'] -join ''
        $userAccount.City = $user['l'] -join ''
        $userAccount.State = $user['st'] -join ''
        $userAccount.PostalCode = $user['postalcode'] -join ''
        $userAccount.Country = $user['c'] -join ''
        $userAccount.TelephoneNumber = $user['telephonenumber'] -join ''
        $userAccount.Mobile = $user['mobile'] -join ''
        $userAccount.Pager = $user['pager'] -join ''
        $userAccount.Fax = $user['facsimiletelephonenumber'] -join ''
        $userAccount.HomePhoneNumber = $user['homephone'] -join ''
        $userAccount.OtherHomePhoneNumber = $user['otherhomephone'] -join ''
        $userAccount.HomeFax = $user['homefax'] -join ''
        $userAccount.OtherFax = $user['otherfacsimiletelephonenumber'] -join ''
        $userAccount.IPPhone = $user['ipphone'] -join ''
        $userAccount.OtherIPPhone = $user['otheripphone'] -join ''

        $userAccount.Company = if ($null -eq $CompanyName) { $user['company'] } else { $CompanyName }
        $userAccount.WebPage = if ($null -eq $Website) { $user['wWWHomePage'] } else { $Website }
        
        $userAccount.ExtensionAttribute1 = $user['extensionattribute1'] -join ''
        $userAccount.ExtensionAttribute2 = $user['extensionattribute2'] -join ''
        $userAccount.ExtensionAttribute3 = $user['extensionattribute3'] -join ''

        return $userAccount
    } catch {
        Write-Error "Unable to query Active Directory for user information. Details: $($_.Exception.Message)"
        exit 1
    }
}


# Creates function that sets registry entries for signature.

function Set-RegistryEntries {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Version,
        [Parameter(Mandatory = $true)]
        [string] $SignatureName
    )

    $regPathGeneral = "HKCU:\Software\Microsoft\Office\$Version\Common\General"
    $regPathMailSettings = "HKCU:\Software\Microsoft\Office\$Version\Common\MailSettings"
    $regPathOutlookSetup = "HKCU:\Software\Microsoft\Office\$Version\Outlook\Setup"

    Write-Verbose "Setting registry keys"
    New-ItemProperty -Path $regPathGeneral -Name "Signatures" -Value "signatures" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $regPathMailSettings -Name "NewSignature" -Value $SignatureName -PropertyType String -Force | Out-Null
    Write-Verbose "Removing First-Run registry key"
    Remove-ItemProperty -Path $regPathOutlookSetup -Name "First-Run" -ErrorAction SilentlyContinue | Out-Null
}

# Checks to see if Office Version 14, 15, or 16 is installed.

function Get-OfficeVersion {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting office version"
    $officeVersions = @("16.0", "15.0", "14.0")
    $basePath = "HKCU:\Software\Microsoft\Office\"

    foreach ($version in $officeVersions) {
        $path = $basePath + $version + "\Outlook"
        if (Test-Path -Path $path) {
            Write-Verbose "Office Version: $version"
            return $version
        }
    }

    Write-Error "No compatible version of Microsoft Office found."
    exit 1
}


# Creates the HTML signature. Edit HTML code as needed.

function Get-SignatureHTML {
    [CmdletBinding()]
    param (
        [UserAccount]$user
    )

    Write-Verbose "Building HTML"

    return @"

<p class=MsoNormal style='line-height:115%'>

$(if($user.DisplayName){"<a name='_MailAutoSig'><b><span
style='font-size:12.0pt;line-height:115%;font-family:Arial,sans-serif'>$($user.DisplayName)<br>
</span></b></a>"})
$(if($user.Description){"<span style='mso-bookmark:_MailAutoSig'></span>
<span
style='font-size:10.0pt;line-height:115%;font-family:Arial,sans-serif'>$($user.Description)<br>"})

$(if($user.JobTitle){"$($user.JobTitle)<br></span>
"})

<b><span style='font-size:12.0pt;line-height:115%;font-family:Arial,sans-serif;
color:navy'>Company Name</span></b>

$(if($user.StreetAddress){ "<span style='font-size:
10.0pt;line-height:115%;font-family:Arial,sans-serif;color:black'><br>
$($user.StreetAddress)<br>" })
$(if($user.City){ "$($user.City), Texas," })
$(if($user.PostalCode){ "$($user.PostalCode) <br></span>"})

$(if($user.TelephoneNumber){"<span style='font-size:10.0pt;line-height:115%;font-family:Wingdings;
color:black'> &#40;</span>
<span style='font-size:10.0pt;line-height:115%;font-family:
Arial,sans-serif;color:black'> Phone $($user.TelephoneNumber)<br>
</span>"})

$(if($user.Mobile){"<span style='font-size:10.0pt;line-height:115%;font-family:Wingdings 2';
color:black'>&#39;</span><span style='font-size:10.0pt;line-height:115%;font-family:
Arial,sans-serif;color:black'> Mobile $($user.Mobile)<br>
</span>"})


$(if($user.Fax){"<span style='font-size:10.0pt;line-height:115%;font-family:Wingdings 2;
color:black'>7</span><span style='font-size:10.0pt;line-height:115%;font-family:
Arial,sans-serif;color:black'> Fax $($user.Fax)<br>
</span>"})

$(if($user.EmailAddress){"<span style='font-size:10.0pt;line-height:115%;font-family:Wingdings;
color:black'>&#47;</span><span style='font-size:10.0pt;line-height:115%;font-family:
Arial,sans-serif;color:black'> </span><a href='mailto:$($user.EmailAddress)'><span
style='font-size:12.0pt;line-height:115%'>$($user.EmailAddress)</span></a><br>"})

<span style='font-size:10.0pt;line-height:115%;font-family:Wingdings;
color:black'>:</span><span style='font-size:10.0pt;line-height:115%;font-family:
Arial,sans-serif;color:black'> Please visit us on the web at </span><a
href="http://www.companywebsite.com/"><span style='font-size:12.0pt;line-height:115%'>http://www.companywebsite.com</span></a><br>

$(if($logo){"<span style='font-size:10.0pt;line-height:115%;font-family:Arial,sans-serif;
color:black;mso-no-proof:yes'><img border=0 width=624 height=237 src='$logo'></span>"})

$(if($logo2){"<span
style='font-size:10.0pt;line-height:115%;font-family:Arial,sans-serif;
color:black;mso-no-proof:yes'><img border=0 width=336 height=192 src='$logo2'></span>"})
</p>

"@


}

# Creates plain text signature. Edit as needed.

function Get-SignaturePlainText {
    [CmdletBinding()]
    param (
        [UserAccount]$user
    )

    Write-Verbose "Building Plaint Text"

    return @" 
$(if($user.DisplayName){"$($user.DisplayName)"})
$(if($user.Description){"$($user.Description)"})
$(if($user.JobTitle){"$($user.JobTitle)"})
Company Name Inc.
$(if($user.StreetAddress){ "$($user.StreetAddress)" })
$(if($user.City){ "$($user.City), Texas," })
$(if($user.PostalCode){ "$($user.PostalCode)"})
$(if($user.TelephoneNumber){"Phone $($user.TelephoneNumber)"})
$(if($user.Mobile){"Mobile $($user.Mobile)"})
$(if($user.Fax){"Fax $($user.Fax)"})
$(if($user.EmailAddress){"$($user.EmailAddress)"})
Please visit us on the web at http://www.companywebsite.com
"@
}

# CSS Style. Edit as needed.

$style = 
@"
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;}
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Aptos;}
@font-face
	{font-family:"Wingdings 2";
	panose-1:5 2 1 2 1 5 7 7 7 7;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:8.0pt;
	margin-left:0in;
	line-height:107%;
	font-size:11.0pt;
	font-family:"Aptos",sans-serif;}
.MsoChpDefault
	{font-size:11.0pt;}
.MsoPapDefault
	{margin-bottom:8.0pt;
	line-height:107%;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
-->
</style>
"@

# Adds both signture files to users signature folder location.

$officeVersion = Get-OfficeVersion
$user = Get-UserDetails

# If the folder does not exist create it
if (-not (Test-Path -Path $folderLocation)) {
    try {
        Write-Verbose "Creating Director: $folderLocation"
        New-Item -ItemType directory -Path $folderLocation
    } catch {
        Write-Error "Error: Unable to create the signatures folder. Details: $($_.Exception.Message)"
        exit
    }
}

$htmlSignature = Get-SignatureHTML -user $user
$plainTextSignature = Get-SignaturePlainText -user $user

# Save the HTML signature file
try {
    Write-Verbose "Saving HTML signature"
    $style + $htmlSignature | Out-File -FilePath "$file.htm" -Encoding $Encoding
} catch {
    Write-Error "Error: Unable to save the HTML signature file. Details: $($_.Exception.Message)"
    exit 1
}

# Save the text signature folder
try {
    Write-Verbose "Saving txt signature"
    $plainTextSignature | out-file "$file.txt" -encoding $Encoding
} catch {
    Write-Error "Error: Unable to save the text signature file. Details: $($_.Exception.Message)"
    exit 1
}

# Runs the function to set registry entries.

Set-RegistryEntries -Version $officeVersion -SignatureName $fileName