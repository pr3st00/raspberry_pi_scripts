#!/bin/bash

# GO IPTV
#URL=http://tinyurl.com/y3kbkxwr

# Ze Ricardo
# URL=http://tinyurl.com/y6jv79gg

# Secure IPTV
URL=http://tv.secureiptv.com.br/4944840374

TEMPFILE=/tmp/lista.m3u
DESTINATIONFILE=~/lista.m3u
MAX_ITEMS=9999999

recallog "[INI] Downlading file"
wget -O $TEMPFILE $URL > /dev/null

recallog "[INFO] Transforming file"
cat /tmp/lista.m3u | sed -e 's/tvg-logo="data:image.*"/tv-logo="http:\/\/img.miptv.ws\/AMC_HD.png"/g' | head -n $MAX_ITEMS > $DESTINATIONFILE

recallog "[DONE] Completed sucessfully"
