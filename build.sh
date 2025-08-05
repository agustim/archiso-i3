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

PACMAN_CONF="$SCRIPT_DIR/pacman.conf"
PACKAGES_FILE="$SCRIPT_DIR/packages.x86_64"

# === VALIDACIÓ D'ENTRADES ===
if [[ ! -f "$AUR_LIST" ]]; then
  echo "❌ Fitxer de paquets AUR no trobat: $AUR_LIST"
  exit 1
fi

if [[ ! -f "$PACMAN_CONF" ]]; then
  echo "❌ Fitxer pacman.conf no trobat a: $PACMAN_CONF"
  exit 1
fi

if [[ ! -f "$PACKAGES_FILE" ]]; then
  echo "❌ Fitxer packages.x86_64 no trobat a: $PACKAGES_FILE"
  exit 1
fi

echo "🧹 Netejant repositori anterior: $REPO_DIR"
sudo rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"

echo "📦 Creant repositori AUR"
/bin/bash "generate-aur-packages.sh" "$AUR_LIST" "$BUILD_DIR" "$REPO_NAME" "$REPO_DIR"

# Restore always backups, when exists.
restore_backups() {
  echo "♻️ Restaurant backups..."
  [ -f "${PACMAN_CONF}.bakup" ] && echo "Restaurat pacman.conf" && mv -f "${PACMAN_CONF}.bakup" "$PACMAN_CONF"
  [ -f "${PACKAGES_FILE}.bakup" ] && echo "Restaurat packages.x86_64" && mv -f "${PACKAGES_FILE}.bakup" "$PACKAGES_FILE"
}

trap restore_backups EXIT

# Add packages.x86_64.aur to packages.x86_64
echo "📜 Afegint paquets AUR a packages.x86_64"
cp "$SCRIPT_DIR/packages.x86_64" "$SCRIPT_DIR/packages.x86_64.backup"
echo -e "\n# Paquets AUR generats" >> "$SCRIPT_DIR/packages.x86_64"
cat "$AUR_LIST" >> "$SCRIPT_DIR/packages.x86_64"

# Afegir repositori local a pacman.conf
echo "🔧 Afegint repositori local a pacman.conf"
cp "$SCRIPT_DIR/pacman.conf" "$SCRIPT_DIR/pacman.conf.backup"
# Replace [path-to-your-repo] with the actual path
sed -i "s|file://\[path-to-your-repo\]|file://$REPO_DIR|g" "$SCRIPT_DIR/pacman.conf"


# Exist workdir and/or out? remove them.
echo "🗑️ Netejant directoris de treball i sortida"
sudo rm -rf "$WORK_DIR" "$OUT_DIR"

# Generar iso
echo "📀 Generant ISO amb mkarchiso"
sudo mkarchiso -v .

echo "✅ ISO generada amb èxit!"