#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

PING_COUNT=3

HOSTNAME=$1
DEVICE_NAME=$2
USAGE="$(basename $SCRIPT) <hostname> <device name on google home>"

if [[ -z $HOSTNAME || -z $DEVICE_NAME ]]; then
	echo $USAGE;
	exit 1;
fi

info "$(date) Starting device disabling automation for device [$DEVICE_NAME]"

if isAlive $HOSTNAME; then
	info "$(date) $HOSTNAME is ALIVE";
	info "$(date) Turning off device $DEVICE_NAME"
	ga execute "Desligar $DEVICE_NAME"
else
	warn "$(date) $HOSTNAME is DOWN, no action required";
fi

info "$(date) Completed"

# EOF
