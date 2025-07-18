#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

LOG_FILE="$LOG_DIR/nas.log"
DISKS="hd1 hd2"
CONTAINERS="emulatorjs"
SUDO="/usr/bin/sudo"
WAIT_TIME=5

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

function containers() {

	ACTION=$1

	info "Peforming action [$ACTION] on containers using disks"

	for CONTAINER in $CONTAINERS
	do
		/usr/bin/docker $ACTION $CONTAINER > /dev/null 2>&1

		if [[ $? == 0 ]]; then
			STATUS="OK";
		else
			STATUS="FAILED";
		fi
			
		printf " %-25s\t%-20s\n" "$CONTAINER" "[${STATUS}]"
	done

	info "Completed"
}

function waitForDisks() {

	info "Waiting for disks ..."
	sleep $WAIT_TIME
	info "Completed"
}

function status() {

	info "Checking NAS status"

	info "1. SMBD"
	debug "Running systemctl"
	systemctl status smbd

	info "2. DISKS"
	for HD in $DISKS
	do
		info "\t Disk [$HD]"
		info "\t File(s) : [$(ls /external/$HD | wc -l)]"
	done

}

case $1 in
	mount)
		logStart
		mountall
		waitForDisks
		containers "start"
		;;
	umount)
		logStart
		containers "stop"
		waitForDisks
		umountall
		;;
	status)
		status
		;;
	*)
		echo "Usage: nas.sh {mount|umount|status}"
		exit 1
		;;
esac

# EOF
