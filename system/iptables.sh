#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

IPTABLES_COMMAND="sudo /usr/sbin/iptables"
IPTABLES_LOG_PREFIX="[iptables]: "
LOGGING_ENABLED=1

DOCKER_NETWORK=$(/usr/bin/docker network inspect -f '{{range .IPAM.Config}}{{.Subnet}}{{end}}' services_network)

function clean() {
	info "Cleaning rules."
	$IPTABLES_COMMAND -P INPUT ACCEPT
	$IPTABLES_COMMAND -F INPUT
	$IPTABLES_COMMAND -F LOGGING
	$IPTABLES_COMMAND -X LOGGING

	$IPTABLES_COMMAND -D DOCKER-USER -i $EXT_IF ! -s $LOCAL_NETWORK -j DROP
}

function list() {
	info "Listing rules:"
	$IPTABLES_COMMAND -v -L INPUT
}

function setup() {

	info "Cleaning up all input rules"
	clean

	info "Add basic stuff"
	$IPTABLES_COMMAND -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
	$IPTABLES_COMMAND -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
	$IPTABLES_COMMAND -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
	$IPTABLES_COMMAND -A INPUT -i lo -j ACCEPT

	info "Allow SSH from local network only"
	$IPTABLES_COMMAND -A INPUT -p tcp -s $LOCAL_NETWORK -m tcp --dport 22 -j ACCEPT

	info "Allow docker access from internal network only"
	$IPTABLES_COMMAND -I DOCKER-USER -i $EXT_IF ! -s $LOCAL_NETWORK -j DROP

	info "Local services"

	for service in minidlna:tcp:8200 minidlna:udp:1900 nas:udp:137 nas:udp:138 nas:tcp:139 nas:tcp:445 ga:tcp:5000
	do
		openToSource $service $LOCAL_NETWORK
	done

	info "Allow services from docker network"

	for service in ga:tcp:5000
	do
		openToSource $service $DOCKER_NETWORK
	done

	info "Default, allow established and out, drop everything else"
	$IPTABLES_COMMAND -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	$IPTABLES_COMMAND -P OUTPUT ACCEPT 

	info "Logging"
	$IPTABLES_COMMAND -N LOGGING
	$IPTABLES_COMMAND -A INPUT -j LOGGING

	if [[ $LOGGING_ENABLED -eq 1 ]]; then
		$IPTABLES_COMMAND -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "$IPTABLES_LOG_PREFIX" --log-level 4
	fi

	$IPTABLES_COMMAND -A LOGGING -j DROP

	info "Completed"
}

function openToSource() {
	service=$1
	source=$2

	name=$(echo $service | cut -d':' -f 1)
	proto=$(echo $service | cut -d':' -f 2)
	port=$(echo $service | cut -d':' -f 3)
	echo "   $name:$proto:$port"
	$IPTABLES_COMMAND -A INPUT -p $proto -m $proto -s $source --dport $port -j ACCEPT
}

# Main
case $1 in
        clean)
                clean
                ;;
        list)
                list
                ;;
        setup)
                setup
                ;;
        *)
                echo "Usage: iptables.sh {clean|list|setup}"
                exit 1
                ;;
esac

# EOF
