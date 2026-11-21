#!/bin/bash
# Apply the Fallout-style LOGIN boot splash + login screen on Omarchy.
#   ./install.sh                  logo, colors and update protection
#   ./install.sh --single-splash  also show the splash only on one monitor (edit OUTPUTS below)
set -euo pipefail
cd "$(dirname "$0")"

BG='#0b120c'
TEXT='#1aff80'
# Outputs hidden during the splash and re-enabled before the login screen.
OUTPUTS=(DP-3 HDMI-A-1)

install -Dm644 logo.png ~/.local/share/anso/logo.png

# Keep omarchy-settings updates from overwriting the custom theme files.
if ! grep -q '^NoExtract.*plymouth/themes/omarchy' /etc/pacman.conf; then
  sudo sed -i '/^\[options\]/a NoExtract = usr/share/plymouth/themes/omarchy/* usr/share/sddm/themes/omarchy/*' /etc/pacman.conf
fi

omarchy plymouth set "$BG" "$TEXT" ~/.local/share/anso/logo.png

if [[ ${1:-} == --single-splash ]]; then
  cmdline=""
  for o in "${OUTPUTS[@]}"; do cmdline+=" video=$o:d"; done
  if ! grep -q 'video=.*:d' /etc/default/limine; then
    echo "KERNEL_CMDLINE[default]+=\"$cmdline\"" | sudo tee -a /etc/default/limine >/dev/null
    sudo limine-mkinitcpio
  fi
  sudo install -Dm644 system/boot-screens-restore.service /etc/systemd/system/boot-screens-restore.service
  sudo systemctl enable boot-screens-restore.service
fi

echo "Done. Reboot to see it."
