#!/bin/sh
. ./env.sh
tail -f $LOG_HOME/server.log

echo ${jboss_home}
echo ${server_name}

