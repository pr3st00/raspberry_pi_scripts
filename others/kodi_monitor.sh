#!/bin/bash

DEBUG=0

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

WAIT_BOOT=25
FILE=/tmp/kodioff
LOGFILE=/var/log/kodi_monitor.log
URL=https://maker.ifttt.com/trigger/turn_off_bedroom_tv/with/key/bL6d4dkncSX9PNuQc67JpM
DELAY=10

info "Starting kodi monitor"

# Then monitor for lost connection
info "Starting monitor process."

while true ; do
	if [[ -f $FILE ]]; then
		rm $FILE
		info "Turning off kodi in $DELAY sec(s)..."
		sleep $DELAY
		curl $URL >>$LOGFILE 2>&1
		info "Turned off!!"
	fi
done

# EOF
