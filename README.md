# Asox Gaming Edition

An anime-styled, gaming-focused Linux distro: Arch Linux + Hyprland, with Steam, Wine and Proton ready out of the box.

## What's in v0.1

- Live ISO that boots straight into Hyprland (sakura pastel theme, Waybar, Wofi, Mako, Kitty)
- Steam, Lutris, Wine, Winetricks, Gamescope, MangoHud, GameMode, OBS, Discord
- Vulkan drivers for AMD and Intel
- `Super+G` toggles **Game Mode** (blur, animations and gaps off for max FPS)
- `asox-proton-ge` downloads the latest Proton-GE for Steam
- Built automatically by GitHub Actions

## Keybinds

| Keys | Action |
|---|---|
| Super + Enter | Terminal |
| Super + D | App launcher |
| Super + S | Steam |
| Super + G | Game Mode on/off |
| Super + F | Fullscreen |
| Super + Q | Close window |
| Super + L | Lock screen |
| Super + 1-5 | Workspaces |
| Print | Screenshot area |

## Build the ISO

**With GitHub Actions (recommended, works from a Mac):**
push to `main`, then open the Actions tab, pick the run and download the `asox-iso` artifact.

**On an Arch machine:** `sudo bash scripts/build.sh` (ISO ends up in `out/`).

## Try it

- **Real hardware:** write the ISO to a USB stick with balenaEtcher and boot it.
- **Virtual machine:** use UTM (QEMU) with a virtio GPU and 4 GB+ RAM. Hyprland needs GPU acceleration, so
  if the screen stays black, uncomment the `cursor { no_hardware_cursors = true }` block in
  `~/.config/hypr/hyprland.conf`. Real hardware gives the best result.

The live user is `asox` with no password. To install to disk for now, open a terminal and run `archinstall`.

## Layout

```
profile/packages.asox     extra packages added on top of the official Arch releng profile
profile/airootfs/         files copied into the live system (configs, scripts, wallpaper)
scripts/build.sh          builds the ISO (starts from releng, overlays our files)
tools/make_wallpaper.py   generates the default wallpaper
```

## Roadmap

- v0.2: Quickshell widgets, theme engine (wallpaper-driven colors), boot and login themes
- v0.3: Calamares installer + Asox Hub welcome app
- v0.4: NVIDIA support, Proton-GE auto-update, linux-zen kernel on the installed system
- v1.0: website and public release
