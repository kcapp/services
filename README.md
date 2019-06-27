# kcapp-services
`systemd` service files to install `kcapp` to run along side other services

## Install
To use these scripts create the following in `/usr/local/bin/`

• `kcapp-announcer`
```
#!/bin/bash
cd $KCAPP_ROOT/announcer
node kcapp-announcer.js
```

• `kcapp-api`
Symlink `api` to `/usr/loca/bin/kcapp-api`
```
sudo ln -s $GOPATH/bin/kcapp-api /usr/local/bin
```

• `kcapp-frontend`
```
#!/bin/bash
cd $KCAPP_ROOT/frontend
DEBUG=kcapp:* npm start &>> log/kcapp.log
```

