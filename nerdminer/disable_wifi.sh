#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

HOSTNAME=http://nerdminer.home

info "$(date) Disabling nerdminer wifi"

wget -qO- ${HOSTNAME}/exit >/dev/null 2>&1

if [ $? -eq 0 ]; then
	info "$(date) Nerdminer wifi disabled sucessfully."
else
	warn "$(date) Nerdminer did not respond."
fi

# EOF
