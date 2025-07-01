# NAS
echo "Creating NAS directories"
sudo mkdir /external
sudo chown pi:pi /external
mkdir /external/hd1
mkdir /external/hd2
mkdir /external/hd3

# Logging
echo "Creating logging directories"
sudo mkdir /var/log/system
sudo chown pi:pi /var/log/system
mkdir /var/log/system/backup

# Misc
echo "Creating misc directories"a
mkdir /home/pi/.ssh
sudo touch /var/log/msmtp.log
sudo chown pi:pi /var/log/msmtp.log
mkdir /home/pi/.ssh.recalbox
touch /var/log/system/backup/rclone_backup.log
touch /var/log/msmtp.log

echo "Completed"

# EOF
