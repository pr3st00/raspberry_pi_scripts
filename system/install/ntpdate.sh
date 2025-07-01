echo "Installing ntpdate"

sudo apt-get install ntpdate

echo "Updating date"

sudo /usr/sbin/ntpdate 0.debian.pool.ntp.org
date

echo "Completed"

# EOF
