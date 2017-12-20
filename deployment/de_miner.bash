#!/bin/bash
echo "upgrade miner(rc.local): wget -q https://raw.githubusercontent.com/xfstudio/nodejs-pool/master/deployment/de_miner.bash -O /root/de_miner.bash && bash /root/de_miner.bash"
echo "Continuing auto run, Please run me as root!"

SALT_MASTER=192.168.1.145
MIONIN_ID=$(curl ifconfig.me)-$(ifconfig eth0|grep 'inet addr'| awk '{print ($2)}'|awk -F: '{print ($2)}')
POOL_HOST=192.168.1.145
POOL_PORT=7777
MINER_WALLET=46KLU3zxPAtUqKqd5VHQBd3Vxt1quP6JUd2CruioHTog5G34NnubN1Jc7dMtvgZhhq3caBJ2hPacqSWsxPmSJUwZFtd1373

if [ "$(sed -n '16p' /etc/salt/minion)"x = "master: $SALT_MASTER"x ]&&[ "$(sed -n '78p' /etc/salt/minion)"x = "id: $MIONIN_ID"x ];
then
echo "$(sed -n '16p' /etc/salt/minion)"
echo "$(sed -n '78p' /etc/salt/minion)"
else
systemctl stop salt-minion
sed -i "16c master: $SALT_MASTER" /etc/salt/minion
sed -i "78c id: $MIONIN_ID" /etc/salt/minion
rm /etc/salt/pki/minion/minion.pub
rm /etc/salt/pki/minion/minion.pem
echo $MIONIN_ID > /etc/salt/minion_id
systemctl start salt-minion
systemctl enable salt-minion
fi

if test $( pgrep -f xmrMiner | wc -l ) -eq 0 
then 
/home/windy/xmrMinerProject/build/xmrMiner -o stratum+tcp://$POOL_HOST:$POOL_PORT -u $MINER_WALLET -p worker -l 72X56 -z 0
else 
echo "$(pgrep -f xmrMiner)"
fi 
