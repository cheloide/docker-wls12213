#!/bin/bash

BASE_DOMAIN="$ORACLE_HOME/wlserver/user_projects/domains"
ORACLE_HOME='/u01/oracle'
DOMAIN_NAME="domain"
DOMAIN_PATH="$ORACLE_HOME/wlserver/user_projects/domains/$DOMAIN_NAME"

function wait_for_admin_server {
    echo "Waiting for Admin Server"
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://wls-admin:7001/console)
    while [ "$STATUS" != "200" ];
    do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://wls-admin:7001/console)
        sleep 5
    done;
}

function firstStart {
    echo "Setting up First Run."

    . $ORACLE_HOME/wlserver/server/bin/setWLSEnv.sh
    java weblogic.WLST ~/nodeserver.py

    echo ListenPort=$NODE_MANAGER_PORT >> $DOMAIN_PATH/nodemanager/nodemanager.properties

    ssh  -p 2222 -o StrictHostKeyChecking=no oracle@wls-admin "$ORACLE_HOME/oracle_common/common/bin/pack.sh -managed=true -domain=$DOMAIN_PATH -template=domain.jar -template_name='$DOMAIN_NAME'"
    scp -P 2222 oracle@wls-admin:$ORACLE_HOME/domain.jar $ORACLE_HOME/

    bash -c "$ORACLE_HOME/oracle_common/common/bin/unpack.sh -template=$ORACLE_HOME/domain.jar  -domain=$DOMAIN_PATH"

    ln -s /properties/cl cl -t $DOMAIN_PATH

    touch ~/.done
}

function startWLS {
    $DOMAIN_PATH/bin/startNodeManager.sh &
    # $DOMAIN_PATH/bin/startManagedWebLogic.sh $NODE_NAME http://wls-admin:7001 &
}

function stopWLS {
    $DOMAIN_PATH/bin/stopNodeManager.sh
    # $DOMAIN_PATH/bin/stopManagedWebLogic.sh $NODE_NAME http://wls-admin:7001
    exit 0
}

wait_for_admin_server

test ! -e ~/.done && firstStart

trap 'stopWLS' SIGTERM
startWLS


while true; do :; done