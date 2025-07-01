#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../../subs/constants.sh
source ${DIR}/../../subs/functions.sh

source /home/pi/scripts/others/discord/mesgs.sh

URL=$sec_DISCORD_WEBHOOK_URL1
DATE=$(/usr/bin/date)

INDEX_DIR=/tmp
INDEX_FILE=${INDEX_DIR}/rafael_index.txt
RANDOMIZE=0


function getRandomMessage() {
	size=${#mesg[@]}
	index=$(($RANDOM % $size))
	echo ${mesg[$index]}
}

function getSequentialMessage() {

	if [[ ! -f $INDEX_FILE ]]; then
		echo "0" > $INDEX_FILE
	fi

	index=$(cat $INDEX_FILE)

	size=${#mesg[@]}
	let new_index=index+1

	if [[ $new_index -lt $size ]]; then
		echo "$new_index" > $INDEX_FILE
	fi

	echo ${mesg[$index]}
}

if [[ $RANDOMIZE -eq 1 ]]; then
	echo "[$DATE] - Selecting random message"
	MESSAGE=$(getRandomMessage)
else
	echo "[$DATE] - Selecting sequential message"
	MESSAGE=$(getSequentialMessage)
fi

echo "[$DATE] - Sending message ($MESSAGE)"
curl -d "{\"content\":\"$MESSAGE\"}" -H "Content-Type: application/json" -X POST $URL

echo "[$DATE] - Next index is $(cat $INDEX_FILE)"

# EOF
