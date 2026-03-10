#
# Processing parameters
#
LIST_NAME="Vista Series"

HOST1="acsb.sh"
HOST2="cb.vistaplay.me"
HOST3="prestotv.sytes.net"
HOST4="rootdns.me"
HOST5="cb.visualprint.me"

HOST=$HOST3

URL="http://$HOST/get.php?username=$sec_IPTV_USER&password=$sec_IPTV_PASSWORD&type=m3u_plus&output=ts"
MAX_ENTRIES=300000

HIDE_LIST="${SCRIPT_DIR}/config/vista/rules/series/hide_list.txt"
ALLOW_LIST="${SCRIPT_DIR}/config/vista/rules/series/allow_list.txt"

DEST_FILE="${DEST_DIR}/series.m3u"

# EOF
