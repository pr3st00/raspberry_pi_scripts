#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
source ${DIR}/../subs/constants.sh
source ${DIR}/../subs/functions.sh

function clean_images() {

	info "Cleaning all unused images in docker"

	/usr/bin/docker image prune -a -f

	info "Completed"
	event "DOCKER images cleared sucessfully" $SYSTEM_CAT
}

function clean_volumes() {

	info "Cleaning all unused volumes in docker"

	/usr/bin/docker volume prune -f

	info "Completed"
	event "DOCKER volumes cleared sucessfully" $SYSTEM_CAT
}

function start_required() {

	info "Starting required containers"

	start_stop_required "start"

	info "Completed"
}

function stop_required() {

	info "Stopping required containers"

	start_stop_required "stop"

	info "Completed"
}

function start_stop_required() {

	action=$1;

	for c in mysql eventproxy google-assistant
	do
		/usr/bin/docker $action $c
	done

	for s in nginx
	do
		(cd /home/pi/docker/$s && docker-compose $action)
	done
}

function restart() {

	info "Restarting docker daeamon"

	sudo systemctl restart docker

	info "Completed"
}

function check_for_updates {

	USAGE="USAGE: check_for_updates <REGISTRY> <BASE_IMAGE>";

	REGISTRY=$2
	BASE_IMAGE=$3
	IMAGE="$REGISTRY/$BASE_IMAGE"

	if [[ -z $REGISTRY ]]; then
		warn "REGISTRY is required"
		info $USAGE
		exit 1;
	fi

	if [[ -z $BASE_IMAGE ]]; then
		warn "BASE_IMAGE is required"
		info $USAGE
		exit 1;
	fi

	CID=$(docker ps -a --format "{{.ID}} {{.Image}} {{.Names}}" | grep $REGISTRY | awk '{print $1}')

	info "CID is $CID"

	info "Pulling latest image for $IMAGE"
	docker pull $IMAGE > /dev/null 2>&1

	if [[ ! $? -eq 0 ]]; then
		warn "Error pulling image"
		exit 1
	fi


	for im in $CID
	do
		LATEST=`docker inspect --format "{{.Id}}" $IMAGE`
		RUNNING=`docker inspect --format "{{.Image}}" $im`
		NAME=`docker inspect --format '{{.Name}}' $im | sed "s/\///g"`
		info "Latest:" $LATEST
		info "Running:" $RUNNING

		if [ "$RUNNING" != "$LATEST" ];then
			warn "$NAME needs upgrade!"
		else
			info "$NAME up to date"
		fi
	done
}

# Main
case $1 in
	all)
		logStart
		clean_images
		clean_volumes
		start_required
		stop_required
		;;
	clean_images)
		logStart
		clean_images
		;;
	clean_volumes)
		logStart
		clean_volumes
		;;
	start_required)
		logStart
		start_required
		;;
	stop_required)
		logStart
		stop_required
		;;
	check_for_updates)
		logStart
		check_for_updates "$@"
		;;
	restart)
		logStart
		restart
		;;
	*)
		echo "Usage: docker.sh {clean_images|clean_volumes|start_required|stop_required|check_for_updates|restart|all}"
		exit 1
		;;
esac

# EOF
