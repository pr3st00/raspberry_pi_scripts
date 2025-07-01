#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

RECALBOX_BACKUP_DIR="$BACKUP_DIR/devices/recalbox"
EXCLUDE_FILE="${DIR}/config/exclude-list-recalbox.txt"

RECALBOX_HOST_NAME="recalbox.home"
RECALBOX_SHARE_DIR="/recalbox/share"

function backup() {

	info "Starting recalbox backup"

	for DIR in saves bios music screenshots system
	do
		/usr/bin/rsync -av --exclude-from="$EXCLUDE_FILE" root@${RECALBOX_HOST_NAME}:${RECALBOX_SHARE_DIR}/${DIR} $RECALBOX_BACKUP_DIR
	done

	info "Completed"
	
	event "RECALBOX Backup completed sucessfully" $BACKUP_CAT
}

function restore() {
	
	info "Restoring recalbox backup"
	echo

	for DIR in saves bios music screenshots
	do
		info "Restoring share item $DIR ..."
		/usr/bin/scp -r ${RECALBOX_BACKUP_DIR}/${DIR}/* root@${RECALBOX_HOST_NAME}:${RECALBOX_SHARE_DIR}/${DIR}
		echo
	done

	for DIR in scripts backup custom.sh
	do
		info "Restoring system item $DIR ..."
		/usr/bin/scp -r ${RECALBOX_BACKUP_DIR}/system/${DIR} root@${RECALBOX_HOST_NAME}:${RECALBOX_SHARE_DIR}/system
		echo
	done

	info "Completed"
	event "RECALBOX Restore completed sucessfully" $BACKUP_CAT
}

# Main
case $1 in
	backup)
		logStart
		backup
		notifyBackup "RECALBOX" $LOG_DIR/backup/recalbox_backup.log
		;;
	restore)
		logStart 
		restore
		;;
	*)
		echo "Usage: recalbox.sh {backup|restore}"
		exit 1
		;;
esac

# EOF
