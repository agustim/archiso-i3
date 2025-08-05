#!/bin/bash
set -e


# === CONFIGURACIÓ ===
AUR_LIST="$1"                            # Fitxer amb paquets AUR
WORK_DIR="${2:-/tmp/aur-build}"         # Directori temporal
REPO_NAME="${3:-customrepo}"            # Nom del repo
REPO_DIR="${4:-./packages}"                 # On generar el repositori final

# === VALIDACIONS ===
if [[ ! -f "$AUR_LIST" ]]; then
  echo "❌ Fitxer no trobat: $AUR_LIST"
  echo "Ús: $0 paquets.txt [/tmp/build-dir] [nom_repo] [output_dir]"
  exit 1
fi

mkdir -p "$WORK_DIR"
mkdir -p "$REPO_DIR"

echo "📦 Compilant paquets AUR..."
while read -r pkg; do
  [[ -z "$pkg" || "$pkg" == \#* ]] && continue  # Omet línies buides o comentades
  echo "➡️  $pkg"
  cd "$WORK_DIR"
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

echo -e "\n✅ Repositori generat a: $REPO_DIR"
echo "   ├── $REPO_NAME.db"
echo "   └── *.pkg.tar.zst"
