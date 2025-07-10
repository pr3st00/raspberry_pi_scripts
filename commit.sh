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

info "Checking for changes"
git status

info "Commit changes? [y|n]"
echo -n "RESP: "
read RESP

if [[ $RESP -eq "y" ]]; then
	git add .
	git commit -m"$COMMIT_MESSAGE"
	git push
fi

info "Completed"

# EOF
