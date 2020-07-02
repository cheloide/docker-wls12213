#!/bin/bash


# _term() { 
#   kill -TERM "$child" 2>/dev/null
# }
# trap _term SIGTERM

# IS_NODE_SERVER=${IS_NODE_SERVER:false}

# if [ $IS_NODE_SERVER == true ]; then
#     ~/start-node-server.sh &
#     CHILD=$!
# else
#     ~/start-admin-server.sh &
#     CHILD=$!
# fi

# wait "$CHILD"


# #set up admin server

function first_start_admin {
    echo "Setting up First Run."

    . $ORACLE_HOME/wlserver/server/bin/setWLSEnv.sh
    java weblogic.WLST ~/adminserver.py

    mkdir -p $DOMAIN_PATH/nodemanager
    echo SecureListener=false >> $DOMAIN_PATH/nodemanager/nodemanager.properties

    touch ~/.done   
}

function first_start_node {
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

function wait_for_admin_server {
    echo "Waiting for Admin Server"
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://wls-admin:7001/console)
    while [ "$STATUS" != "200" ];
    do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://wls-admin:7001/console)
        sleep 5
    done;
}

function start_wls_admin() {
    $DOMAIN_PATH/bin/startWebLogic.sh &
    WEBLOGIC_PID=$!
}

function stop_wls_admin() {
    echo "SIGTERM Detected, stopping Weblogic Server"
    kill -TERM "$SSHD_PID" 2>/dev/null
    $DOMAIN_PATH/bin/stopWebLogic.sh
}

function start_wls_node {
    $DOMAIN_PATH/bin/startNodeManager.sh &
    WEBLOGIC_PID=$!
}

function stop_wls_node {
    echo "SIGTERM Detected, stopping NodeManager"
    $DOMAIN_PATH/bin/stopNodeManager.sh
    exit 0
}

if [ $IS_NODE_SERVER == true ]; then

    BASE_DOMAIN="$ORACLE_HOME/wlserver/user_projects/domains"
    ORACLE_HOME='/u01/oracle'
    DOMAIN_NAME="domain"
    DOMAIN_PATH="$ORACLE_HOME/wlserver/user_projects/domains/$DOMAIN_NAME"

    wait_for_admin_server
    test ! -e ~/.done && first_start_node
    trap 'stop_wls_node' SIGTERM
    start_wls_node
else
    /usr/sbin/sshd -p 2222 &
    SSHD_PID=$!

    ORACLE_HOME='/u01/oracle'
    DOMAIN_PATH="$ORACLE_HOME/wlserver/user_projects/domains/domain"

    test ! -e ~/.done && first_start_admin
    trap 'stop_wls_node' SIGTERM
    start_wls_admin
fi

wait "$WEBLOGIC_PID"