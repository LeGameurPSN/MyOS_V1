#!/bin/bash
# build.sh — construit l'ISO de PSN_OS avec live-build
# À lancer avec sudo, sur une machine/VM Debian ou Ubuntu.
set -e

if ! command -v lb >/dev/null 2>&1; then
    echo "live-build n'est pas installé. Installe-le avec :"
    echo "  sudo apt update && sudo apt install -y live-build"
    exit 1
fi

echo "== Nettoyage build précédent =="
lb clean --purge || true

echo "== Configuration live-build =="
lb config \
    --distribution bookworm \
    --architecture amd64 \
    --archive-areas "main contrib non-free non-free-firmware" \
    --debian-installer none \
    --bootappend-live "boot=live components username=user hostname=psnos locales=fr_FR.UTF-8 keyboard-layouts=fr" \
    --iso-application "PSN_OS" \
    --iso-volume "PSN_OS" \
    --linux-packages linux-image

echo "== Build de l'ISO (ça peut prendre 20-40 min) =="
lb build

DATE_TAG=$(date +%Y%m%d)
ISO_OUT="psnos-${DATE_TAG}.iso"
mv live-image-amd64.hybrid.iso "$ISO_OUT" 2>/dev/null || true

echo "== Terminé =="
echo "ISO générée : $ISO_OUT"
