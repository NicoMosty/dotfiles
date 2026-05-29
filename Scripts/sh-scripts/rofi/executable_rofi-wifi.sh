#!/bin/bash

# rofi-wifi-connect.sh
# A script to manage WiFi connections using Rofi with single column and submenus
# Created for: NicoMosty
# Last updated: 2025-05-20 05:23:30

# Dependencies: rofi, NetworkManager, nmcli

# Configuration variables
ROFI_WIDTH="15%" # Width of Rofi windows (can be adjusted here)

# Create config directory if it doesn't exist
CONFIG_DIR="$HOME/.config/rofi-wifi-connect"
mkdir -p "$CONFIG_DIR"

# Permanent and temporary cache files
PERMANENT_SCAN_CACHE="$CONFIG_DIR/wifi-scan-cache"
SCAN_CACHE="/tmp/rofi-wifi-scan-cache"
LAST_SCAN_TIME="$CONFIG_DIR/last-scan-time"

# Check if required dependencies are installed
command -v rofi >/dev/null 2>&1 || {
  echo "Rofi is not installed. Aborting."
  exit 1
}
command -v nmcli >/dev/null 2>&1 || {
  echo "NetworkManager CLI (nmcli) is not installed. Aborting."
  exit 1
}

# Function to run Rofi with consistent theme
run_rofi() {
  local prompt="$1"
  local lines="$2"
  local input="$3"
  local extra_opts="$4"

  echo -e "$input" | rofi \
    -theme-str "window {width: $ROFI_WIDTH;}" \
    -theme-str "listview {columns: 1;}" \
    -dmenu -i -p "$prompt" -lines "$lines" $extra_opts
}

# Function to connect to a WiFi network
connect_to_wifi() {
  local ssid="$1"
  local password

  # Check if the network requires a password
  if nmcli -t -f SECURITY device wifi list | grep -q "^$ssid:.*WPA\|^$ssid:.*WEP"; then
    # Use Rofi to get the password
    password=$(run_rofi "Enter password for $ssid" "0" "" "-password")

    if [ -z "$password" ]; then
      notify-send "WiFi Connection" "Password entry cancelled"
      return 1
    fi

    # Connect with password
    if nmcli device wifi connect "$ssid" password "$password"; then
      notify-send "WiFi Connection" "Successfully connected to $ssid"
    else
      notify-send "WiFi Connection" "Failed to connect to $ssid"
    fi
  else
    # Connect without password
    if nmcli device wifi connect "$ssid"; then
      notify-send "WiFi Connection" "Successfully connected to $ssid"
    else
      notify-send "WiFi Connection" "Failed to connect to $ssid"
    fi
  fi
}

# Function to forget a WiFi network
forget_network() {
  local ssid="$1"

  # Delete all connections for the specified SSID
  if nmcli connection delete id "$ssid"; then
    notify-send "WiFi Connection" "Forgotten network: $ssid"
  else
    notify-send "WiFi Connection" "Failed to forget network: $ssid"
  fi
}

# Function to show network details
show_network_details() {
  local ssid="$1"

  # Get detailed information about the network
  local details=$(nmcli -f ALL device wifi list | grep -i "$ssid")

  # Display details in Rofi with wider width for details
  local temp_width="$ROFI_WIDTH"
  ROFI_WIDTH="80%"
  run_rofi "Details for $ssid" "10" "$details" ""
  ROFI_WIDTH="$temp_width"
}

# Function to scan for available WiFi networks and store results in a format that's easier to parse
scan_wifi() {
  notify-send "Scanning for WiFi networks..."
  nmcli device wifi rescan
  sleep 1

  # Save scan results to temp file with clear separation between fields
  nmcli --fields SSID,SIGNAL,SECURITY device wifi list | tail -n +2 | sed 's/  */|/g' >"$SCAN_CACHE"

  # Also save to permanent cache
  cp "$SCAN_CACHE" "$PERMANENT_SCAN_CACHE"

  # Save timestamp
  date +%s >"$LAST_SCAN_TIME"

  notify-send "Scan complete."
}

# Function to get last scan time in human readable format
get_last_scan_time() {
  if [ -f "$LAST_SCAN_TIME" ]; then
    local last_time=$(cat "$LAST_SCAN_TIME")
    local current_time=$(date +%s)
    local diff=$((current_time - last_time))

    if [ $diff -lt 60 ]; then
      echo "$diff seconds ago"
    elif [ $diff -lt 3600 ]; then
      echo "$((diff / 60)) minutes ago"
    else
      echo "$((diff / 3600)) hours ago"
    fi
  else
    echo "Never"
  fi
}

