# ArchISO personalitzat amb i3 i AUR 🪶

Distribució Arch Linux personalizada, construïda amb `mkarchiso`, amb entorn **i3**, eines de desenvolupament i paquets **AUR precompilats** integrats en un repositori local.

---

## 🚀 Objectiu

Crear una ISO autoexecutant que inclogui:

- **Window manager i3** amb configuració personalitzada
- **Paquets de l’AUR** ja compilats i disponibles en un repo local
- Entorn preparat per treballar amb llenguatges i IDEs (Python, Go, Rust, VS Code...)
- Facilitat per arrancar en qualsevol màquina amb **autologin**

---

## 🛠️ Estructura del repositori

```
archiso-i3/
├── airootfs/                         # Arrel del sistema live
├── build.sh                          # Script per generar la ISO
├── generate-aur-packages.sh          # Compila AUR i crea el repo local
├── packages.x86_64                   # Paquets a instal·lar amb pacman
├── packages.x86_64.aur               # Llista de paquets AUR
├── pacman.conf                       # Configuració de pacman per la ISO
├── profiledef.sh                     # Perfil d’archiso (label, modes, etc.)
└── scripts/                          # Opcional: scripts helpers (si existeixen)
```

---

## ⚙️ Com funciona

1. `build.sh` és l’script principal:
   - Netega directoris (`workdir`, `out`, el repo)
   - Fes backup de `packages.x86_64` i `pacman.conf`
   - Executa `generate-aur-packages.sh`
   - Afegeix els paquets AUR a `packages.x86_64`
   - Actualitza `pacman.conf` per incloure el `repo local`
   - Genera la ISO amb `mkarchiso`
   - Restaura els fitxers originals de configuració

2. `generate-aur-packages.sh` clona cada paquet de la llista `.aur`, el compila amb `makepkg` i crea un `.zst`; després genera un repo local amb `repo-add`.

---

## 🧾 Prerequisits

- Executar com a `root` o amb `sudo`
- Arch Linux amb `archiso` i eines com `git`, `makepkg`, `repo-add`

Instal·la les dependències base si cal:

```bash
sudo pacman -Syu archiso base-devel git squashfs-tools
```

---

## ✅ Com construir la ISO

Des del directori del projecte:

```bash
chmod +x build.sh generate-aur-packages.sh
sudo ./build.sh
```

L’arxiu ISO es generarà a `out/arch-i3--x86_64.iso`.

---

## 🚀 Provar la ISO

 pots provar-la amb QEMU:

```bash
qemu-system-x86_64 -cdrom out/arch-i3--x86_64.iso -m 2G -enable-kvm
```

L'usuari live és `root`, o l’autologin s'activa si està configurat.

---

## 🔧 Personalització

- **Paquets**: edita `packages.x86_64` i `packages.x86_64.aur` per afegir o eliminar paquets.
- **Perfil d’ISO**: `profiledef.sh` permet modificar label, modes d’arrencada (UEFI/Bios), compresió, etc.
- **Hooks o scripts**: Si vols afegir funcionalitats (com `autologin`, `i3 config`, clonació ssh), copia fitxers o scripts a `airootfs/`.

---

## 💡 Consells finals

- Si els paquets AUR fallen a compilar, revisa logs i dependències.
- Assegura't que `BUILD_DIR` existeix (si falles amb error de `cd`, afegeix `mkdir -p` si cal).
- Pots regenerar la ISO tantes vegades com vulguis; si tot està bé, hi ha molt poc temps de construcció.

---

## 📜 Llicència

Distribuit amb llicència **LGPL** .

---

### 🙌 Gràcies per utilitzar aquest projecte! qualsevol dubte, pregunta o millora... welcome! 💬