#!/bin/bash

# Options
shutdown="⏻ Shutdown"
reboot=" Reboot"
logout=" Logout"
lock=" Lock"
suspend="⏾ Suspend"

# Rofi CMD
chosen=$(echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi -dmenu -i -p "Power")

case "$chosen" in
"$shutdown") systemctl poweroff ;;
"$reboot") systemctl reboot ;;
"$logout") swaymsg exit ;;
"$lock") swaylock -c 111111 ;;
"$suspend") systemctl suspend ;;
*) exit 1 ;;
esac
