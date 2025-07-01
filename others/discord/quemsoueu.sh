#!/bin/bash

URL=$sec_DISCORD_WEBHOOK_URL2
DATE=$(/usr/bin/date)

source /home/pi/scripts/others/discord/mesgs2.sh

size=${#mesg[@]}
index=$(($RANDOM % $size))
MESSAGE=${mesg[$index]}

echo "[$DATE] - Sending ($MESSAGE)"

curl -d "{\"content\":\"$MESSAGE\"}" -H "Content-Type: application/json" -X POST $URL

# EOF
