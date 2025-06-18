# Removes multiple specified printers. 

# Path to the install script
$installScript = "Remove-Printer.ps1"

# Define an array of printer configurations. Change as needed.

$printers = @(
    @{
        Name = "PRINTER 1"
    },
    @{
        Name = "PRINTER 2"
    },
    @{
        Name = "PRINTER 3"
    }
)

# Loop through each printer and install
foreach ($printer in $printers) {    
    Start-Process powershell.exe -ArgumentList @(
        '-ExecutionPolicy', 'Bypass',
        '-File', "`"$installScript`"",
        '-PrinterName', "`"$($printer.Name)`""
    ) -WindowStyle Hidden
}
