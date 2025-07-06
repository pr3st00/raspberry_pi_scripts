# raspberry_pi_scripts

List os shell scripts from my raspberry pi.

All secure values are referenced in the scripts with variables with _sec prefix.

.bashrc loading secure files

# Secure constants
. /home/pi/scripts/subs/.secure

.secure contents:

#
# SECURE CONSTANTS
#
export sec_MYSQL_ROOT_PASSWORD="XXXXXXX"
export sec_IFTT_KEY="XXXXXXXXX"
export sec_PHONE_NUMBER="XXXXXXXX"

export sec_DISCORD_WEBHOOK_URL1="XXXXXXXXXXXXXX"
export sec_DISCORD_WEBHOOK_URL2="XXXXXXXXXXXXXX"

export sec_WIT_TOKEN="XXXXXXXXXX"

export sec_IPTV_USER="XXXXX"
export sec_IPTV_PASSWORD="XXXXXX"

# EOF
