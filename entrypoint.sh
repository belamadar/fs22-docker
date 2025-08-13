#!/usr/bin/env bash
set -euo pipefail

FS22_DIR="/fs22"
GAME_DIR="$FS22_DIR/game/app"
INSTALLER_DIR="$FS22_DIR/installer"
CONFIG_DIR="$FS22_DIR/config"
DLC_DIR="$FS22_DIR/dlc"

export WINEPREFIX="$FS22_DIR/.wine"
export WINEARCH="win64"

cd "$FS22_DIR"

# Init Wine prefix once
if [ ! -d "$WINEPREFIX" ]; then
  echo "[INFO] Creating WINE prefix..."
  wineboot --init
  # minimal runtime FS22 often needs:
  winetricks -q vcrun2019 || true
fi
 
