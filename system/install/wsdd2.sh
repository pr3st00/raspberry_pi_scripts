echo "Installing wsdd2"

cd /home/pi/projects/c/wsdd2
make clean
make
sudo make install

echo "Starting wsdd2 service"

/usr/sbin/wsdd2 -N NAS -G WORKGROUP -4 -d &

echo "Completed"

# EOF