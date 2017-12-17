#!/bin/bash
echo "upgrade pool"
echo "usage: bash upgrade_pool.bash <ROOT_SQL_PASS> <POOL_CODE>"
sleep 5
echo "Continuing install,  Please do not run me as root!"
HOME_DIR=/home/windy
UPDATE_DIR=$HOME_DIR/pool-updates
mkdir -p $UPDATE_DIR
cd $UPDATE_DIR
wget "https://raw.githubusercontent.com/xfstudio/nodejs-pool/master/deployment/$2_pool_config.sql" -N
mysql -u root --password=$1 < $UPDATE_DIR/$2_pool_config.sql
echo "Done upgrade pool"

sudo pm2 startOrRestart /usr/local/src/monero/build/release/bin/monero-wallet-rpc --name=moneroWalletRPC --log-date-format="YYYY-MM-DD HH:mm Z" -- --rpc-bind-port 18082 --password-file $HOME_DIR/xmr_wallet_pass --wallet-file /root/xmr_windy_wallet.bin --disable-rpc-login --trusted-daemon

echo "restart pool"
cd $HOME_DIR/nodejs-pool
git pull origin master
npm install

pm2 startOrRestart $HOME_DIR/nodejs-pool/init.js --name=blockManager --log-date-format="YYYY-MM-DD HH:mm Z"  -- --module=blockManager
pm2 startOrRestart $HOME_DIR/nodejs-pool/init.js --name=worker --log-date-format="YYYY-MM-DD HH:mm Z" -- --module=worker
pm2 startOrRestart $HOME_DIR/nodejs-pool/init.js --name=payments --log-date-format="YYYY-MM-DD HH:mm Z" -- --module=payments
pm2 startOrRestart $HOME_DIR/nodejs-pool/init.js --name=remoteShare --log-date-format="YYYY-MM-DD HH:mm Z" -- --module=remoteShare
pm2 startOrRestart $HOME_DIR/nodejs-pool/init.js --name=longRunner --log-date-format="YYYY-MM-DD HH:mm Z" -- --module=longRunner
pm2 startOrRestart $HOME_DIR/nodejs-pool/init.js --name=pool --log-date-format="YYYY-MM-DD HH:mm Z" -- --module=pool
pm2 startOrRestart $HOME_DIR/nodejs-pool/init.js --name=api --log-date-format="YYYY-MM-DD HH:mm Z" -- --module=api

cd $HOME_DIR/xssminer
git pull origin master
npm install
pm2 startOrRestart $HOME_DIR/xssminer/server.js -i 0 --name="xssminer"

cd $HOME_DIR/poolui
git pull origin master
npm install
./node_modules/bower/bin/bower update
./node_modules/gulp/bin/gulp.js build
cd build
pm2 startOrRestart $HOME_DIR/poolui/build/app.js -i 0 --name="poolui"

sudo cp $HOME_DIR/nodejs-pool/deployment/sites/* /etc/nginx/sites-available/
sudo nginx -t
sudo nginx -s reload