################################

# 1. Connect (disabling WAM to avoid the crash)
Connect-IPPSSession -UserPrincipalName "admin-upn" -EnableSearchOnlySession -DisableWAM

# 2. Build and start the search

New-ComplianceSearch -Name "TicketNumber" -ExchangeLocation All -ContentMatchQuery 'From:email-address'
Start-ComplianceSearch -Identity "TicketNumber"

################################

Get-ComplianceSearch -Identity "TicketNumber"  # Check for Completed status

################################

(Get-ComplianceSearch -Identity "TicketNumber").Items # How many items it found

################################

New-ComplianceSearchAction -SearchName "TicketNumber" -Purge -PurgeType HardDelete  # PURGE IT

################################

Get-ComplianceSearchAction -Identity "TicketNumber_Purge" ## CHECK STATUS (_Purge has to stay)

################################

(Get-ComplianceSearchAction -Identity "TicketNumber_Purge").Results ## PROOF of results (_Purge has to stay)

