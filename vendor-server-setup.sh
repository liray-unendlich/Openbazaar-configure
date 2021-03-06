#!/bin/bash
#please do this script as root.
######################################################################

clear
echo "*********** Welcome to the Phore (PHR) Bazaar Server Setup Script ***********"
echo 'This script will install all required updates & package for Ubuntu 16.04 !'
echo 'This script will install openbazaar server client and phored.'
echo 'You can run this script on VPS only.'
echo '****************************************************************************'
sleep 2
echo '*** Step 1/4 ***'
echo '*** Installing package ***'
sleep 2
apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get install -y nano htop
wget https://github.com/phoreproject/Phore/releases/download/v1.2.0.0/phore-1.1.0-x86_64-linux-gnu.tar.gz
wget https://github.com/phoreproject/openbazaar-go/releases/download/v1.0.1/openbazaar-go-linux-amd64
mv openbazaar-go-linux-amd64 openbazaard
tar -xvzf phore-1.1.0-x86_64-linux-gnu.tar.gz
rm phore-1.1.0-x86_64-linux-gnu.tar.gz
cd phore-1.1.0/bin
mv phored phore-cli phore-tx ~/
cd ~/
chmod +x openbazaard phored phore-cli phore-tx
mv openbazaard phored phore-cli phore-tx /usr/local/bin/
rm -r phore-1.1.0
sleep 1
echo '*** Done 1/4 ***'
sleep 1
echo '*** Step 2/4 ***'
echo '*** Starting & Configuring firewall ***'
apt-get install -y ufw
ufw default deny
ufw allow ssh/tcp
ufw logging on
ufw --force enable
ufw status
echo '*** Configuring the wallet ***'
mkdir .phore
rpcusr=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
rpcpass=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
echo "rpcuser=$rpcusr\nrpcpassword=$rpcpass\nrpcallowip=127.0.0.1\nlisten=1\nserver=1\ndaemon=1\nstaking=0\nlogtimestamps=1\nmaxconnections=256" > ~/.phore/phore.conf
echo '*** Done 3/4 ***'
echo '*** Start syncing and initialize openbazaard ***'
openbazaard init
sed -i -e 's/"AcceptStoreRequests": false/"AcceptStoreRequests": true/g' .openbazaar2.0/config
#rpcusr=$(cat .phore/phore.conf | grep rpcuser | awk '{print substr($0,9)}')
#rpcpass=$(cat .phore/phore.conf | grep rpcpassword | awk '{print substr($0,13)}')
sed -i -e "s:phorerpc:$rpcusr:" .openbazaar2.0/config
sed -i -e "s:rpcpassword:$rpcpass:" .openbazaar2.0/config
echo '*** Starting OpenBazaard ***'
sleep 1
openbazaard start --verbose
echo "Your openbazaar server is started!"
echo '*** Done 4/4 ***'