# Main function to show available networks
show_networks() {
  # Create symbolic link from permanent cache to temp cache if needed
  if [ ! -f "$SCAN_CACHE" ] && [ -f "$PERMANENT_SCAN_CACHE" ]; then
    cp "$PERMANENT_SCAN_CACHE" "$SCAN_CACHE"
  fi

  # If neither cache exists or last scan is too old, perform a new scan
  if [ ! -f "$SCAN_CACHE" ] || [ ! -f "$LAST_SCAN_TIME" ] || [ $(($(date +%s) - $(cat "$LAST_SCAN_TIME"))) -gt 300 ]; then
    scan_wifi
  fi

  while true; do
    # Get the currently connected SSID directly from iwconfig/iw
    # This is more reliable than using nmcli in some cases
    CURRENT_SSID=""
    WIFI_DEVICE=$(iw dev | grep Interface | awk '{print $2}' | head -1)

    if [ -n "$WIFI_DEVICE" ]; then
      CURRENT_SSID=$(iw dev "$WIFI_DEVICE" link | grep SSID | cut -d: -f2- | sed 's/^[ \t]*//')
    fi

    # Fallback to nmcli if iw doesn't give us an SSID
    if [ -z "$CURRENT_SSID" ]; then
      CURRENT_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
    fi

    # Get list of saved connections
    SAVED_CONNECTIONS=$(nmcli -t -f NAME connection show)

    # Format the list for Rofi display (single column)
    FORMATTED_LIST=""

    # Add "Exit" and "Scan Networks" at the beginning of the list
    LAST_SCAN=$(get_last_scan_time)
    FORMATTED_LIST+="Exit\nScan Networks (Last: $LAST_SCAN)\n---\n"

    # Read from cached scan results and add networks
    while IFS='|' read -r SSID SIGNAL SECURITY; do
      # Skip empty lines or separator lines
      [ -z "$SSID" ] || [[ "$SSID" =~ ^-- ]] && continue

      # Default icons (not connected, not saved)
      CONN_ICON="󰤯"  # WiFi icon (not connected)
      SAVED_ICON=" " # No saved icon

      # Check if this network is currently connected
      if [ "$SSID" = "$CURRENT_SSID" ]; then
        CONN_ICON="󰤨" # WiFi icon (connected)
      fi

      # Check if this network is saved
      if echo "$SAVED_CONNECTIONS" | grep -q "^$SSID$"; then
        SAVED_ICON="󰆓" # Bookmark icon (saved)
      fi

      # Add to the formatted list with both icons
      FORMATTED_LIST+="$CONN_ICON $SAVED_ICON $SSID ($SIGNAL% - $SECURITY)\n"

    done <"$SCAN_CACHE"

    # Calculate appropriate number of lines based on number of networks
    NUM_NETWORKS=$(echo -e "$FORMATTED_LIST" | wc -l)
    if [ $NUM_NETWORKS -gt 15 ]; then
      NUM_NETWORKS=15
    fi

    # Show available networks in Rofi with a single column
    CHOSEN=$(run_rofi "WiFi Networks" "$NUM_NETWORKS" "$FORMATTED_LIST" "")

    # Handle selection
    if [ -z "$CHOSEN" ] || [ "$CHOSEN" = "Exit" ]; then
      exit 0
    elif [[ "$CHOSEN" == *"Scan Networks"* ]]; then
      scan_wifi
    elif [[ "$CHOSEN" == "---" ]]; then
      # Skip separator line
      continue
    elif [[ "$CHOSEN" == *"("*"%"* ]]; then
      # This is a network entry
      # Extract SSID from the chosen option
      SELECTED_SSID=$(echo "$CHOSEN" | sed 's/^[󰤯󰤨] [󰆓 ] *//' | sed 's/ (.*)$//')

      # Check if this network is currently connected
      IS_CONNECTED="no"
      if [ "$SELECTED_SSID" = "$CURRENT_SSID" ]; then
        IS_CONNECTED="yes"
      fi

      # Check if this network is saved
      IS_SAVED="no"
      if echo "$SAVED_CONNECTIONS" | grep -q "^$SELECTED_SSID$"; then
        IS_SAVED="yes"
      fi

      # Get security type from chosen option
      SECURITY=$(echo "$CHOSEN" | sed 's/.*% - \(.*\))/\1/')

      # Show submenu for this network
      show_network_submenu "$SELECTED_SSID" "$SECURITY" "$IS_CONNECTED" "$IS_SAVED"
    fi
  done
}

# Function to display submenu for a specific network
show_network_submenu() {
  local ssid="$1"
  local security="$2"
  local is_connected="$3"
  local is_saved="$4"

  # Options for submenu
  local options=""

  # Show different options based on connection and saved status
  if [ "$is_connected" = "yes" ]; then
    options="Disconnect from \"$ssid\""
  else
    options="Connect to \"$ssid\""
  fi

  if [ "$is_saved" = "yes" ]; then
    options="$options\nForget \"$ssid\""
  fi

  options="$options\nShow details for \"$ssid\"\nBack to network list"

  # Show options in Rofi
  local choice=$(run_rofi "Actions for $ssid" "5" "$options" "")

  # Process chosen action
  case "$choice" in
  *"Connect"*)
    connect_to_wifi "$ssid"
    ;;
  *"Disconnect"*)
    # Use more reliable device name detection
    WIFI_DEVICE=$(iw dev | grep Interface | awk '{print $2}' | head -1)
    if [ -z "$WIFI_DEVICE" ]; then
      WIFI_DEVICE="wlan0" # Default fallback
    fi
    nmcli device disconnect "$WIFI_DEVICE"
    notify-send "WiFi Connection" "Disconnected from $ssid"
    ;;
  *"Forget"*)
    forget_network "$ssid"
    ;;
  *"Show details"*)
    show_network_details "$ssid"
    ;;
  *"Back"*)
    return
    ;;
  *)
    return
    ;;
  esac
}

# Check for iw command
command -v iw >/dev/null 2>&1 || { echo "Warning: 'iw' command not found, some functionality may not work properly."; }

# Initial setup - restore permanent cache if available
if [ -f "$PERMANENT_SCAN_CACHE" ]; then
  # Copy permanent cache to temp location
  cp "$PERMANENT_SCAN_CACHE" "$SCAN_CACHE"

  # Check if the cache is too old (older than 1 hour)
  if [ -f "$LAST_SCAN_TIME" ]; then
    if [ $(($(date +%s) - $(cat "$LAST_SCAN_TIME"))) -gt 3600 ]; then
      # Cache too old, perform a new scan
      scan_wifi
    fi
  else
    # No timestamp file, perform a new scan
    scan_wifi
  fi
else
  # No permanent cache exists yet, perform a scan
  scan_wifi
fi

# Start the main function
show_networks

exit 0
