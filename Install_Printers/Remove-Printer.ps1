# Remove printer by printer name.


[CmdletBinding()]
Param (
    [Parameter(Mandatory = $True)]
    [String]$PrinterName
)

Try {
    #Remove Printer
    $PrinterExist = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
    if ($PrinterExist) {
        Remove-Printer -Name $PrinterName -Confirm:$false
    }
}
Catch {
    Write-Warning "Error removing Printer"
    Write-Warning "$($_.Exception.Message)"
}