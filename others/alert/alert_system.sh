#!/bin/bash

#-----------------------------------------------------------------------------------------------
: <<-'EOF'
Copyright 2018 Fernando Costa de Almeida <fernando.c.almeida@gmail.com>
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
EOF
#-----------------------------------------------------------------------------------------------

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

SLEEP_TIME=120
EMAIL=fernando.c.almeida@gmail.com

LOG_DIR=/tmp/alert
IMAGES_DIR=/var/lib/motion

SOUND_DIR=/home/pi/projects/scripts/alert/sounds
LAST_ALERT_FILE=$LOG_DIR/last_alert.txt
LOCK_FILE=$LOG_DIR/alert_system.lock
LOG_FILE=$LOG_DIR/alert_system.log
IMAGE_FILE=$(ls -tr $IMAGES_DIR/*jpg 2>/dev/null| tail -1)
SOUND_FILE=$(find $SOUND_DIR -type f | shuf -n 1)

function log() {
	echo "[$(date '+%m/%d/%y %H:%M:%S')] $1" | tee -a $LOG_FILE
}

trap cleanup 0 1 2 3 6

function cleanup() {
	rm $LOCK_FILE 2>/dev/null
	log "[END] Finished alert"
	log "-----------------------------------------------------------------"
	trap 0 1 2 3 6
	exit 0
}

if [ ! -d $LOG_DIR ]; then
	log "[WARNING] Log directory ($LOG_DIR) doesn't exist, creating one." 
	mkdir -p $LOG_DIR
fi

log "-----------------------------------------------------------------"
log "[INI] Starting alarm system"

if [ -f $LOCK_FILE ]; then
	log "[ERROR] Alert is already being fired, exiting..."
	exit 1
fi

echo $$ >> $LOCK_FILE

CURRENT_TIME=$(date +%s)

if [ ! -f $LAST_ALERT_FILE ]; then
	LAST_ALERT=0
else
	LAST_ALERT=$(cat $LAST_ALERT_FILE)
fi

TIME_ELAPSED=$(( $CURRENT_TIME - $LAST_ALERT))

if [ $TIME_ELAPSED -gt $SLEEP_TIME ]; then
	echo $CURRENT_TIME > $LAST_ALERT_FILE
	log "[INFO] Sending email alert"
	mpack -s "[ALERT] Motion detected" $IMAGE_FILE $EMAIL &
	log "[INFO] Now playing sound ($SOUND_FILE)"
	aplay $SOUND_FILE >/dev/null 2>/dev/null
else
	log "[WARNING] Last alert was sent only $TIME_ELAPSED(s) ago. (SLEEP_TIME is $SLEEP_TIME)."
fi

# EOF
