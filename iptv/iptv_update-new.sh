#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

USER_AGENT="Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:40.0) Gecko/20100101 Firefox/40.0"
CLEANUP=0

SCRIPT_DIR="/home/pi/scripts/iptv"
PROCESS_SCRIPT="${SCRIPT_DIR}/process.pl"

TEMP_DIR="/tmp"
TEMP_FILE="$TEMP_DIR/templist.m3u"

DEST_DIR="/home/pi/projects/html/iptv"

logStart

PARAMETERS=$1

if [[ ! -f $PARAMETERS ]]; then
	warn "Parameters file $PARAMETERS not found"
	exit 255
fi

info "Loading parameters from $PARAMETERS"
set -a
source $PARAMETERS
set +a

info "List is $LIST_NAME"

debug "URL is: $URL"

info "Downloading newest m3u file"
/usr/bin/wget --user-agent="$USER_AGENT" -q $URL -O $TEMP_FILE

info "Transforming file based of config"
debug "Process command is: /usr/bin/cat $TEMP_FILE | /usr/bin/perl $PROCESS_SCRIPT $HIDE_LIST $ALLOW_LIST ${MAX_ENTRIES}"
debug "Destination file is $DEST_FILE"
/usr/bin/cat $TEMP_FILE | /usr/bin/perl $PROCESS_SCRIPT $HIDE_LIST $ALLOW_LIST ${MAX_ENTRIES} 2>/dev/null > ${DEST_FILE}.bkp

entries=$(cat ${DEST_FILE}.bkp | grep -v '#' | wc -l | awk '{ print $1 }')
info "Processed file [${DEST_FILE}.bkp] has [$entries] entries"

if [[ $entries -gt 0 ]]; then
	info "Creating destination file [$DEST_FILE]"
	mv ${DEST_FILE}.bkp $DEST_FILE
else
	warn "Destination file [${DEST_FILE}.bkp] has no entries, destination file [$DEST_FILE] will be preserved"
	/usr/bin/rm ${DEST_FILE}.bkp
fi

if [[ $CLEANUP == 1 ]]; then
	info "Cleaning up"
	/usr/bin/rm $TEMP_FILE
fi

info "Completed"

event "IPTV list ($LIST_NAME) updated" "$SYSTEM_CAT"

# EOF
