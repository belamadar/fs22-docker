#!/usr/bin/env bash
set -e

FS22_DIR="/fs22"
GAME_DIR="$FS22_DIR/game"
INSTALLER_DIR="$FS22_DIR/installer"
CONFIG_DIR="$FS22_DIR/config"
DLC_DIR="$FS22_DIR/dlc"

WINEPREFIX="$FS22_DIR/.wine"
WINEARCH="win64"

cd "$FS22_DIR"

# Create WINE prefix if missing
if [ ! -d "$WINEPREFIX" ]; then
    echo "[INFO] Creating WINE prefix..."
    wineboot --init
fi

# Install game if not already installed
if [ -z "$(ls -A "$GAME_DIR" 2>/dev/null)" ]; then
    echo "[INFO] No game installation found. Looking for installer files in $INSTALLER_DIR..."
    
    INSTALLER_EXE=$(find "$INSTALLER_DIR" -type f -name "*.exe" | head -n 1)
    if [ -z "$INSTALLER_EXE" ]; then
        echo "[ERROR] No installer found in $INSTALLER_DIR"
        echo "Please move your FarmingSimulator2022.exe to the volume mounted to /fs22/installer
        exit 1
    fi

    echo "[INFO] Running installer: $INSTALLER_EXE"
    wine "$INSTALLER_EXE" /S || {
        echo "Installer failed!"
        exit 1
    }

    echo "Installation complete."
fi

# Symlink config
if [ -d "$CONFIG_DIR" ]; then
    echo "Linking config directory..."
    mkdir -p "$GAME_DIR/config"
    cp -r "$CONFIG_DIR"/* "$GAME_DIR/config/" || true
fi

# Add DLC if present
if [ -d "$DLC_DIR" ]; then
    echo "Linking DLC..."
    mkdir -p "$GAME_DIR/dlc"
    cp -r "$DLC_DIR"/* "$GAME_DIR/dlc/" || true
fi

# Start the FS22 server
cd "$GAME_DIR"
echo "Starting FS22 Dedicated Server..."
exec wine DedicatedServer.exe
