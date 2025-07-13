#!/bin/bash

# ----------------------------------------------------------------------------------------
# Script Name: backup.sh
# Description: This script centralizes all backup actitivies of the system
# Author: Fernando Costa de Almeida
# Date: 2025-07-13
# Usage: ./backup.sh {mysql|nas|rclone|config|all}
# ----------------------------------------------------------------------------------------

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

function rclone_backup() {

	info "Starting rclone backup"

	EXCLUDE_FILE="${DIR}/config/exclude-list-rclone.txt"
	SOURCE_DIR="/home/pi"
	LAST_BACKUP_FILE="${SOURCE_DIR}/last_backup.txt"
	DEST_DIR="googledrive:Rclone/Backup/Services"
	RCLONE_BIN="/usr/bin/rclone"

	/bin/echo $(/bin/date) > $LAST_BACKUP_FILE && $RCLONE_BIN sync --exclude-from $EXCLUDE_FILE $SOURCE_DIR $DEST_DIR

	info "Completed"
	event "RCLONE Backup completed sucessfully" $BACKUP_CAT
}

function mysql_backup() {

	info "Cleaning old event records"
	executeQuery "delete from event where datetime <= DATE_SUB(SYSDATE(), INTERVAL 60 DAY)"

	info "Starting backup of mysql databases"
	/usr/bin/docker exec mysql sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > $BACKUP_DIR/mysql/all-databases.sql

	info "Completed"
	event "MYSQL Backup completed sucessfully" "$BACKUP_CAT"
}

function nas_backup() {

	SOURCE_DIR="/external"
	DEST_DIR="/backup"
	EXCLUDE_FILE="/home/pi/Backup/nas_exclude.txt"

	info "Backing up NAS"

	/bin/echo $(/bin/date) > $SOURCE_DIR/last_backup.txt

	/usr/bin/rsync -av --exclude-from $EXCLUDE_FILE $SOURCE_DIR $DEST_DIR

	info "Completed"
	event "NAS Backup completed sucessfully" "$BACKUP_CAT"
}

function config_backup() {

	FILE_LIST_NAME="${DIR}/config/files-to-backup.txt"
	
	info "Backing up config files to $BACKUP_DIR"

	for f in $(cat $FILE_LIST_NAME)
	do
		report_file $(basename $f) && sudo cp -Rp $f $BACKUP_DIR
	done

	info "Fixing permissions"

	for f in $BACKUP_DIR/msmtprc $BACKUP_DIR/daemon.json
	do
		report_file $(basename $f) && sudo chmod o+r $f
	done

	info "Miscelaneous"

	report_file "pi crontab" && /usr/bin/crontab -l         > $BACKUP_DIR/crontab
	report_file "dpkg list"  && /usr/bin/dpkg -l            > $BACKUP_DIR/dpkg.list

	if [[ -f /usr/local/node/bin/node ]]; then
		report_file "node version" && /usr/local/node/bin/node -v > $BACKUP_DIR/node.version
	else
		report_file "No node found"
	fi

	report_file ".bashrc"   && cp /home/pi/.bashrc  $BACKUP_DIR/dotconfig/bashrc
	report_file ".profile"  && cp /home/pi/.profile $BACKUP_DIR/dotconfig/profile

	info "Completed"
	event "CONFIG Backup completed sucessfully" "$BACKUP_CAT"
}

function report_file() {
	printf " %-25s\t%-20s\n" "$@" "[OK]"
}

# Main
case $1 in
	all)
		logStart
		myqsl_backup
		nas_backup
		rclone_backup
		config_backup
		;;
	mysql)
		logStart
		mysql_backup
		notifyBackup "MYSQL" $LOG_DIR/backup/mysql_backup.log
		;;
	rclone)
		logStart
		rclone_backup
		notifyBackup "RCLONE" $LOG_DIR/backup/rclone_backup.log
		;;
	nas)
		logStart
		nas_backup
		notifyBackup "NAS" $LOG_DIR/backup/nas_backup.log
		;;
	config)
		logStart
		config_backup
		notifyBackup "CONFIG" $LOG_DIR/backup/config_backup.log
		;;
	*)
		echo "Usage: backup.sh {mysql|nas|rclone|config|all}"
		exit 1
		;;
esac

# EOF
