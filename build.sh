#!/bin/bash
set -euo pipefail

# === FUNCIONS ===

cleanup() {
  echo "🔁 Restaurant fitxers de backup..."
  [[ -f "$SCRIPT_DIR/packages.x86_64.backup" ]] && mv "$SCRIPT_DIR/packages.x86_64.backup" "$SCRIPT_DIR/packages.x86_64"
  [[ -f "$SCRIPT_DIR/pacman.conf.backup" ]] && mv "$SCRIPT_DIR/pacman.conf.backup" "$SCRIPT_DIR/pacman.conf"
}
trap cleanup EXIT

# === CONFIGURACIÓ ===
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

AUR_LIST="${1:-$SCRIPT_DIR/packages.x86_64.aur}"
BUILD_DIR="${2:-/tmp/aur-build}"
REPO_NAME="${3:-customrepo}"
REPO_DIR="${4:-$SCRIPT_DIR/packages}"
WORK_DIR="${5:-$SCRIPT_DIR/workdir}"
OUT_DIR="${6:-$SCRIPT_DIR/out}"

PACMAN_CONF="$SCRIPT_DIR/pacman.conf"
PACKAGES_FILE="$SCRIPT_DIR/packages.x86_64"

# === VALIDACIONS ===
[[ -f "$AUR_LIST" ]] || { echo "❌ Fitxer de paquets AUR no trobat: $AUR_LIST"; exit 1; }
[[ -f "$PACMAN_CONF" ]] || { echo "❌ Fitxer pacman.conf no trobat a: $PACMAN_CONF"; exit 1; }
[[ -f "$PACKAGES_FILE" ]] || { echo "❌ Fitxer packages.x86_64 no trobat a: $PACKAGES_FILE"; exit 1; }

# === NETEJA ===
echo "🧹 Netejant $REPO_DIR, $WORK_DIR i $OUT_DIR..."
sudo rm -rf "$REPO_DIR" "$WORK_DIR" "$OUT_DIR"
mkdir -p "$REPO_DIR" "$WORK_DIR"

# === BACKUPS ===
cp "$PACKAGES_FILE" "$PACKAGES_FILE.backup"
cp "$PACMAN_CONF" "$PACMAN_CONF.backup"

# === COMPILACIÓ DE PAQUETS AUR ===
echo "📦 Compilant paquets AUR i creant repo..."
mkdir -p "$BUILD_DIR"
while read -r pkg; do
  [[ -z "$pkg" || "$pkg" == \#* ]] && continue
  echo "➡️  Compilant $pkg..."
  cd "$BUILD_DIR"
  rm -rf "$pkg"
  git clone "https://aur.archlinux.org/${pkg}.git"
  cd "$pkg"
  makepkg -s --noconfirm
  cp *.pkg.tar.zst "$REPO_DIR/"
done < "$AUR_LIST"

cd "$REPO_DIR"
echo "📚 Generant base de dades del repo..."
rm -f "${REPO_NAME}".db* "${REPO_NAME}".files*
repo-add "${REPO_NAME}.db.tar.gz" *.pkg.tar.zst

# Tornar al directori de treball
cd "$SCRIPT_DIR"

# === MODIFICACIÓ DE CONFIG ===
echo -e "\n# Paquets AUR" >> "$PACKAGES_FILE"
cat "$AUR_LIST" >> "$PACKAGES_FILE"
sed -i "s|file://\[path-to-your-repo\]|file://$REPO_DIR|g" "$PACMAN_CONF"

# === GENERACIÓ DE LA ISO ===
echo "📀 Generant ISO..."
sudo mkarchiso -v .

echo "✅ Tot completat correctament!"
