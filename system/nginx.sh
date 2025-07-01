#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

LOG_FILES="public.access.log private.access.log"

GO_ACCESS="/usr/bin/goaccess"
DOCKER="/usr/bin/docker"

function analyze_all() {

	info "Analyzing nginx logs"

	copy_files
	
	$GO_ACCESS $LOG_FILES
	
	clean

	info "Completed"
}

function generate_report() {

	DB_DIR="/home/pi/scripts/system/data"
	REPORT_DIR="/home/pi/html/report"
	REPORT_FILE="index.html"

        info "Generating report"

	copy_files

        $GO_ACCESS $LOG_FILES --log-format=COMBINED --restore --persist --db-path=$DB_DIR -o $REPORT_DIR/$REPORT_FILE

	clean

        info "Completed"
}

function copy_files() {
	for f in $LOG_FILES
	do
		$DOCKER cp nginx:/var/log/nginx/$f .
	done
}

function clean() {
	info "Cleaning"
	rm $LOG_FILES
}

# Main
case $1 in
	analyze)
		analyze_all
		;;
	report)
		generate_report
		;;
	*)
		echo "Usage: nginx.sh {analyze|report}"
		exit 1
		;;
esac

# EOF
