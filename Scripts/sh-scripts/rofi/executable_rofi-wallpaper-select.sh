#!/usr/bin/env bash

# Directories where wallpapers are stored
wallpaper_dirs=(
  "/home/nicomosty/Pictures/Wallpapers"
  "/home/nicomosty/Imágenes/wallpaper"
)

# If an option was selected, apply the wallpaper
if [[ -n "$1" ]]; then
  for dir in "${wallpaper_dirs[@]}"; do
    selected_wallpaper="$dir/$1"
    if [[ -f "$selected_wallpaper" ]]; then
      # Update wallpaper-path file
      echo "$selected_wallpaper" > /home/nicomosty/.config/wallpaper-path
      # Update wallpaper symlink
      ln -sf "$selected_wallpaper" /home/nicomosty/.config/wallpaper
      exit
    fi
  done
  exit
fi

# Print all wallpapers from all directories with their image paths as icons
for dir in "${wallpaper_dirs[@]}"; do
  for file in "$dir"/*; do
    if [[ -f "$file" ]]; then
      filename=$(basename "$file")
      # Output to Rofi: label\0icon\x1f/path/to/icon
      echo -en "$filename\0icon\x1f$file\n"
    fi
  done
done
