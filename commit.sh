#!/bin/bash

SOURCE_DIR="/home/pi/scripts/"
DEST_DIR="/home/pi/projects/shell/raspberry_pi_scripts"
EXCLUDE_FILE="$SOURCE_DIR/exclude-list.txt"

/usr/bin/rsync -av --exclude-from $EXCLUDE_FILE $SOURCE_DIR $DEST_DIR

# EOF
