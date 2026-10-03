## on local machine, to check printers

Get-Printer | Select-Object Name, PortName, DriverName

Get-PrinterPort | Select-Object Name, PrinterHostAddress

Remove-PrinterPort -Name "IP_xx.xx.xx.xx"
