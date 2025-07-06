#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

ROUTER_BACKUP_DIR="${BACKUP_DIR}/devices/router/ax53"
ROUTER_LOG_DIR="${LOG_DIR}/backup"

ROUTER_HOST="tplinkwifi.net/cgi-bin/luci/;stok=07bfe11dd354f513ee4dd5e2381e1fcd/admin/firmware?form=config_multipart"
ROUTER_PASS=$sec_ROUTER_PASS

FILE="backup-Archer_AX53-2023-09-10.bin"

function backup() {

	info "Starting router backup"

	if [[ ! -d ${ROUTER_BACKUP_DIR}/old ]]; then
		warn "Directory ${ROUTER_BACKUP_DIR}/old doesnt exist, creating..."
		mkdir -p ${ROUTER_BACKUP_DIR}/old
	fi

	info "Moving old backups"
	mv ${ROUTER_BACKUP_DIR}/* ${ROUTER_BACKUP_DIR}/old 2>/dev/null
	
	info "HTTP backups"

	/usr/bin/wget -q  --password ${ROUTER_PASS} -P ${ROUTER_BACKUP_DIR} http://${ROUTER_HOST} -O ${FILE}

	info "Completed"
	event "ROUTER Backup completed sucessfully" $BACKUP_CAT
}

# Main
case $1 in
	backup)
		logStart
		backup
		notifyBackup "AX53" $ROUTER_LOG_DIR/router_backup.log
		;;
	*)
		echo "Usage: router.sh {backup}"
		exit 1
		;;
esac

# EOF
