sudo apt-get update
sudo apt-get install automake autoconf pkg-config libcurl4-openssl-dev libjansson-dev \
libssl-dev libgmp-dev zlib1g-dev make g++
sudo apt-get install git
git clone https://github.com/tpruvot/cpuminer-multi.git
cd cpuminer-multi
sudo ./build.sh
./cpuminer -u bc1qkt9wq35a7n27v0xr53l720m40jxsc8du6nwka4.cel_motoxplay -p x \
-a sha256d -o stratum+tcp://public-pool.io:21496
