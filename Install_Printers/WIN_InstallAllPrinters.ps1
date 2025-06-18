# Installs multiple specified printers. All certificates, driver files, and scripts should be placed under the same folder.

# Path to the certificate file
$certificatePath = "file.cer"

# Path to the install script
$installScript = "Install-Printer.ps1"

# Add certificate to Trusted Publisher store. Remove if not needed.
certutil -addstore "TrustedPublisher" $certificatePath

# Define an array of printer configurations. Change as needed.

$printers = @(
    @{
        IP = "192.168.175.250"
        Name = "PRINTER 1"
        Driver = "SHARP MX-M5071 PCL6"
        INF = "su2emenu.inf"
    },
    @{
        IP = "192.168.175.144"
        Name = "PRINTER 2"
        Driver = "HP LaserJet Pro M402-M403 n-dne PCL 6"
        INF = "hpdo602a_x64.inf"
    },
    @{
        IP = "192.168.176.250"
        Name = "PRINTER 3"
        Driver = "SHARP BP-70M55 PCL6"
        INF = "su3emenu.inf"
    }
)

# Loop through each printer and install
foreach ($printer in $printers) {
    $portName = "IP_$($printer.IP)"
    
    Start-Process powershell.exe -ArgumentList @(
        '-ExecutionPolicy', 'Bypass',
        '-File', "`"$installScript`"",
        '-PortName', "`"$portName`"",
        '-PrinterIP', "`"$($printer.IP)`"",
        '-PrinterName', "`"$($printer.Name)`"",
        '-DriverName', "`"$($printer.Driver)`"",
        '-INFFile', "`"$($printer.INF)`""
    ) -WindowStyle Hidden
}
