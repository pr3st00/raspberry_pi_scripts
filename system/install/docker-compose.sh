echo "Installing docker-compose"

sudo apt-get update && sudo apt-get upgrade
sudo apt-get install libffi-dev libssl-dev
sudo apt install python3-dev
sudo apt-get install -y python3 python3-pip
sudo pip3 install docker-compose

echo "Completed"

# EOF
