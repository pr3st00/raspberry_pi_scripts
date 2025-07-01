sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
#sudo rm /var/lib/dpkg/locksudo cp -arf /var/lib/dpkg /var/lib/dpkg.backup
sudo mv /var/lib/dpkg/status /var/lib/dpkg/status-bad
sudo cp /var/lib/dpkg/status-old /var/lib/dpkg/status || sudo cp /var/backups/apt.extended_states.0 /var/lib/dpkg/status
sudo mv /var/lib/dpkg/available /var/lib/dpkg/available-bad
#sudo cp /var/lib/dpkg/available-old /var/lib/dpkg/available
sudo rm -rf /var/lib/dpkg/updates/*
sudo rm -rf /var/lib/apt/lists
sudo rm /var/cache/apt/*.bin
sudo mkdir /var/lib/apt/lists
sudo mkdir /var/lib/apt/lists/partial
