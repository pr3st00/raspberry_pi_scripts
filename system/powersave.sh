#!/bin/bash

# ----------------------------------------------------------------------------------------
# Script Name: powersave.sh
# Description: This script controls power saving options
# Author: Fernando Costa de Almeida
# Date: 2026-10-21
# Usage: ./powersave.sh {on|off|status}
# ----------------------------------------------------------------------------------------

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source "${DIR}"/../subs/constants.sh
source "${DIR}"/../subs/functions.sh

on() {
	info "Turn power saving ON"
	sudo iw dev wlan0 set power_save on
}

off() {
	info "Turn power saving OFF"
	sudo iw dev wlan0 set power_save off
}

status() {
	info "Current power save STATUS:"
	iw dev wlan0 get power_save
}

# Main
case $1 in
	on)
		logStart
		on
		status
		;;
	off)
		logStart
		off
		status
		;;
	status)
		logStart
		status
		;;
	*)
		echo "Usage: powersave.sh {on|off|status}"
		exit 1
		;;
esac

# EOF
