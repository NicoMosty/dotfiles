# 🌌 NicoMosty's Dynamic Dotfiles

A highly customized, fully keyboard-driven, and dynamically themed tiled desktop environment built on **Niri**, **Waybar**, **Sofi/Rofi**, and **SwayNC**. 

Every element—including window borders, status bars, notification overlays, terminal colors, and file managers—dynamically adapts to your active wallpaper using the **Matugen** dynamic color engine.

This repository is managed across multiple devices (Laptop & UltraWide Desktop) using **Chezmoi**.

---

## 🛠️ Technology Stack

* **Window Manager**: [Niri](https://github.com/YaLTeR/niri) (Scrollable, tiled Wayland compositor)
* **Status Bar**: [Waybar](https://github.com/Alexays/Waybar) (Fully customized, dynamic layout)
* **Launcher & Clipboard**: [Rofi](https://github.com/davatorium/rofi) (With compact 3x3 app grid and integrated clipboard and thumbnail wallpaper switcher)
* **Notification Center**: [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) (Minimalist sidebar widget panel)
* **Theme Color Engine**: [Matugen](https://github.com/InkoHX/matugen) (Dynamic material color generation)
* **Wallpaper Daemon**: [Swaybg](https://gitlab.freedesktop.org/rymdport/swaybg) (Managed dynamically via systemd user services)
* **Terminal Emulator**: [Kitty](https://github.com/kovidgoyal/kitty) (GPU-accelerated terminal with dynamic Matugen reloading)
* **File Manager**: [Thunar](https://github.com/xfce-mirror/thunar) (GTK3 file manager styled cleanly with Libadwaita dynamic variables)

---

## 🎛️ Chezmoi Multi-Device Architecture

We manage a single repository on GitHub, but dynamically compile machine-specific preferences (such as different screen layouts and touchpad options) using Chezmoi's **template variables**.

Each machine is classified using the `device` variable inside `~/.config/chezmoi/chezmoi.toml`:

### 💻 Laptop Profile (`device = "Laptop"`)
* **Display Outputs (`3_outputs.kdl`)**: Laptop screen `eDP-1` at `1920x1080` (scaled 1.0, y=1080) positioned below the external HDMI screen.
* **Hardware Inputs (`2_input.kdl`)**: Merged touchpad support (tap, drag-lock, natural scrolling) and Latin American (`latam,us`) keyboard layouts.
* **Waybar Layout (`config.jsonc`)**: Includes the active `"battery"` monitor module on the status bar.

### 🖥️ UltraWide Desktop Profile (`device = "UltraWide"`)
* **Display Outputs (`3_outputs.kdl`)**: Ultrawide monitor `DP-2` at `3440x1440` (scaled 1.0, y=0) positioned beside HDMI.
* **Hardware Inputs (`2_input.kdl`)**: Standard desktop mouse/keyboard layouts.
* **Waybar Layout (`config.jsonc`)**: Excludes the battery indicator cleanly from the layout.

---

## 🔄 Synchronization Commands

### Pushing changes from your active machine:
1. Make changes to your configuration file (e.g., editing `~/.config/niri/config.kdl`).
2. Add it to Chezmoi (if not already tracked):
   ```bash
   chezmoi add ~/.config/niri/config.kdl
   ```
3. Open the source directory, commit, and push your changes to GitHub:
   ```bash
   chezmoi cd
   git add .
   git commit -m "Update Niri shortcuts"
   git push
   ```

### Pulling changes on the other machine:
Simply connect to the other machine and run the Chezmoi update command:
```bash
chezmoi update
```
Chezmoi will automatically pull your updates from GitHub, parse the hostname tags, compile the templates matching that machine's hardware, and apply them on-the-fly!

---

## 🔒 Wallpaper & Color Auto-Reload Daemon
This system uses a custom Systemd user path daemon to monitor `~/.config/wallpaper-path` for changes:
1. When you select a wallpaper using your custom **Rofi Wallpaper selector** (`Mod + Space` -> `Tab` -> `Wallpapers`), it updates `~/.config/wallpaper-path`.
2. The user systemd path (`wallpaper-change.path`) triggers `wallpaper-change.service`.
3. This restarts `swaybg.service` to apply the background, and runs `matugen` to dynamically regenerate and reload Waybar (`colors-matugen.css`), Niri window borders (`4_layout.kdl`), Rofi themes (`colors-matugen.rasi`), SwayNC (`style.css`), Kitty (`current_theme.conf`), and GTK 3 & 4 applications on-the-fly!
