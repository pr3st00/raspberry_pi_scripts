#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

function check_process() {

	PROCESS_NAME=$1

	echo -n "Checking process $PROCESS_NAME ..."

	if [[ $(ps -ef | grep $PROCESS_NAME | grep -v grep | wc -l) -gt 0 ]]; then
		echo "	OK"
	else
		echo "	NOK"
	fi
}

# Main
case $1 in
	all)
		logStart

		for process in /usr/sbin/smbd /usr/local/cu
		do
			check_process $process
		done
		;;
	*)
		echo "Usage: system_check.sh {all}"
		exit 1
		;;
esac

# EOF