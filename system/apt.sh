#!/bin/bash

# ----------------------------------------------------------------------------------------------------------------------------
# Script Name: apt.sh
# Description: This script centralizes all actions for apt
# Author: Fernando Costa de Almeida
# Date: 2026-08-21
# Usage: ./apt.sh {check}
# -----------------------------------------------------------------------------------------------------------------------------

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

UPDATE_MESSAGE="Atualizar services"

check_updates() {
	info "Checking for updates"

	# Refresh package lists
	/usr/bin/sudo apt-get update -qq

	# Count available upgrades
	UPDATES=$(/usr/bin/apt list --upgradable 2>/dev/null | tail -n +2 | wc -l)

	if [[ "$UPDATES" -gt 0 ]]; then
		info "$UPDATES update(s) available."
		ga say "$UPDATE_MESSAGE"
	else
		info "System is up to date."
	fi

	info "Completed"
}

# Main
case $1 in
	all)
		logStart
		;;
	check)
		logStart
		check_updates
		;;
	*)
		echo "Usage: apt.sh {check}"
		exit 1
		;;
esac

# EOF
