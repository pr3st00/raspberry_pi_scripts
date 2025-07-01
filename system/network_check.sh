#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

HOSTNAME=192.168.1.1
MAX_FAILURES=1
FAILURES_FILE=/tmp/network_check_failures.txt

if [[ ! -r $FAILURES_FILE ]]; then
	warn "$(date) Failures file ($FAILURES_FILE) does not exist. Initializing it."
	echo "0" > $FAILURES_FILE
fi

cur_failures=$(cat $FAILURES_FILE)
info "$(date) Current failures is [$cur_failures]"

/bin/ping -I wlan0 -c 2 $HOSTNAME >/dev/null 2>&1

if [ $? -eq 0 ]; then
	info "$(date) Network status [ALIVE]"
	echo "0" > $FAILURES_FILE
else
	warn "$(date) Network status [DOWN]"
	let "cur_failures+=1"

	echo "$cur_failures" > $FAILURES_FILE

	if [[ $cur_failures -gt $MAX_FAILURES ]]; then
		warn "$(date) Failures exceeded max failures [$MAX_FAILURES], rebooting"
		rm $FAILURES_FILE
		/sbin/reboot
	fi
fi

# EOF
