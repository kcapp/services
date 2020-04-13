![kcapp logo](https://raw.githubusercontent.com/kcapp/frontend/master/public/images/logo.png)
# services
`systemd` service files to install `kcapp` to run along side other services

## Install
To use these scripts create the following in `/usr/local/bin/`

• `kcapp-announcer`
```bash
#!/bin/bash
export SLACK_KEY="<slack_key>"
export SLACK_CHANNEL="<channel>"
export ANNOUNCE=true

cd $KCAPP_ROOT/announcer
node kcapp-announcer.js <office_id>
```

• `kcapp-api`
Symlink `api` to `/usr/loca/bin/kcapp-api`
```bash
sudo ln -s $GOPATH/bin/kcapp-api /usr/local/bin
```

• `kcapp-frontend`
```bash
#!/bin/bash
cd $KCAPP_ROOT/frontend
DEBUG=kcapp:* npm start &>> log/kcapp.log
```

