#Move Files and Folders using Move-SPOFilesBetweenFolders

#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
  
Function Move-SPOFilesBetweenFolders
{
  param
    (
        [Parameter(Mandatory=$true)] [string] $SiteURL,
        [Parameter(Mandatory=$true)] [Microsoft.SharePoint.Client.Folder] $SourceFolder,
        [Parameter(Mandatory=$true)] [Microsoft.SharePoint.Client.Folder] $TargetFolder
    )
    Try {
        #Write-host "Copying Files from '$($SourceFolder.ServerRelativeUrl)' to '$($TargetFolder.ServerRelativeUrl)'"
        #Get all Files from the source folder
        $SourceFilesColl = $SourceFolder.Files
        $Ctx.Load($SourceFilesColl)
        $Ctx.ExecuteQuery()
  
        #Iterate through each file and move
        Foreach($SourceFile in $SourceFilesColl)
        {
            #Get all files from source Folder
            $SourceFile =$Ctx.Web.GetFileByServerRelativeUrl($SourceFile.ServerRelativeUrl)
            $Ctx.Load($SourceFile)
            $Ctx.ExecuteQuery()
              
            #Move File to destination
            $TargetFileUrl = $SourceFile.ServerRelativeUrl -Replace $SourceFolderURL,$TargetFolderURL
            $SourceFile.MoveTo($TargetFileUrl, [Microsoft.SharePoint.Client.MoveOperations]::Overwrite)
            $Ctx.ExecuteQuery()
  
            Write-host -f Green "File Moved to: "$TargetFileURL
        }
  
        #Process Sub Folders
        $SubFolders = $SourceFolder.Folders
        $Ctx.Load($SubFolders)
        $Ctx.ExecuteQuery()
        Foreach($SubFolder in $SubFolders)
        {
            If($SubFolder.Name -ne "Forms")
            {
                #Prepare Target Folder
                $EnsureFolderURL = $SubFolder.ServerRelativeUrl -Replace $SourceFolderUrl, $TargetFolderUrl
                Try {
                        $Folder=$Ctx.web.GetFolderByServerRelativeUrl($EnsureFolderURL)
                        $Ctx.load($Folder)
                        $Ctx.ExecuteQuery()
                    }
                catch {
                        #Create Folder
                        if(!$Folder.Exists)
                        {
                            $Folder=$Ctx.Web.Folders.Add($EnsureFolderURL)
                            $Ctx.Load($Folder)
                            $Ctx.ExecuteQuery()
                            Write-host "New Folder Created:"$SubFolder.Name -f Yellow
                        }
                    }
                #Call the function recursively to move all files from source folder to target
                Move-SPOFilesBetweenFolders -SiteURL $SiteURL -SourceFolder $SubFolder -TargetFolder $Folder
 
                #Remove the Source Folder
                $SubFolder.Recycle() | Out-Null
                $Ctx.ExecuteQuery()
            }
        } 
    }
    Catch {
        write-host -f Red "Error Moving File:" $_.Exception.Message
    }
}
  
#Set Parameter values
$SiteURL="https://domainname.sharepoint.com"
$SourceFolderURL ="FolderName"
$TargetFolderURL ="FolderName"
  
#Setup Credentials to connect
$Cred= Get-Credential
  
#Setup the context
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
       
#Get the source and Target Folders
$SourceFolder=$Ctx.Web.GetFolderByServerRelativeUrl($SourceFolderURL)
$Ctx.Load($SourceFolder)
$TargetFolder=$Ctx.Web.GetFolderByServerRelativeUrl($TargetFolderURL)
$Ctx.Load($TargetFolder)
$Ctx.ExecuteQuery()
 
#Call the function 
Move-SPOFilesBetweenFolders -SiteURL $SiteURL -SourceFolder $SourceFolder -TargetFolder $TargetFolder