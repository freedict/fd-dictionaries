#!/bin/sh
#vim:set expandtab sts=4 ts=4 sw=4:
# This script updates the dictd database and restarts dictd. It'll also try to
# figure out whether dictd is installed in the first place and what the correct
# way of restart is (upstart / systemd /init).
set -e

isDictInstalled() {
    if test -f /usr/sbin/dictd || command -v dictd > /dev/null || [ -f /sbin/dictd ]
    then
        return 0
    else
        echo "The dictd server hasn't been found on this system."
        if command -v apt-get > /dev/null
        then
            echo 'Type `apt-get install dictd` before re-executing this script.'
        elif command -v pacman > /dev/null
        then
            echo 'Type `pacman -Syu dictd` before re-executing this script.'
        elif command -v yum > /dev/null
        then
            echo 'Type `yum install dictd` before re-executing this script.'
        else
            echo "Please install the dictd server before proceeding."
        fi
        exit 20
    fi
}


restart_dictd_server() {
    echo "Restarting dictd..."
    if command -v service > /dev/null
    then
        service dictd restart
    elif command -v systemctl > /dev/null
    then
        systemctl restart dictd
    elif test -f /etc/init.d/dictd
    then
        /etc/init.d/dictd restart stop
        /etc/init.d/dictd restart start
    fi
}

update_dictd_database() {
    dictdconfig -w
}


################################################################################

# abort if dictd is not installed
isDictInstalled

update_dictd_database
restart_dictd_server
exit 0;

