#!/bin/bash

# Configuració
PROFILE_NAME="qsm42a7b.default-release"
PROFILE_PATH="/home/tomeu/.mozilla/firefox/$PROFILE_NAME"
BACKUP_DIR="/home/tomeu/_Backups/tomeu/firefox_backups/"
DATE=$(date +%F_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/firefox_backup_${DATE}.tar.gz"

# Crear carpeta de backup si no existeix
mkdir -p "$BACKUP_DIR"

# Comprovar si el perfil existeix
if [ ! -d "$PROFILE_PATH" ]; then
    echo "Error: No s'ha trobat el perfil: $PROFILE_PATH"
    exit 1
fi

# Crear backup
notify-send "Iniciant Backup"
tar -czf "$BACKUP_FILE" -C "$(dirname "$PROFILE_PATH")" "$PROFILE_NAME"

# Esborrar backups més antics de 7 dies
find "$BACKUP_DIR" -name "firefox_backup_*.tar.gz" -type f -mtime +7 -exec rm -f {} \;

# Missatge de confirmació
echo "Backup creat: $BACKUP_FILE"
notify-send "Backup creat: $BACKUP_FILE"
