#
# Shared Functions
#

function debugon() {
	export DEBUG=1
}

function debugoff() {
	export DEBUG=0
}

#
# Displays info message
#
function info() {
	echo -e "${GREEN}[INFO] ${@}${RESET}"
}
 
#
# Display warning message
#
function warn() {
	echo -e "${YELLOW}[WARN] ${@}${RESET}"
}

#
# Display error message
#
function error() {
	echo -e "${RED}[ERROR] ${@}${RESET}"
}

#
# Displays debug message (if enabled)
#
function debug() {
	if [[ $DEBUG == "1" ]]; then
		echo -e "${MAGENTA}[DEBUG] ${@}${RESET}"
	fi
}

#
# Strip color characters
#
function stripColors() {

	local line
	while read line
	do
		sed -e "s#\[00;[0-9][0-9]m##g" | sed -e "s#\033##g"
	done < "${1:-/dev/stdin}"
}

#
# Logs start of a process
#
function logStart() {
	info "Process started at $(date)"
}

#
# Sends an SMS
#
function sms() {

	local MESSAGE=$1;

	local EVENT="HOME_EVENT";
	local KEY=$sec_IFTT_KEY
	local PHONE_NUMBER=$sec_PHONE_NUMBER
	local PAYLOAD="{ \"value1\" : \"$PHONE_NUMBER\", \"value2\" : \"$MESSAGE\" }";

	curl -X POST -H "Content-Type: application/json" -d "$PAYLOAD" https://maker.ifttt.com/trigger/${EVENT}/with/key/${KEY} > /dev/null 2>&1
}

#
# Record an event
#
function event() {

	local EVENT_MSG=$1
	local EVENT_CAT=$2

	if [[ -z $EVENT_CAT ]]; then
		EVENT_CAT="default"
	fi

	local EVENT_USER=$(whoami)

	executeQuery "INSERT INTO event VALUES (null,CURRENT_TIMESTAMP(),'$EVENT_CAT','$EVENT_USER','$EVENT_MSG')"
}

#
# List all events
#
function getevents() {
	local GROUP=$1

	local condition=""

	if [[ ! -z $GROUP ]]; then
		condition=" WHERE category = '$GROUP' "
	fi

	executeQuery "SELECT * FROM event $condition ORDER BY datetime DESC;"
}

#
# Executes a mysql query on events db
#
function executeQuery() {
	local QUERY=$1

	local USER=raspberrypi
	local PASS=$sec_MYSQL_ROOT_PASSWORD
	local DB=events
	local CONTAINER=mysql

	/usr/bin/docker exec -i $CONTAINER mysql -u$USER -p$PASS -D $DB --table <<< "$QUERY"
}

#
# Calls google assistant
#
function ga() {
	local ACTION="$1"
	local COMMAND="$2"

	local USAGE="USAGE: ga <action (say|execute)> <command>"

	if [[ -z $ACTION || -z $COMMAND ]]; then
		warn "Missing action or command"
		echo $USAGE
		return
	fi


	if [[ $ACTION == "say" ]]; then
		URI="broadcast_message"
	elif [[ $ACTION == "execute" ]]; then
		URI="command"
	else
		warn "Invalid action"
		echo $USAGE
		return
	fi

	/usr/bin/wget -q -O /dev/null "${SERVICES_URL}:5000/${URI}?message=$COMMAND"
}

#
# Executes bash in the container
#
function dockershell() {

	local POD=$1

	if [[ -z $POD ]]; then
		warn "POD is required"
	else
		info "Trying bash..."
		/usr/bin/docker exec -it $POD /bin/bash

		RETURN_CODE=$?

		if [[ $RETURN_CODE -ne 0 ]]; then
			info "Trying sh..."
			/usr/bin/docker exec -it $POD /bin/sh
		fi

		info "Return code is [$RETURN_CODE]"
	fi
}

#
# Sends an email
#
function mail() {

	local BODY=$1
	local SUBJECT=$2
	local TO=$3

	/usr/bin/echo "$BODY" | mailx -s "$SUBJECT" $TO
}

#
# Sends a file by email
#
function mailFile() {

	local FILE=$1
	local SUBJECT=$2
	local TO=$3

	info "Sending email"

	if [[ -f $FILE ]]; then
		debug "Email command is: /usr/bin/cat $FILE | stripColors | mailx -s $SUBJECT $TO"
		/usr/bin/cat $FILE | stripColors | mailx -s "$SUBJECT" $TO
	else
		warn "File [$FILE] not found"
	fi
}

#
# Central function for backup notification
#
function notifyBackup() {
	local TYPE=$1
	local LOGFILE=$2

	debug "Sending $LOGFILE via email to $EMAIL_TO"
	
	mailFile $LOGFILE "[SERVICES][BACKUP] Backup report for $TYPE" $EMAIL_TO
}

function isAlive() {

	local HOSTNAME=$1
	local PING_COUNT=3

	if [[ -z $HOSTNAME ]]; then
		warn "Missing hostname"
		return 255
	fi

	/usr/bin/ping -c $PING_COUNT $HOSTNAME > /dev/null 2>&1
	return $?
}

# EOF
