#!/bin/bash

set -e # Exit on error

# Directori d'aquest script
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# === CONFIGURACIÓ ===
AUR_LIST="${1:-$SCRIPT_DIR/packages.x86_64.aur}"   # Fitxer amb paquets AUR
BUILD_DIR="${2:-/tmp/aur-build}"         # Directori temporal
REPO_NAME="${3:-customrepo}"            # Nom del repo
REPO_DIR="${4:-$SCRIPT_DIR/packages}"             # On generar el repositori final
WORK_DIR="${5:-$SCRIPT_DIR/workdir}"         # Directori de treball
OUT_DIR="${6:-$SCRIPT_DIR/out}"           # Directori de sortida

sudo rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"

/bin/bash "generate-aur-packages.sh" "$AUR_LIST" "$BUILD_DIR" "$REPO_NAME" "$REPO_DIR"

# Add packages.x86_64.aur to packages.x86_64
cp "$SCRIPT_DIR/packages.x86_64" "$SCRIPT_DIR/packages.x86_64.backup"
echo -e "\n# Paquets AUR generats" >> "$SCRIPT_DIR/packages.x86_64"
cat "$AUR_LIST" >> "$SCRIPT_DIR/packages.x86_64"

# Backup 
cp "$SCRIPT_DIR/pacman.conf" "$SCRIPT_DIR/pacman.conf.backup"
# Replace [path-to-your-repo] with the actual path
sed -i "s|file://\[path-to-your-repo\]|file://$REPO_DIR/$REPO_NAME|g" "$SCRIPT_DIR/pacman.conf"


# Exist workdir and/or out? remove them.
sudo rm -rf "$WORK_DIR" "$OUT_DIR"

# Generar iso
sudo mkarchiso -v .

# Restore packages.x86_64
rm -f packages.x86_64
mv packages.x86_64.backup packages.x86_64

# Restore pacman.conf
rm -f pacman.conf
mv pacman.conf.backup pacman.conf
