#!/usr/bin/env bash
# Builds the Asox ISO. Runs inside an Arch Linux container (see the workflow)
# or on any Arch machine as root:  sudo bash scripts/build.sh
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
WORK=/tmp/asox-profile
OUT="$REPO/out"

echo "==> Installing archiso"
sed -i 's/^CheckSpace/#CheckSpace/' /etc/pacman.conf
pacman-key --init
pacman-key --populate archlinux
pacman -Syu --noconfirm --needed archiso

echo "==> Starting from the official releng profile"
rm -rf "$WORK"
cp -r /usr/share/archiso/configs/releng "$WORK"

echo "==> Overlaying Asox files"
cp -a "$REPO/profile/airootfs/." "$WORK/airootfs/"

# releng ships its own passwd/group files; they would erase users created by
# packages (like sddm), so drop them. The live user is created at boot instead.
rm -f "$WORK"/airootfs/etc/{passwd,shadow,group,gshadow}

echo "==> Enabling multilib (needed for Steam and 32-bit Wine/Proton)"
sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' "$WORK/pacman.conf"
sed -i 's/^CheckSpace/#CheckSpace/' "$WORK/pacman.conf"

echo "==> Merging package lists"
cat "$WORK/packages.x86_64" "$REPO/profile/packages.asox" \
  | grep -v '^#' | grep -v '^[[:space:]]*$' | sort -u > "$WORK/packages.x86_64.new"
mv "$WORK/packages.x86_64.new" "$WORK/packages.x86_64"

echo "==> Branding"
sed -i 's/^iso_name=.*/iso_name="asox"/' "$WORK/profiledef.sh"
sed -i 's/^iso_publisher=.*/iso_publisher="Asox Gaming Edition <https:\/\/github.com\/thpunisher\/asox-gaming-edition>"/' "$WORK/profiledef.sh"
sed -i 's/^iso_application=.*/iso_application="Asox Gaming Edition Live"/' "$WORK/profiledef.sh"
for d in efiboot syslinux grub; do
  [ -d "$WORK/$d" ] && find "$WORK/$d" -type f -exec sed -i 's/Arch Linux/Asox Gaming Edition/g' {} +
done

# Smaller + faster compression than the default xz, and permissions for our files
cat >> "$WORK/profiledef.sh" <<'EOP'

airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')
file_permissions+=(
  ["/etc/sudoers.d/10-asox"]="0:0:440"
  ["/usr/local/bin/asox-gamemode"]="0:0:755"
  ["/usr/local/bin/asox-proton-ge"]="0:0:755"
  ["/usr/local/bin/asox-screenshot"]="0:0:755"
)
EOP

echo "==> Networking: use NetworkManager instead of iwd/systemd-networkd"
find "$WORK/airootfs/etc/systemd/system" \( -lname '*systemd-networkd*' -o -lname '*iwd*' \) -delete 2>/dev/null || true
mkdir -p "$WORK/airootfs/etc/systemd/system/multi-user.target.wants"
ln -sf /usr/lib/systemd/system/NetworkManager.service "$WORK/airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service"

echo "==> Enabling SDDM (autologin into Hyprland) and the live-user service"
ln -sf /usr/lib/systemd/system/sddm.service "$WORK/airootfs/etc/systemd/system/display-manager.service"
ln -sf /etc/systemd/system/asox-live-user.service "$WORK/airootfs/etc/systemd/system/multi-user.target.wants/asox-live-user.service"

echo "==> Building the ISO (this takes a while)"
mkdir -p "$OUT"
mkarchiso -v -w /tmp/archiso-work -o "$OUT" "$WORK"
chmod -R a+rwX "$OUT"
ls -lh "$OUT"
