#!/bin/bash

# ----------------------------------------------------------------------------------------
# Script Name: scriptlist.sh
# Description: This script lists all available scripts
# Author: Fernando Costa de Almeida
# Date: 2026-07-27
# Usage: ./scriptlist.sh
# ----------------------------------------------------------------------------------------

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source "${DIR}/subs/constants.sh"
source "${DIR}/subs/functions.sh"

##DESC Lists all available scripts

# Bold variants
CYAN=$'\033[0;36m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
RESET=$'\033[0m'

SCRIPT_NAME=$(basename $0)
SCRIPTS_DIR="/home/pi/scripts"

pushd $SCRIPTS_DIR >/dev/null 2>&1

declare -A SCRIPTS

printf "%-10s %-30s %-100s\n" "CATEGORY" "SCRIPT_NAME" "DESC"

for script in $(find . -name "*sh" 2>/dev/null | grep -v './docker/' | sort)
do
        dir=$(echo $script | cut -d'/' -f3)
        scriptname=$(basename $script)
        category=$(echo $script | cut -d'/' -f2)
        desc=$(grep "##DESC" $script | grep -v grep | sed -e 's/##DESC//g')

        if [[ -z $dir ]]; then
                category="BASE"
        fi

        if [[ -z $desc ]]; then
                desc="NO DESC"
        fi

        SCRIPTS["$scriptname"]="$desc,$category"
done

popd >/dev/null 2>&1

for scriptname in "${!SCRIPTS[@]}"; do
        value="${SCRIPTS[$scriptname]}"
        desc=$(echo $value | cut -d',' -f1)
        category=$(echo $value | cut -d',' -f2)

        col1="${CYAN}$(printf '%-10s' "${category::10}")${RESET}"
        col2="${GREEN}$(printf '%-30s' "${scriptname::30}")${RESET}"
        col3="${YELLOW}$(printf '%-100s' "${desc::100}")${RESET}"

        printf "%s %s %s\n" "$col1" "$col2" "$col3"
done

# EOF
