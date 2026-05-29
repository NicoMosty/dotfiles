#!/bin/bash

# Temporary file to store screenshot
TMP_IMG="/tmp/qr_grab_$$.png"

# Select area and take screenshot
if ! grim -g "$(slurp)" "$TMP_IMG"; then
  echo "Screenshot failed or cancelled."
  exit 1
fi

# Extract QR content
QR_DATA=$(zbarimg --quiet --raw "$TMP_IMG")
rm "$TMP_IMG"

# Check if something was found
if [ -z "$QR_DATA" ]; then
  notify-send "QR Reader" "No QR code found."
  exit 1
fi

# Copy to clipboard
echo -n "$QR_DATA" | wl-copy

# Optional: show notification
notify-send "QR Copied!" "$QR_DATA"
