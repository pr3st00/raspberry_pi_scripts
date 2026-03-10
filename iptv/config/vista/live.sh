#
# Processing parameters
#
LIST_NAME="Vista Live Channels"

HOST1="acsb.sh"
HOST2="cb.vistaplay.me"
HOST3="prestotv.sytes.net"
HOST4="rootdns.me"
HOST5="cb.visualprint.me"

HOST=$HOST3

URL_TYPE=m3u_plus
URL_OUTPUT=m3u8

URL="http://$HOST/get.php?username=$sec_IPTV_USER&password=$sec_IPTV_PASSWORD&type=$URL_TYPE&output=$URL_OUTPUT"
MAX_ENTRIES=200000

HIDE_LIST="${SCRIPT_DIR}/config/vista/rules/live/hide_list.txt"
ALLOW_LIST="${SCRIPT_DIR}/config/vista/rules/live/allow_list.txt"

DEST_FILE="${DEST_DIR}/live.m3u"

# EOF
