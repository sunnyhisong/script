#!/bin/sh
. ./env.sh
tail -f $LOG_HOME/server.log

echo ${RHDG_HOME}
echo ${SERVER_NAME}
