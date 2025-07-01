#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

#
# Script Parameters
#
HOST1="acsb.sh"
HOST2="01.vistaplay.me"
HOST3="prestotv.sytes.net"
HOST=$HOST3

URL="http://$HOST3/get.php?username=$sec_IPTV_USER&password=$sec_IPTV_PASSWORD&type=m3u_plus&output=ts"
USER_AGENT="Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:40.0) Gecko/20100101 Firefox/40.0"
MAX_ENTRIES=20000
CLEANUP=0

SCRIPT_DIR="/home/pi/scripts/iptv"
HIDE_LIST="${SCRIPT_DIR}/config/nexttv/hide_list.txt"
ALLOW_LIST="${SCRIPT_DIR}/config/nexttv/allow_list.txt"
PROCESS_SCRIPT="${SCRIPT_DIR}/process.pl"

TEMP_DIR="/tmp"
TEMP_FILE="$TEMP_DIR/templist.m3u"

DEST_DIR="/home/pi/projects/docker/nginx/html/iptv"
DEST_FILE="${DEST_DIR}/lista.m3u"

logStart

info "Downloading newest m3u file"
/usr/bin/wget --user-agent="$USER_AGENT" -q $URL -O $TEMP_FILE

info "Transforming file based of config" 
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

event "IPTV list updated" "$SYSTEM_CAT"

# EOF
