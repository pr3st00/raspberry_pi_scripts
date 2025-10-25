#!/bin/bash

# ----------------------------------------------------------------------------------------
# Script Name: commit.sh
# Description: This script commits any changes to gitlab repository
# Author: Fernando Costa de Almeida
# Date: 2025-07-13
# Usage: ./commit.sh
# ----------------------------------------------------------------------------------------

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/subs/constants.sh
source ${DIR}/subs/functions.sh

SOURCE_DIR="/home/pi/scripts/"
DEST_DIR="/home/pi/projects/shell/raspberry_pi_scripts"
EXCLUDE_FILE="$SOURCE_DIR/exclude-list.txt"

COMMIT_MESSAGE="Updated scripts at $(date +'%m/%d/%Y %H:%m:%S')" 

function commit() {
	cd $DEST_DIR
	git add .
	git commit -m"$COMMIT_MESSAGE"
	git push
	echo
}

function synch() {
	/usr/bin/rsync -av --exclude-from $EXCLUDE_FILE $SOURCE_DIR $DEST_DIR
	echo
}

function check_for_changes() {
	cd $DEST_DIR
	git status
	echo
}

info "Synching scripts project \n"
synch

info "Checking for changes \n"
check_for_changes

info "Commit changes? [y|n]"
echo -n "R: "
read RESP

echo

if [[ $RESP == "y" ]]; then
	commit
fi

info "Completed"

# EOF
