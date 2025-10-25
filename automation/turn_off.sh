#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

HOSTNAME=$1
DEVICE_NAME=$2
USAGE="$(basename $SCRIPT) <hostname> <device name on google home>"

if [[ -z $HOSTNAME || -z $DEVICE_NAME ]]; then
	echo $USAGE;
	exit 1;
fi

logStart
info "Starting device disabling automation for device [$DEVICE_NAME]"

/usr/bin/ping -c 5 $HOSTNAME > /dev/null 2>&1

if [[ $? -eq 0 ]]; then
	info "$HOSTNAME is ALIVE";
	info "Turning off device $DEVICE_NAME"
	ga execute "Desligar $DEVICE_NAME"
else
	warn "$HOSTNAME is DOWN, no action required";
fi

info "Completed"

# EOF
