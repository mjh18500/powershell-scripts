# Resets AD user Password. Prompts to enter username and new password.


function Reset-ADPassword {

    param($actName)
    
    if(!$actName){$actName = Read-Host "Enter username"}
    $usrObj = Resolve-UserName $actName

    If ($usrObj) {    
        
        Write-Host `n"Password reset:" $usrObj.Name -ForegroundColor $foregroundColor
        
        Write-Host "1. Reset and flag"
        Write-Host "2. Reset and do not flag"
        Write-Host "3. Just flag (or unflag if flagged)"`n
        
    
        $psdOp = Read-Host "Please specify an option #" 
        Write-Host "Note: You will be prompted to confirm any option you select." -ForegroundColor $foregroundColor
    
        Switch ($psdOp)  {
    
            1 { 
                
                $resetTo = Read-Host "Reset password to" -AsSecureString
                $resetTo = $resetTo | ConvertFrom-SecureString
                $PlainTextPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR( (ConvertTo-SecureString $resetTo) ))
                Set-QADUser $usrObj -UserPassword $PlainTextPassword -UserMustchangePassword $true -Credential $adminCredential -confirm }
    
            2 { 
                
                $resetTo = Read-Host "Reset password to" -AsSecureString
                $resetTo = $resetTo | ConvertFrom-SecureString
                $PlainTextPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR( (ConvertTo-SecureString $resetTo) ))
                Set-QADUser $usrObj -UserPassword $PlainTextPassword -UserMustchangePassword $false -Credential $adminCredential -confirm }
    
            3 { 
                
                if ($usrObj.UserMustChangePassword -eq $true) {
                    Set-QADUser $usrObj -UserMustChangePassword  $false  -Credential $adminCredential -confirm }
                else { Set-QADUser $usrObj -UserMustchangePassword $true -Credential $adminCredential -confirm } }  
        }
    } 
}