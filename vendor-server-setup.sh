#!/bin/bash
#please do this script as root.
######################################################################

clear
echo "*********** Welcome to the Phore (PHR) Bazaar Server Setup Script ***********"
echo 'This script will install all required updates & package for Ubuntu 16.04 !'
echo 'This script will install openbazaar server client and phored.'
echo 'You can run this script on VPS only.'
echo '****************************************************************************'
sleep 3
echo '*** Step 1/4 ***'
echo '*** Installing package ***'
sleep 2
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y nano htop git
sudo apt-get install -y software-properties-common
sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev libevent-dev
sudo apt-get install -y libboost-all-dev
sudo apt-get install -y libminiupnpc-dev
sudo apt-get install -y autoconf
sudo apt-get install -y automake
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
wget https://github.com/phoreproject/openbazaar-go/releases/download/v1.0.1/openbazaar-go-linux-amd64
mv openbazaar-go-linux-amd64 openbazaard
chmod +x openbazaard
sudo cp openbazaard /usr/local/bin/
sleep 1
echo '*** Done 1/4 ***'
sleep 1
echo '*** Step 2/4 ***'
echo '*** Starting & Configuring firewall ***'
sudo apt-get install -y ufw
sudo ufw default deny
sudo ufw allow ssh/tcp
sudo limit ssh/tcp
sudo ufw logging on
sudo ufw --force enable
sudo ufw status
sleep 1
echo "***make swap***"
grep -q "swapfile" /etc/fstab
if [ $? -ne 0 ]; then
  echo "can't find swapfile. making swapfile..."
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap defaults 0 0' >> /etc/fstab
else
  echo 'find swapfile, go next step...'
fi
echo '*** Done 2/4 ***'
sleep 1
echo "***Compiling phored...***"
git clone https://github.com/phoreproject/Phore.git
cd Phore
sudo ./autogen.sh
sudo ./configure
sudo make
sudo make install
echo '*** Starting & configuring the wallet ***'
sleep 2
phored -daemon
sleep 3
echo -n 'Dont worry about rpcuser~ errors.'
rpcusr=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
rpcpass=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)

echo -e "rpcuser=$rpcusr\nrpcpassword=$rpcpass\nrpcallowip=127.0.0.1\nlisten=1\nserver=1\ndaemon=1\nstaking=0\nlogtimestamps=1\nmaxconnections=256\n" > ~/.phore/phore.conf

echo '*** Done 3/4 ***'
echo '*** Start syncing and initialize openbazaard ***'
phored -daemon
openbazaard init
sed -i -e 's/"AcceptStoreRequests": false/"AcceptStoreRequests": true/g' .openbazaar2.0/config
#rpcusr=$(cat .phore/phore.conf | grep rpcuser | awk '{print substr($0,9)}')
#rpcpass=$(cat .phore/phore.conf | grep rpcpassword | awk '{print substr($0,13)}')
sed -i -e "s:phorerpc:$rpcusr:" .openbazaar2.0/config
sed -i -e "s:rpcpassword:$rpcpass:" .openbazaar2.0/config
echo 'Please wait for a minute. it will show you result of phore-cli getinfo'
sleep 60
phore-cli getinfo
sleep 2
openbazaard start --verbose
echo "Your openbazaar server is started!"
echo '*** Done 4/4 ***'
