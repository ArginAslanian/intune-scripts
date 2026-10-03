## the install script to put inside the source folder for printer driver app packaging for intune deployment

param (
    [string]$PortName,
    [string]$PrinterIP,
    [string]$PrinterName,
    [string]$DriverName,
    [string]$INFFile
)

$ErrorActionPreference = "Stop"

try {
    $ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

    # 1. Extract certificate from the .cat files and trust it silently
    $catFiles = Get-ChildItem -Path $ScriptPath -Filter "*.cat"
    foreach ($cat in $catFiles) {
        $sig = Get-AuthenticodeSignature $cat.FullName
        if ($sig.SignerCertificate) {
            $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("TrustedPublisher", "LocalMachine")
            $store.Open("ReadWrite")
            $store.Add($sig.SignerCertificate)
            $store.Close()
        }
    }

    # 2. Create printer port
    if (-not (Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue)) {
        Add-PrinterPort -Name $PortName -PrinterHostAddress $PrinterIP
    }

    # 3. Bypass Intune's 32-bit redirection to find the 64-bit pnputil.exe
    $pnpUtil = "$env:windir\sysnative\pnputil.exe"
    if (-not (Test-Path $pnpUtil)) { 
        $pnpUtil = "$env:windir\System32\pnputil.exe" 
    }

    # 4. Inject the driver and log output
    $pnpLog = & $pnpUtil /add-driver "$ScriptPath\$INFFile" 2>&1
    $pnpLog | Out-File -FilePath "C:\PrinterInstallLog.txt"

    Start-Sleep -Seconds 5

    # 5. Map driver and printer
    Add-PrinterDriver -Name $DriverName

    if (-not (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue)) {
        Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PortName
    }

    exit 0
}
catch {
    $_.Exception.Message | Out-File -FilePath "C:\PrinterInstallLog.txt" -Append
    exit 1
}
