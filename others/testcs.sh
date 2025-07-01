#!/bin/bash

HOSTS="ne.csdez.top:16000 netop.ddns.net:16000 net.hopto.org:16000"
TIMEOUT=10

for HOSTINFO in $HOSTS
do
	HOST=$(echo $HOSTINFO | cut -d':' -f 1)
	PORT=$(echo $HOSTINFO | cut -d':' -f 2)

	echo -n "* Testing host $HOST	"
	echo "TEST" | nc -w $TIMEOUT $HOST $PORT > /dev/null 2>&1

	if [[ $? -eq 0 ]]; then
		echo "[OK]";
	else
		echo "[NOK]";
	fi
done

# EOF
