## get a report of all windows devices and their versions

Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

# Windows 11 build numbers start at 10.0.22000
Get-MgDeviceManagementManagedDevice -Filter "operatingSystem eq 'Windows'" -All | 
    Where-Object { [version]$_.osVersion -ge [version]"10.0.22000" } | 
    Select-Object deviceName, 
        userDisplayName,
        osVersion, 
        @{
            Name = 'FeatureUpdateVersion';
            Expression = {
                switch -Wildcard ($_.osVersion) {
                    "10.0.263*" { "26H2" }
                    "10.0.262*" { "25H2" }
                    "10.0.261*" { "24H2" }
                    "10.0.22631*" { "23H2" }
                    "10.0.22621*" { "22H2" }
                    "10.0.22000*" { "21H2" }
                    default { "Other/Insider Build" }
                }
            }
        } | 
    Export-Csv -Path "C:\Temp\Windows11_Version_Report.csv" -NoTypeInformation
