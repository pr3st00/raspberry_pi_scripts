#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

FILESERVER_DIR="${CONTAINERS_DIR}/nginx/html/php/elFinder/files"
FILESERVER_BACKUP_DIR="/external/hd1/Backup/fileServer"
TEMP_DIR="/tmp/index"

LAST_LISTING=$TEMP_DIR/last_listing.txt
CURRENT_LISTING=$TEMP_DIR/current_listing.txt

APINDEX_PROGRAM="${PROJECTS_DIR}/c/apindex/apindex"

function index() {

	info "Checking for changes and updating fileserver indexes"
	
	mkdir -p $TEMP_DIR
	
	if [[ ! -f $LAST_LISTING ]]; then
		info "Last index not found, generating.."
		find $FILESERVER_DIR > $LAST_LISTING
		updateIndex
		exit
	fi
	
	info "Generating current file index"
	find $FILESERVER_DIR > $CURRENT_LISTING
	
	if ! diff $LAST_LISTING $CURRENT_LISTING; then
		info "File contents changed"
		updateIndex
	fi
	
	find $FILESERVER_DIR > $LAST_LISTING

	info "Completed"
}

function updateIndex() {

	info "Generating index files"
	/bin/echo $(/bin/date) > $FILESERVER_DIR/last_update.txt
	
	(cd $FILESERVER_DIR && mv .trash /tmp && $APINDEX_PROGRAM . && mv /tmp/.trash .)
	
	event "FILESERVER index updated" "$SYSTEM_CAT"
}

function backup() {

	info "Backing up fileServer"

	/usr/bin/rsync -av $FILESERVER_DIR $FILESERVER_BACKUP_DIR

	info "Completed"

	event "FILESERVER backup completed sucessully" "$BACKUP_CAT"
	notifyBackup "FILESERVER" $LOG_DIR/backup/fileserver_backup.log
}

# Main
case $1 in
	index)
		logStart
		index
		;;
	backup)
		logStart
		backup
		;;
	*)
		echo "Usage: fileerver.sh {index|backup}"
		exit 1
		;;
esac

# EOF
