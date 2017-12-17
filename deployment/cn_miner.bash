#!/bin/bash
echo "upgrade miner(rc.local): wget https://raw.githubusercontent.com/xfstudio/nodejs-pool/master/deployment/cn_miner.bash -o /root/cn_miner.bash -N && bash /root/cn_miner.bash"
echo "Continuing auto run, Please run me as root!"

SALT_MASTER=pool.xf.sc.cn
POOL_HOST=miner.xf.sc.cn
POOL_PORT=5555
MINER_WALLET=46KLU3zxPAtUqKqd5VHQBd3Vxt1quP6JUd2CruioHTog5G34NnubN1Jc7dMtvgZhhq3caBJ2hPacqSWsxPmSJUwZFtd1373
# salt
sed -i "16c master: $HOST_MASTER" /etc/salt/minion
sed -i "78c id: $(curl ifconfig.me)-$(ifconfig eth0|grep 'inet addr'| awk '{print ($2)}'|awk -F: '{print ($2)}')" /etc/salt/minion

systemctl enable salt-minion
systemctl restart salt-minion

if test $( pgrep -f xmrMiner | wc -l ) -eq 0 
then 
~/xmrMinerProject/build/xmrMiner -o stratum+tcp://$POOL_HOST:$POOL_PORT -u $MINER_WALLET -p x -z 0 -B 
else 
echo "$(pgrep -f xmrMiner)"
fi 
