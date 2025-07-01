#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

LOG_FILE="$LOG_DIR/nas.log"
DISKS="hd1 hd2"
SUDO="/usr/bin/sudo"

function mountall() {

	info "Starting Samba"
	$SUDO systemctl start smbd

	for HD in $DISKS
	do
		info "Mounting $HD ..."
		$SUDO mount /external/$HD
		info "Files available: $(ls /external/$HD | wc -l)"
	done

	info "Completed"
	event "NAS mounted" "$NAS_CAT"
}

function umountall() {

	info "Stopping Samba"
	$SUDO systemctl stop smbd

	for HD in $DISKS
	do
		info "Umounting $HD"
		$SUDO umount /external/$HD
	done

	info "Completed"
	event "NAS umounted" "$NAS_CAT"
}

case $1 in
	mount)
		logStart
		mountall
		;;
	umount)
		logStart
		umountall
		;;
	*)
		echo "Usage: nas.sh {mount|umount}"
		exit 1
		;;
esac

# EOF
