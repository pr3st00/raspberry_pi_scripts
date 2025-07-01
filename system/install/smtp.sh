echo "Installing mailing software"

sudo apt install bsd-mailx msmtp msmtp-mta

sudo touch /etc/msmtprc
sudo chown root:msmtp /etc/msmtprc 
sudo chmod 640 /etc/msmtprc

sudo touch /var/log/msmtp.log
sudo chown pi:pi /var/log/msmtp.log

echo "Completed"

# EOF
