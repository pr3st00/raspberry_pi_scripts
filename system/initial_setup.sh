#!/bin/bash

echo "Initial system setup"

################################################################################################################################################
echo "1. Create directories"

dmesg
lsblk
cd /
sudo mkdir /external
cd external/
sudo mkdir hd1 hd2
ls -ltr
sudo mount /dev/sda1 /external/hd1
cd /external/hd1/
ls
sudo mount /dev/sda2 /external/hd1
cd /external/hd1/
ls

################################################################################################################################################
echo "2. Mount backup image"

cd
mkdir ~/mnt_backup
fdisk -l /external/hd1/Backup/raspbian_backup.img 
sudo mount -o loop,offset=272629760 /external/hd1/Backup/raspbian_backup.img ~/mnt_backup
cd mnt_backup/

################################################################################################################################################
echo "3. Fix fstab and reboot"

ls -ltr
cd /etc/
ls
sudo vi /etc/fstab 
sudo reboot

################################################################################################################################################
echo "4. Copy projects and scripts, create symlinks"

cd
ln -s /external/hd1 nas
ls -ltr
pwd
sudo cp -Rp mnt_backup/home/pi/scripts .
sudo cp -Rp mnt_backup/home/pi/projects .
ln -s scripts/docker .
sudo cp -Rp mnt_backup/home/pi/Backup .
cp mnt_backup/home/pi/.bash_aliases .
zramctl 

################################################################################################################################################
echo "5. Install docker"

sudo apt-get update
cd /etc/apt/sources.list.d/
sudo cp ~/mnt_backup/etc/apt/sources.list.d/docker.list .
cd ../keyrings/
sudo cp ~/mnt_backup/etc/apt/keyrings/docker.gpg .
sudo usermod -aG docker pi
sudo apt-get install docker-compose-plugin
sudo apt-get install docker-ce docker-ce-cli containerd.io
docker compose
docker network create services_network
docker network ls
   
################################################################################################################################################   
echo "6. Install containers"   
   
cd

# fundamentus

cd docker
cd fundamentus
bash docker.sh build
dockerps
bash docker.sh run
bash docker.sh start
cd ..
ls -tlr

# nginx

cd nginx/
sudo bash useradd.sh 
cd php-fpm/
bash build.sh 
dockerps
cd ..
. ./updatenginx.sh 
dockerps
cd ..

# mysql

cd mysql/
bash run.sh 
cd ..

# noip

cd noip/
bash run.sh 
dockerps
cd ..

# emulatorjs

cd emulatorjs/
docker compose up
cd ..
ls

# squid  

cd squid
bash run.sh 
dockerps

# google-assistant

cd
cd docker
cd google-assistant
bash run.sh 
dockerps

# pihole

cd
cd docker
cd pihole/
. ./update.sh 
dockerps
cat update.sh 
ls -ltr
docker compose down
docker compose up -d
dockerps

# portainer

cd portainer/
ls -ltr
bash run.sh 
dockerps

# deluge  

containers
ls
cd deluge/
ls
cat run.sh 
bash run.sh 
dockerps

################################################################################################################################################
echo "7. Motd"

# motd
sudo cp ~/mnt_backup/etc/profile.d/motd.sh /etc/profile.d  

################################################################################################################################################
echo "8. Utils"

# utils
sudo apt-get install util-linux
sudo apt-get install bsdutils
sudo apt-get install util-linux-extra
sudo apt get install bsdextrautils 

################################################################################################################################################
echo "9. Samba"

sudo apt-get install samba samba-common-bin
sudo apt-get install samba 
cd /etc/samba/
sudo cp smb.conf smb.conf.orig
sudo cp ~/mnt_backup/etc/samba/smb.conf .
nas.sh status
nas.sh umount
nas.sh mount
nas.sh status
docker cp all-databases.sql mysql:/tmp
dockershell mysql
nas.sh status

################################################################################################################################################
echo "10. Restore logs and crontab"

# restore logs
cd /var/log/
ls
sudo cp -Rp ~/mnt_backup/var/log/system .
ls -ltr

# restore crontab 
cd
cd Backup/
ls -ltr
crontab < crontab
crontab -l
 
################################################################################################################################################ 
echo "11. Minidlna" 
 
# minidlna
sudo apt install minidlna -y
cd /etc/
sudo cp minidlna.conf minidlna.conf.orig
sudo cp ~/mnt_backup/etc/minidlna.conf .
minidlna.sh refresh

################################################################################################################################################
# check zramctl  
zramctl 

# last  
sudo apt install wtmpdb
wtmpdb last

# msmtprc
sudo cp msmtprc /etc
sudo apt install msmtp
sudo cp ~/mnt_backup/etc/msmtprc ~/.msmtprc
sudo chmod 600 ~/.msmtprc
ls -ltra
cd
ls -ltra
chown pi:pi .msmtprc 
sudo chown pi:pi .msmtprc 
echo -e "Subject: Teste Raspberry Pi\n\nEste é um e-mail de teste do msmtp." | msmtp -v fernando.c.almeida@gmail.com
cd /var/log/
sudo touch msmtp.log
sudo chown pi:pi msmtp.log
sudo apt-get install bsd-mailx
echo "teste" | mailx -s "Testing" fernando.c.almeida@gmail.com

# rclone
sudo -v ; curl https://rclone.org/install.sh | sudo bash
cp ~/mnt_backup/home/pi/.config/rclone/rclone.conf .
backup.sh rclone
  
# git config  
git config pull.rebase false
git config --global credential.helper store
cd mnt_backup/
cd home/pi/
git config --global user.name "Fernando Almeida"
git config --global user.email "fernando.c.almeida@gmail.com"
cp .git-credentials ~

# bc
sudo apt install bc

# docker config
cd mnt_backup/
cd etc/docker/
ls
cat daemon.json 
sudo cp daemon.json /etc/docker/
sudo cp key.json /etc/docker/
sudo systemctl restart docker

# samba
cd samba/
ls
ls -ltr
tail -f *
cd /etc/samba/
vi smb.conf
sudo smbpasswd -a pi
sudo pdbedit -L
sudo smbpasswd -e pi

sudo systemctl restart smbd
sudo systemctl restart nmbd
nas.sh status
sudo systemctl restart smbd nmbd

# nginx report`  
sudo apt install goaccess
  
# ntpdate  
sudo apt install ntpdate
sudo apt install ntpsec-ntpdate
sudo ntpdate 0.debian.pool.ntp.org

# save history
history > install_history.txt 

echo "Remember:"
echo "1. Edit /boot/firmware/config.txt and add custom values"

echo "Completed"

# EOF