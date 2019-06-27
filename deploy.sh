#!/bin/bash

API_SERVICE=kcapp-api
API_DIRECTORY=/home/thord/go/src/github.com/kcapp/api/
FRONTEND_SERVICE=kcapp-frontend
FRONTEND_DIRECTORY=/home/thord/Development/kcapp/frontend/

print_result() {
	EXIT_CODE=$(echo $?)
	if [ "$EXIT_CODE" == "0" ] ; then
	    echo -e " - \e[32mDONE\e[39m"
	else
	    echo -e " - \e[91mFAILED\e[39m"
	    # TODO Mark deploy as failed, and log out in print_done + exit code
	fi
}

print_done() {
	echo -e
	echo -ne "===================================="
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
	    echo -e "- \e[32mDONE\e[39m"
	    return 0
	fi
}

# Update API
echo -e "Updating API"
git_pull $API_DIRECTORY
api_change=$(echo $?)
if [ "$api_change" == 0 ] ; then
	printf "Building API %-23s"
	go build
	print_result
	# TODO Fix this, cannot copy this unless service is stopped
	cp api kcapp-api
fi


# Update Frontend
echo -e
echo -e "Updating Frontend"
git_pull $FRONTEND_DIRECTORY
frontend_change=$(echo $?)
if [ "$frontend_change" == 0 ] ; then
	echo -e
	cd $FRONTEND_DIRECTORY
	# TODO Check if package.json has changed
	echo "Installing all frontend dependencies"
	npm install -s
fi

if [ "$api_change" == 1 ] && [ "$frontend_change" == 1 ] ; then
	echo -e
	echo "Everything is up to date!"
	print_done
	exit 0
fi

echo -e

# Restart services
printf "Restarting '$FRONTEND_SERVICE' service "
sudo service $FRONTEND_SERVICE restart >/dev/null 2>&1
print_result

printf "Restarting '$API_SERVICE' service %-5s"
sudo service $API_SERVICE restart >/dev/null 2>&1
print_result

echo -e

# Pre-request all pages, to compile the template files
printf "Waiting for frontend to start ... %-2s"
sleep 7
print_result
echo -e

echo "Compiling all pages"
declare -a PAGES=("/"
	"/players"
	"/statistics/weekly"
	"/tournaments"
	"/tournaments/1"
	"/elo"
	"/matches/1/result"
	"/legs/1"
	"/legs/1/result"
	"/matches/page/1")

for PAGE in "${PAGES[@]}"; do
	printf "Requesting %-25s" $PAGE
	curl -s "http://localhost:3000$PAGE" > /dev/null
    print_result
done

print_done
