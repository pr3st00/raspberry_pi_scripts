#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

DATE=$(/usr/bin/date +"%Y-%m-%d_%H-%M-%S")

BACKUP_DIR="${BACKUP_DIR}/devices/pihole"
BACKUP_FILE="pi-hole_pihole_teleporter_${DATE}_-03.zip"
LOG_DIR="${LOG_DIR}/backup"
LOG_FILE="pihole.log"
MAX_HISTORY_DAYS=5

HOST="services.home:82"
PASS="05trunks"

function update() {

	info "Updating lists"
	/usr/bin/docker exec pihole sh -c 'pihole -g'
	info "Completed"
}

function backup() {

	info "Starting pihole backup"

	if [[ ! -d ${BACKUP_DIR}/old ]]; then
		warn "Directory ${BACKUP_DIR}/old doesnt exist, creating..."
		mkdir -p ${BACKUP_DIR}/old
	fi

	info "Moving old backups"
	mv ${BACKUP_DIR}/* ${BACKUP_DIR}/old 2>/dev/null

	info "Authentication"
	SID=$(curl -qX POST "http://$HOST/api/auth" -H 'accept: application/json' -H 'content-type: application/json' \
               -d "{\"password\":\"$PASS\"}" 2>/dev/null | cut -d':' -f 5 | cut -d',' -f 1 | sed -e 's/"//g')

	info "Pi hole config backup"
	curl -qX GET "http://$HOST/api/teleporter" -H 'accept: application/zip' -H "sid: $SID" --output $BACKUP_DIR/$BACKUP_FILE 2>/dev/null

	info "File name is [$BACKUP_FILE]"

	info "Cleaning backup files older than $MAX_HISTORY_DAYS days"
	find ${BACKUP_DIR}/old -name 'pi-hole_pihole_teleporter*-03.zip' -mtime +${MAX_HISTORY_DAYS} -delete

	info "Completed"
	event "PIHOLE Backup completed sucessfully" $BACKUP_CAT
}

# Main
case $1 in
	backup)
		logStart
		backup
		notifyBackup "PIHOLE" $LOG_DIR/$LOG_FILE
		;;
	update)
		logStart
		update
		;;
	*)
		echo "Usage: pihole.sh {backup|restore|update}"
		exit 1
		;;
esac

# EOF
