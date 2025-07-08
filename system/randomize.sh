#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

function heimdall_background() {

	BACKGROUND_DIR="${CONTAINERS_DIR}/nginx/html/images/backgrounds/heimdall"
	HEIMDALL_IMAGE_DIR="${CONTAINERS_DIR}/nginx/html/heimdall/img"
	
	info "Choosing a random heimdall background"

	file=$(ls $BACKGROUND_DIR | sort -R | tail -1)
	
	info "File is $file"
	/usr/bin/cp ${BACKGROUND_DIR}/${file} ${HEIMDALL_IMAGE_DIR}/bg1.jpg

	info "Completed"
}

# Main
case $1 in
	all)
		logStart
		heimdall_background
		;;
	heimdall_background)
		logStart
		heimdall_background
		;;
	*)
		echo "Usage: randomize.sh {heimdall_background|all}"
		exit 1
		;;
esac

# EOF
