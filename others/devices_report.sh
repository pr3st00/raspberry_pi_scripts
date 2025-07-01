#!/bin/bash

DEVICES=/home/pi/scripts/devices.txt
URL=http://pr3st00iot.mybluemix.net/devicesreport

isAlive() {
	ip=$1;
	host=$(printf '%-15s' "$ip");
	alive="true"
	datestring=$(/bin/date -u +'%Y-%m-%dT%H:%M:%S.000Z')
	date=$(/bin/date -u +'%Y-%m-%d')
	month=$(/bin/date -u +'%B')
	dayofweek=$(/bin/date -u +'%A')
	dayofmonth=$(/bin/date -u +'%d')
	hour=$(/bin/date -u +'%H')

	/bin/ping -c 2 $ip >/dev/null 2>&1

	if [ $? -eq 0 ]; then
		echo "$host =     ALIVE";
	else
		alive="false"
		echo "$host =     DEAD";
	fi


	/usr/bin/curl --header "Content-Type: application/json" \
	--request POST \
	--data "{ \"device\" : \"$ip\", \"alive\" : \"$alive\", \"date\" : \"$date\", \"month\" : \"$month\", \"dayofmonth\" : \"$dayofmonth\", \"dayofweek\" : \"$dayofweek\",  \"hour\" : \"$hour\" }" $URL  > /dev/null 2>&1
}

echo "-------------- DEVICES REPORT ------------------"
echo "- DATE: $(date) "
echo

for DEVICE in $(cat $DEVICES); do
	isAlive "$DEVICE";
done

echo
echo "------------------------------------------------"
