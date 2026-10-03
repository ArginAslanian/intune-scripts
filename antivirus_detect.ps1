# check what antivirus is your pc running

## This will tell you what mode is Defender on (Normal/Active, Passive/Blocked)
Get-MpComputerStatus | Select-Object AMRunningMode

## This will tell you what security software does windows see and use
Get-CimInstance -Namespace root\SecurityCenter2 -ClassName AntivirusProduct
