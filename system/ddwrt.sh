#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

ROUTER_BACKUP_DIR="${BACKUP_DIR}/devices/router/ddwrt"
ROUTER_LOG_DIR="${LOG_DIR}/backup"

ROUTER_HOST="router"
ROUTER_USER="root"
ROUTER_PASS="05trunks"

function backup() {

	info "Starting router backup"

	if [[ ! -d ${ROUTER_BACKUP_DIR}/old ]]; then
		warn "Directory ${ROUTER_BACKUP_DIR}/old doesnt exist, creating..."
		mkdir -p ${ROUTER_BACKUP_DIR}/old
	fi

	info "Moving old backups"
	mv ${ROUTER_BACKUP_DIR}/* ${ROUTER_BACKUP_DIR}/old 2>/dev/null
	
	info "NVRAM txt backup"
	/usr/bin/expect ${DIR}/config/ddwrt.expect > ${ROUTER_BACKUP_DIR}/nvram.bkp

	info "HTTP backups"

	for FILE in nvrambak.bin traffdata.bak
	do
		echo $FILE
		/usr/bin/wget -q --user ${ROUTER_USER} --password ${ROUTER_PASS} -P ${ROUTER_BACKUP_DIR} http://${ROUTER_HOST}/${FILE}
	done

	info "Completed"
	event "ROUTER Backup completed sucessfully" $BACKUP_CAT
}

function generatedns() {
	info "Generating dns configuration"
	info "Completed"
}

# Main
case $1 in
	backup)
		logStart
		backup
		notifyBackup "DDWRT" $ROUTER_LOG_DIR/router_backup.log
		;;
	generatedns)
		logStart
		generatedns
		;;
	*)
		echo "Usage: router.sh {backup|generatedns}"
		exit 1
		;;
esac

# EOF
