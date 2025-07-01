echo "Installing SAMBA"

sudo apt-get install samba samba-common-bin
sudo smbpasswd -a pi
sudo systemctl restart smbd
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.orig

echo "Completed"

# EOF
