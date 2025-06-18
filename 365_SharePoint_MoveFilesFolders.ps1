#  Moves files and folders in Sharepoint using PnP


#Config Variables
$SiteURL = "https://domain.sharepoint.com"
$SourceLibraryURL = "FolderName" #Site Relative URL from the current site
$TargetLibraryURL = "DocumentName/FolderName" #Server Relative URL of the Target Folder
$clientID = "Tenant client ID"
 
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive -clientid $clientID
 
#Get all Items from the Document Library
$Items = Get-PnPFolderItem -FolderSiteRelativeUrl $SourceLibraryURL | Where {$_.Name -ne "Forms"}
 
#Move All Files and Folders Between Document Libraries
Foreach($Item in $Items)
{
    Move-PnPFile -SourceUrl $Item.ServerRelativeUrl -TargetUrl $TargetLibraryURL -AllowSchemaMismatch -Force -AllowSmallerVersionLimitOnDestination
    Write-host "Moved Item:"$Item.ServerRelativeUrl
}



# Get all files in the root of STORAGE (paginated)
$Items = Get-PnPListItem -List $SourceLibraryURL -PageSize 100 -Fields "FileRef", "FileLeafRef", "FSObjType"

foreach ($Item in $Items) {
    # Skip folders and "Forms"
    if ($Item["FSObjType"] -eq 0 -and $Item["FileLeafRef"] -ne "Forms") {
        $FileRef = $Item["FileRef"]            # e.g. /sites/site/Storage/myfile.docx
        $FileName = $Item["FileLeafRef"]
        $TargetUrl = "$TargetLibraryURL/$FileName"

        # Move the file
        Move-PnPFile -SourceUrl $FileRef -TargetUrl $TargetUrl -Force
        Write-Host "Moved: $FileRef"
    }
}