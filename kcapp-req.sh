#!/bin/bash

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

echo "Compiling all pages"
declare -a PAGES=("/"
        "/players"
        "/players/1/statistics"
        "/statistics/weekly"
        "/tournaments"
        "/tournaments/1"
        "/elo"
        "/offices"
        "tournaments/admin"
        "/matches/1/result"
        "/legs/1"
        "/legs/1/result"
        "/matches/page/1"
        "/tournaments/1/player/1"
        "/tournaments/admin"
        "/players/compare"
        "/controller")

for PAGE in "${PAGES[@]}"; do
        printf "Requesting %-25s" $PAGE
        curl -s "http://localhost:3000$PAGE" > /dev/null
    print_result
done

print_done
