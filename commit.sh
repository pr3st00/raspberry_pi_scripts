#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/subs/constants.sh
source ${DIR}/subs/functions.sh

SOURCE_DIR="/home/pi/scripts/"
DEST_DIR="/home/pi/projects/shell/raspberry_pi_scripts"
EXCLUDE_FILE="$SOURCE_DIR/exclude-list.txt"

COMMIT_MESSAGE="Updated scripts at $(date)" 

info "Synching scripts project \n"

/usr/bin/rsync -av --exclude-from $EXCLUDE_FILE $SOURCE_DIR $DEST_DIR
cd $DEST_DIR
echo

info "Checking for changes \n"
git status
echo

info "Commit changes? [y|n]"
echo -n "RESP: "
read RESP

echo

if [[ $RESP == "y" ]]; then
	git add .
	git commit -m"$COMMIT_MESSAGE"
	git push
	echo
fi

info "Completed"

# EOF
