#!/bin/bash

required() {
    #printf "Checking prerequisite \e[34m%-14s\e[39m" $1
    if ! [ -x "$(command -v $1)" ]; then
        echo "Error: $1 is not installed." >&2
        print_result FAILED
        exit 1
    fi
    #print_result
}

yesno() {
    while true; do
        printf "$@. Continue? [\e[32my\e[39m/\e[31mN\e[39m] "
        read -p "" yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit 2;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

git_clone() {
    printf "Cloning $1" $1
    eval "git clone --quiet $1 $2"
    print_result
}

git_pull() {
	cd $1
	local branch=$(git branch | grep \* | cut -d ' ' -f2)
	echo -ne "Pulling latest changes from '\e[34m$branch\e[39m'"
	local status=$(git pull)
	if [[ "$status" == Already* ]] ; then
	    echo -e " - \e[32mUp to date\e[39m!"
	    return 1
	else
	    echo -e " 1- \e[32mDONE\e[39m"
	    return 0
	fi
}

exit_code() {
	EXIT_CODE=$(echo $?)
	if [ "$EXIT_CODE" != "0" ] ; then
        echo -e "\nFailed when running \e[34m$1\e[39m. Possibly old version?"
	    exit 1
	fi
}

print_result() {
    if [ -z "$1" ] ; then
        printf " - \e[32mOK\e[39m\n"
    else
        printf " - \e[91mFAILED\e[39m\n"
    fi
}

# ===================================
# Prerequisites
# ===================================
INSTALL_DIRECTORY=${1:-$PWD}
INSTALL_DIRECTORY=${INSTALL_DIRECTORY%/}/kcapp
EXEC_DIRECTORY=/usr/local/bin
INSTALL=true
echo -e "  _                               _           _        _ _\n | |                             (_)         | |      | | |\n | | _____ __ _ _ __  _ __ ______ _ _ __  ___| |_ __ _| | | ___ _ __\n | |/ / __/ _\` | '_ \| '_ \______| | '_ \/ __| __/ _\` | | |/ _ \ '__|\n |   < (_| (_| | |_) | |_) |     | | | | \__ \ || (_| | | |  __/ |\n |_|\_\___\__,_| .__/| .__/      |_|_| |_|___/\__\__,_|_|_|\___|_|\n               | |   | |\n               |_|   |_|\n"

printf "Checking prerequisites"
required git
required go
required node
required npm
required docker
required docker-compose
required mysqlsh
required goose
print_result

# Check if directory already exists
if [ -d "$INSTALL_DIRECTORY" ]; then
    echo -e "\nDirectory '\e[34m$INSTALL_DIRECTORY\e[39m' already exists."
    yesno "Update to latest version"
    INSTALL=false
else
    yesno "Will install kcapp into \e[34m$INSTALL_DIRECTORY\e[39m"
    printf "Creating directory '$INSTALL_DIRECTORY'"
    mkdir $INSTALL_DIRECTORY
    print_result
fi


# ===================================
# Database
# ===================================
echo -e "\n  _____  ____  \n |  __ \|  _ \ \n | |  | | |_) |\n | |  | |  _ < \n | |__| | |_) |\n |_____/|____/ \n"
if [ "$INSTALL" = true ] ; then
    git_clone "https://github.com/kcapp/database" $INSTALL_DIRECTORY/database
    cd $INSTALL_DIRECTORY/database
    echo "Starting database..."
    docker-compose --log-level CRITICAL up -d
    exit_code "docker-compose"

    # Wait for database to start
    sleep 10

    # Run migrations
    echo "Running database migrations"
    cd $INSTALL_DIRECTORY/database/migrations/
    goose mysql "kcapp:abcd1234@tcp(localhost:3366)/kcapp?parseTime=true" up

    # Insert some required data
    mysqlsh -u kcapp -pabcd1234 localhost:3366/kcapp --sql << EOF
    INSERT INTO office(id, \`name\`, is_active) VALUES (1, 'Test', 1);
EOF

else
    git_pull $INSTALL_DIRECTORY/database
    db_change=$(echo $?)
    if [ "$db_change" == 0 ] ; then
        echo "Running database migrations"
        cd $INSTALL_DIRECTORY/database/migrations/
        goose mysql "kcapp:abcd1234@tcp(localhost:3366)/kcapp?parseTime=true" up
    fi
fi


# ===================================
# API
# ===================================
echo -e "\n           _____ _____ \n     /\   |  __ \_   _|\n    /  \  | |__) || |  \n   / /\ \ |  ___/ | |  \n  / ____ \| |    _| |_ \n /_/    \_\_|   |_____|\n"
if [ "$INSTALL" = true ] ; then
    git_clone "https://github.com/kcapp/api" $INSTALL_DIRECTORY/api
    cd $INSTALL_DIRECTORY/api
    echo "Installing API dependencies"
    eval "go get ./... > /dev/null 2>&1"
else
    git_pull $INSTALL_DIRECTORY/api
    api_change=$(echo $?)
    if [ "$api_change" == 0 ] ; then
        cd $INSTALL_DIRECTORY/api
        echo "Installing all dependencies"
        eval "go get ./... > /dev/null 2>&1"
    fi
fi


# ===================================
# Frontend
# ===================================
echo -e "\n  ______ _____   ____  _   _ _______ ______ _   _ _____  \n |  ____|  __ \ / __ \| \ | |__   __|  ____| \ | |  __ \ \n | |__  | |__) | |  | |  \| |  | |  | |__  |  \| | |  | |\n |  __| |  _  /| |  | | . \` |  | |  |  __| | . \` | |  | |\n | |    | | \ \| |__| | |\  |  | |  | |____| |\  | |__| |\n |_|    |_|  \_\\\\\\____/|_| \_|  |_|  |______|_| \_|_____/ \n"
if [ "$INSTALL" = true ] ; then
    git_clone "https://github.com/kcapp/frontend" $INSTALL_DIRECTORY/frontend
    cd $INSTALL_DIRECTORY/frontend
    echo "Installing Frontend dependencies"
    npm install --silent --no-audit
    mkdir log
    echo -e "\n\nkcapp successfully installed in $INSTALL_DIRECTORY!"
else
    git_pull $INSTALL_DIRECTORY/frontend
    frontend_change=$(echo $?)
    if [ "$frontend_change" == 0 ] ; then
        echo -e
        cd $INSTALL_DIRECTORY/frontend
        echo "Installing all dependencies"
        npm install --silent --no-audit
    fi
fi


# ===================================
# Finalize
# ===================================
if [ "$INSTALL" = true ] ; then
    echo -e "Creating startup script for API '\e[34m$INSTALL_DIRECTORY/kcapp-api\e[39m'"
    cat << EOF > $INSTALL_DIRECTORY/kcapp-api
    #!/bin/bash
    cd $INSTALL_DIRECTORY/api
    go run kcapp-api.go
EOF
    chmod 0755 $INSTALL_DIRECTORY/kcapp-api

    echo -e "Creating startup script for Frontend '\e[34m$INSTALL_DIRECTORY/kcapp-frontend\e[39m'"
    cat << EOF > $INSTALL_DIRECTORY/kcapp-frontend
    #!/bin/bash
    cd $INSTALL_DIRECTORY/frontend
    DEBUG=kcapp:* npm start
EOF
    chmod 0755 $INSTALL_DIRECTORY/kcapp-frontend
fi

# Start API and Frontend
yesno "\nStart API and Frontend"

# First kill old process if it exists
CURRENT_SID=`ps -efj | grep 'kcapp-frontend' | grep -v grep | awk '{print $5}'`
kill $(ps -s $CURRENT_SID -o pid=)
$INSTALL_DIRECTORY/kcapp-api &
$INSTALL_DIRECTORY/kcapp-frontend &