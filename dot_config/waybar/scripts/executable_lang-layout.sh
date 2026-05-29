#!/usr/bin/env bash

layout=$(niri msg -j keyboard-layouts | jq -r '.names[.current_idx]')

# Simplificar nombres largos
case "$layout" in
"Spanish (Latin American)") out="LATAM" ;;
"English (US, intl., with dead keys)") out="US-INTL" ;;
*) out="$layout" ;;
esac

# Waybar espera JSON si usamos return-type=json
echo "{\"text\": \"$out\", \"tooltip\": \"$layout\"}"
