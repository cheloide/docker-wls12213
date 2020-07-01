#!/bin/bash

IS_NODE_SERVER=${IS_NODE_SERVER:false}

if [ $IS_NODE_SERVER == true ]; then
    ~/start-node-server.sh
else
    ~/start-admin-server.sh
fi