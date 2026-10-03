# manual script for offboarding
# Connect to Microsoft Graph and Exchange Online
Connect-MgGraph -Scopes User.ReadWrite.All, GroupMember.ReadWrite.All, Directory.ReadWrite.All, UserAuthenticationMethod.ReadWrite.All
Connect-ExchangeOnline

# Prompt for the user's UPN/Email
$userEmail = Read-Host "Enter user's UPN (e.g. jdoe@xyz.com)"

# Retrieve the user object to use its properties for the rest of the script
$user = Get-MgUser -UserId $userEmail -Property DisplayName, Id, Mail
if (-not $user) { Write-Warning "User not found. Exiting."; return }

Write-Host "Removing calendar events for the last 365 days..." -ForegroundColor Cyan
# Cancel all meetings organized by the user
Remove-CalendarEvents -Identity $user.Mail -CancelOrganizedMeetings -QueryWindowInDays 365 -Confirm:$false

Write-Host "Resetting user password..." -ForegroundColor Cyan
# Generate a random 16-character password + "A1!" and force change on next sign-in
$tempPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_}) + "A1!"
Update-MgUser -UserId $user.Id -PasswordProfile @{ Password = $tempPassword; ForceChangePasswordNextSignIn = $true }

Write-Host "Removing authentication methods..." -ForegroundColor Cyan
# Find all non-password authentication methods and delete them via Microsoft Graph API
Get-MgUserAuthenticationMethod -UserId $user.Id | Where-Object { $_.AdditionalProperties["@odata.type"] -notmatch "passwordAuthenticationMethod" } | ForEach-Object { Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/users/$($user.Id)/authentication/methods/$($_.Id)" }

Write-Host "Revoking active sign-in sessions..." -ForegroundColor Cyan
# Revoke all active sessions for the user
Revoke-MgUserSignInSession -UserId $user.Id | Out-Null

Write-Host "Disabling user account..." -ForegroundColor Cyan
# Block sign-in by disabling the account
Update-MgUser -UserId $user.Id -AccountEnabled:$false

Write-Host "Updating Exchange: Convert to Shared mailbox and Hide from GAL" -ForegroundColor Cyan
# Convert to Shared Mailbox and hide from address lists
Set-Mailbox -Identity $user.Mail -Type Shared -HiddenFromAddressListsEnabled $true

Write-Host "`n✅ Offboarding tasks completed successfully for $($user.Mail)." -ForegroundColor Green
