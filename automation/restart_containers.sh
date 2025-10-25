#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

CONTAINERS=$1
USAGE="$(basename $SCRIPT) <containers>"

if [[ -z $CONTAINERS ]]; then
	echo $USAGE;
	exit 1;
fi

logStart
info "Starting restarting of the following containers [$CONTAINERS]"

for container in $CONTAINERS
do
	info "Stopping $container"
	/usr/bin/docker stop $container
	sleep 5
	/usr/bin/docker start $container
	info "Starting $container"
done

info "Completed"

# EOF
