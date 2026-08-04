#!/usr/bin/env bash
# ==============================================================================
# ADVANCED AUTOMATED BACKUP SCRIPT WITH GPG ENCRYPTION & ALERTS
# ==============================================================================
# Author: Hitesh Kumar
# Purpose: Backup databases, compress directories, encrypt, upload, & alert.
# ==============================================================================

set -o pipefail

# --- Configurations and Defaults ---
CONFIG_FILE="$(dirname "$0")/../config/backup.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "ERROR: Configuration file not found at $CONFIG_FILE"
    exit 1
fi

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="${LOCAL_BACKUP_PATH}/${DATE}"
LOG_FILE="/var/log/backup.log"

# Setup logging
exec 3>&1 4>&2
if [[ ! -w "$LOG_FILE" ]]; then
    LOG_FILE="/tmp/backup.log"
    echo "Warning: No write permission on /var/log/backup.log, logging to $LOG_FILE"
fi
exec 1>>"$LOG_FILE" 2>&1

log() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] ${message}" >&3
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] ${message}"
}

send_notification() {
    local status="$1"
    local msg="$2"
    if [[ -z "$DISCORD_WEBHOOK_URL" ]]; then return; fi

    local color=65280 # Green
    if [[ "$status" == "ERROR" ]]; then
        color=16711680 # Red
    fi

    local payload=$(cat <<EOF
{
  "embeds": [{
    "title": "Backup Notification - ${status}",
    "description": "${msg}",
    "color": ${color},
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  }]
}
EOF
)
    curl -H "Content-Type: application/json" -X POST -d "$payload" "$DISCORD_WEBHOOK_URL" &>/dev/null || true
}

# --- 1. System Health Checks ---
log "INFO" "Starting backup process..."
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [[ "$DISK_USAGE" -gt "$MAX_DISK_THRESHOLD" ]]; then
    log "ERROR" "Disk space critical: ${DISK_USAGE}% usage. Aborting backup."
    send_notification "ERROR" "Disk space critical: ${DISK_USAGE}% usage. Aborting backup on host $(hostname)."
    exit 1
fi

# Ensure output directory exists
mkdir -p "$BACKUP_DIR"

# --- 2. Database Dumps ---
if [[ "$BACKUP_MYSQL" == "true" ]]; then
    log "INFO" "Dumping MySQL Database: ${DB_NAME}..."
    MYSQL_DUMP_FILE="${BACKUP_DIR}/${DB_NAME}_mysql_${DATE}.sql"
    if mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$MYSQL_DUMP_FILE"; then
        log "INFO" "MySQL backup successful."
    else
        log "ERROR" "MySQL dump failed!"
        send_notification "ERROR" "MySQL dump failed for database ${DB_NAME} on host $(hostname)."
    fi
fi

# --- 3. Directory Compression & GPG Encryption ---
log "INFO" "Compressing directories..."
TAR_FILE="${BACKUP_DIR}/files_${DATE}.tar.gz"
if tar -czf "$TAR_FILE" -C "$SOURCE_DIR" . ; then
    log "INFO" "File compression successful."
else
    log "ERROR" "File compression failed!"
    send_notification "ERROR" "File compression failed for path ${SOURCE_DIR} on host $(hostname)."
fi

# GPG Encryption
if [[ "$ENABLE_GPG" == "true" ]]; then
    log "INFO" "Encrypting files using GPG..."
    for file in "$BACKUP_DIR"/*; do
        if [[ -f "$file" && "${file##*.}" != "gpg" ]]; then
            gpg --batch --yes --passphrase "$GPG_PASSPHRASE" -c "$file"
            rm "$file" # Remove plain text original
        fi
    done
    log "INFO" "Encryption completed."
fi

# --- 4. Remote Sync (rsync / SSH) ---
if [[ "$ENABLE_REMOTE_SYNC" == "true" ]]; then
    log "INFO" "Syncing backups to remote server: ${REMOTE_HOST}..."
    if rsync -az -e "ssh -i ${SSH_KEY_PATH} -p ${REMOTE_PORT}" "$BACKUP_DIR" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"; then
        log "INFO" "Remote synchronization completed successfully."
    else
        log "ERROR" "Remote synchronization failed!"
        send_notification "ERROR" "Remote backup synchronization failed to host ${REMOTE_HOST}."
    fi
fi

# --- 5. Retention Policy (Clean old backups) ---
log "INFO" "Running retention cleanup..."
# Clean local folders older than RETENTION_DAYS
find "$LOCAL_BACKUP_PATH" -mindepth 1 -maxdepth 1 -mtime +"$RETENTION_DAYS" -type d -exec rm -rf {} \;
log "INFO" "Cleanup complete."

log "INFO" "Backup process completed successfully."
send_notification "SUCCESS" "Backup completed successfully on host $(hostname). Files stored locally at ${BACKUP_DIR}."
exit 0
