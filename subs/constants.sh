#
# Shared Constants
#

# Network
LOCAL_NETWORK="192.168.1.0/24"
EXT_IF="WLAN0"

# Locations
BASE_DIR="/home/pi"
PROJECTS_DIR="${BASE_DIR}/projects"
CONTAINERS_DIR="${BASE_DIR}/docker"
BACKUP_DIR="${BASE_DIR}/Backup"
LOG_DIR="/var/log/system"

# Data
MYSQL_ROOT_PASSWORD=$sec_MYSQL_ROOT_PASSWORD

# Events categories
BACKUP_CAT="backup"
SECURITY_CAT="security"
NAS_CAT="nas"
SYSTEM_CAT="system"

# Misc
GREEN='\033[00;32m' # green
RED='\033[00;31m'   # red
RESET='\033[00;00m' # white

EMAIL_TO="fernando.c.almeida@gmail.com"
SERVICES_URL="http://services.home"

# EOF
