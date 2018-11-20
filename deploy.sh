#!/bin/bash

# Stop running processes
sudo service kcapp-frontend stop
sudo service kcapp-api stop

# Update api
cd ~/go/src/github.com/kcapp/api
git pull
go build
mv api kcapp-api

# Update frontend
cd ~/kcapp/frontend
git pull
npm install

# Start services again
sudo service kcapp-api start
sudo service kcapp-frontend start