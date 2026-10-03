$OldPrinterName = "PrinterName"

# Check if the ghost printer exists on the machine
if (Get-Printer -Name $OldPrinterName -ErrorAction SilentlyContinue) {
    # remove the printer from Windows
    Remove-Printer -Name $OldPrinterName -ErrorAction SilentlyContinue
}
