echo "Installing docker"

sudo apt install raspberrypi-kernel raspberrypi-kernel-headers
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker pi
sudo cp /home/pi/Backup/daemon.json /etc/docker/

echo "Completed"
echo "Reboot the system now."

echo "After reboot, run: docker network create --subnet=172.24.0.0/16 services_network"

# EOF
