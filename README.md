![kcapp logo](https://raw.githubusercontent.com/wiki/kcapp/frontend/images/logo/kcapp_plus_systemd.png)
# services
`systemd` service files to install `kcapp` to run along side other services

## Install
To use these scripts create the following in `/usr/local/bin/`

### [kcapp-announcer](https://github.com/kcapp/slack-announcer)
```bash
#!/bin/bash
export SLACK_KEY="<slack_key>"
export SLACK_CHANNEL="<channel>"
export ANNOUNCE=true

cd $KCAPP_ROOT/announcer
node kcapp-announcer.js <office_id>
```

### [kcapp-api](https://github.com/kcapp/api)
Symlink `api` to `/usr/loca/bin/kcapp-api`
```bash
sudo ln -s $GOPATH/bin/kcapp-api /usr/local/bin
```

### [kcapp-frontend](https://github.com/kcapp/frontend)
```bash
#!/bin/bash
cd $KCAPP_ROOT/frontend
DEBUG=kcapp* npm run prod &>> log/kcapp.log
```

### [kcapp-colors](https://github.com/kcapp/colors)
```bash
#!/bin/bash
cd $KCAPP_ROOT/colors
RED=27 GREEN=17 BLUE=22 KCAPP_API=<HOST> PORT=<PORT> DEBUG=kcapp* npm start
```

### [kcapp-nfc](https://github.com/kcapp/nfc)
```bash
#!/bin/bash
cd $KCAPP_ROOT/nfc
DEBUG=kcapp* npm start
KCAPP_API=<HOST> PORT=<PORT> VENUE_ID=<VENUE_ID> DEBUG=kcapp* npm start
```