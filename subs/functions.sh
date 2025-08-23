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

	MESSAGE=$1;

	EVENT="HOME_EVENT";
	KEY=$sec_IFTT_KEY
	PHONE_NUMBER=$sec_PHONE_NUMBER
	PAYLOAD="{ \"value1\" : \"$PHONE_NUMBER\", \"value2\" : \"$MESSAGE\" }";

	curl -X POST -H "Content-Type: application/json" -d "$PAYLOAD" https://maker.ifttt.com/trigger/${EVENT}/with/key/${KEY} > /dev/null 2>&1
}

#
# Record an event
#
function event() {

	EVENT_MSG=$1
	EVENT_CAT=$2

	if [[ -z $EVENT_CAT ]]; then
		EVENT_CAT="default"
	fi

	EVENT_USER=$(whoami)

	executeQuery "INSERT INTO event VALUES (null,CURRENT_TIMESTAMP(),'$EVENT_CAT','$EVENT_USER','$EVENT_MSG')"
}

#
# List all events
#
function getevents() {
	GROUP=$1

	condition=""

	if [[ ! -z $GROUP ]]; then
		condition=" WHERE category = '$GROUP' "
	fi

	executeQuery "SELECT * FROM event $condition ORDER BY datetime DESC;"
}

#
# Executes a mysql query on events db
#
function executeQuery() {
	QUERY=$1

	USER=raspberrypi
	PASS=$sec_MYSQL_ROOT_PASSWORD
	DB=events
	CONTAINER=mysql

	/usr/bin/docker exec -i $CONTAINER mysql -u$USER -p$PASS -D $DB --table <<< "$QUERY"
}

#
# Calls google assistant
#
function ga() {
	ACTION="$1"
	COMMAND="$2"

	USAGE="USAGE: ga <action (say|execute)> <command>"

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

	POD=$1

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

	BODY=$1
	SUBJECT=$2
	TO=$3

	/usr/bin/echo "$BODY" | mailx -s "$SUBJECT" $TO
}

#
# Sends a file by email
#
function mailFile() {

	FILE=$1
	SUBJECT=$2
	TO=$3

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
	TYPE=$1
	LOGFILE=$2

	debug "Sending $LOGFILE via email to $EMAIL_TO"
	
	mailFile $LOGFILE "[SERVICES][BACKUP] Backup report for $TYPE" $EMAIL_TO
}

# EOF
