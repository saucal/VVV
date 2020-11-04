#!/bin/sh

npm install --unsafe-perm -g ngrok
echo "You'd need to setup your auth token to use ngrok"

VVV_NGROK_PATH="/etc/vvv-ngrok"

mkdir -p "$VVV_NGROK_PATH"
chown vagrant:vagrant "$VVV_NGROK_PATH"
cp /srv/config/homebin/ngrok.js "${VVV_NGROK_PATH}/"

cd "$VVV_NGROK_PATH"
npm install --save ngrok yargs shutdown-async