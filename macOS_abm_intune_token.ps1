## check the apple business manager <-> intune connection token

# Connect to Graph 
Connect-MgGraph -Scopes "DeviceManagementServiceConfig.Read.All"

# Query the beta endpoint for Apple Deployment Program tokens
$uri = "https://graph.microsoft.com/beta/deviceManagement/depOnboardingSettings"
$abmTokens = Invoke-MgGraphRequest -Method GET -Uri $uri

# Output the token details and extract the underlying error code
$abmTokens.value | Select-Object `
    @{Name="Apple ID"; Expression={$_.appleIdentifier}},
    @{Name="Last Successful Sync"; Expression={$_.lastSuccessfulSyncDateTime}},
    @{Name="Sync Status"; Expression={$_.lastSyncStatus}},
    @{Name="Error Code"; Expression={$_.lastSyncErrorCode}} | Format-Table -AutoSize
