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

# Install game if not present
if [ -z "$(ls -A "$GAME_DIR" 2>/dev/null)" ]; then
  echo "[INFO] No game installation found. Looking for installer files in $INSTALLER_DIR..."
  INSTALLER_EXE="$(find "$INSTALLER_DIR" -type f -name '*.exe' | head -n 1 || true)"
  if [ -z "$INSTALLER_EXE" ]; then
    echo "[ERROR] No installer found in $INSTALLER_DIR"
    echo "        Place FarmingSimulator2022.exe (+ .bin parts) into $INSTALLER_DIR and restart."
    exit 1
  fi
  echo "[INFO] Running installer: $INSTALLER_EXE"
  wine "$INSTALLER_EXE" /S || { echo "[ERROR] Installer failed"; exit 1; }
  echo "[INFO] Installation complete."
fi

# Copy config (optional)
if [ -d "$CONFIG_DIR" ]; then
  echo "[INFO] Syncing config ..."
  mkdir -p "$GAME_DIR/config"
  cp -rT "$CONFIG_DIR" "$GAME_DIR/config" || true
fi

# If dedicatedServer.xml exists, patch a few fields from env (optional)
DEDICATED_XML="$GAME_DIR/dedicatedServer.xml"
if command -v xmlstarlet >/dev/null 2>&1 && [ -f "$DEDICATED_XML" ]; then
  echo "[INFO] Updating dedicatedServer.xml from env (if provided)"
  xmlstarlet ed --inplace \
    -u "/server/webserver/initial_admin/username" -v "${WEB_USERNAME:-admin}" \
    -u "/server/webserver/initial_admin/passphrase" -v "${WEB_PASSWORD:-}" \
    -u "/server/@name" -v "${SERVER_NAME:-FarmingSimulator22}" \
    "$DEDICATED_XML" || true
fi

cd "$GAME_DIR"
echo "[INFO] Starting FS22 Dedicated Server..."
# Prefer dedicatedServer.exe if present
if [ -f "./dedicatedServer.exe" ]; then
  exec wine ./dedicatedServer.exe
elif [ -f "./DedicatedServer.exe" ]; then
  exec wine ./DedicatedServer.exe
else
  # fallback: game exe in server mode
  exec wine ./FarmingSimulator2022.exe -server
fi
