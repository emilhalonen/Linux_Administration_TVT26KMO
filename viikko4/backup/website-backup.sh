#!/usr/bin/env bash
set -uo pipefail

SOURCE_HOST="ubuntu@192.168.1.228"
SSH_KEY="/root/.ssh/backup_ed25519"
BACKUP_DIR="/var/backups/website-from-a"
LOG_FILE="/var/log/website-backup.log"
KEEP=48

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
}

umask 077
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

timestamp=$(date '+%Y-%m-%d_%H%M%S')
archive="$BACKUP_DIR/html_$timestamp.tar.gz"

if ssh -i "$SSH_KEY" -o BatchMode=yes "$SOURCE_HOST" \
        "tar -czf - -C /var/www html" > "$archive.part" \
    && tar -tzf "$archive.part" > /dev/null; then
    mv "$archive.part" "$archive"
    log "OK $archive ($(du -h "$archive" | cut -f1))"
else
    rm -f "$archive.part"
    log "FAILED $timestamp"
    exit 1
fi

ls -1t "$BACKUP_DIR"/html_*.tar.gz | tail -n +$((KEEP + 1)) | xargs -r rm -f
