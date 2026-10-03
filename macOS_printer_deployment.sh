#!/bin/bash

PRINTER_NAME="PrinterName"
PRINTER_IP="xx.xx.xx.xx"
DISPLAY_NAME="DisplayName"
LOCATION="Location"

# 1. Find and remove ANY existing printer queues pointing to this exact IP address
EXISTING_PRINTERS=$(lpstat -v | grep "$PRINTER_IP" | awk '{print $3}' | tr -d ':')

if [ -n "$EXISTING_PRINTERS" ]; then
    for OLD_PRINTER in $EXISTING_PRINTERS; do
        lpadmin -x "$OLD_PRINTER"
    done
fi

# 2. Safety check: Remove the target queue name in case it exists but points to a dead IP
if lpstat -p "$PRINTER_NAME" &> /dev/null; then
    lpadmin -x "$PRINTER_NAME"
fi

# 3. Add the printer using IPP Everywhere
lpadmin -p "$PRINTER_NAME" -v "ipp://$PRINTER_IP" -D "$DISPLAY_NAME" -L "$LOCATION" -E -m everywhere -o printer-is-shared=false

exit 0
