#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

function refresh() {

	info "Refreshing minidlna database"
	
	sudo minidlnad -R
	sudo systemctl restart minidlna

	info "Completed"
	event "Minidlna database refreshed" $SYSTEM_CAT
}

# Main
case $1 in
	refresh)
		logStart
		refresh
		;;
	*)
		echo "Usage: minidlna.sh {refresh}"
		exit 1
		;;
esac

# EOF