## Get a report of noncopmliant Windows devices

Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All" # -UseDeviceAuthentication

$devices = Get-MgDeviceManagementManagedDevice `
    -Filter "complianceState eq 'nonCompliant' and operatingSystem eq 'Windows'" `
    -All

$report = foreach ($device in $devices) {

    [PSCustomObject]@{
        DeviceName        = $device.DeviceName
        UserPrincipalName = $device.UserPrincipalName
        ComplianceState   = $device.ComplianceState
        LastCheckIn       = $device.LastSyncDateTime
        OSVersion         = $device.OsVersion
        Manufacturer      = $device.Manufacturer
        Model             = $device.Model
        Ownership         = $device.ManagedDeviceOwnerType
        EnrolledDate      = $device.EnrolledDateTime
    }
}

$report |
    Sort-Object LastCheckIn |
    Export-Csv "C:\Temp\NonCompliantWindowsDevices.csv" -NoTypeInformation
