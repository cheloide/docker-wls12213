#!/bin/bash

/usr/sbin/sshd -p 2222 &

ORACLE_HOME='/u01/oracle'
DOMAIN_PATH="$ORACLE_HOME/wlserver/user_projects/domains/domain"

# #set up admin server


function firstStart {
    echo "Setting up First Run."

    . $ORACLE_HOME/wlserver/server/bin/setWLSEnv.sh
    java weblogic.WLST ~/adminserver.py

    mkdir -p $DOMAIN_PATH/nodemanager
    echo SecureListener=false >> $DOMAIN_PATH/nodemanager/nodemanager.properties

    touch ~/.done   
}

function startWLS() {
    $DOMAIN_PATH/bin/startWebLogic.sh &
}

function stopWLS() {
    echo "SIGTERM Detected, stopping Weblogic Server"
    $DOMAIN_PATH/bin/stopWebLogic.sh
    exit 0
}


test ! -e ~/.done && firstStart

trap 'stopWLS' SIGTERM
startWLS

while true; do :; done