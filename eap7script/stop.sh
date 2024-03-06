#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. $BASEDIR/env.sh


PID=`ps -ef | grep java | grep "SERVER=$SERVER_NAME " | awk '{print $2}'`

echo "JBOSS ( $SERVER_NAME ) PROCESS : $PID "

if [[ e$PID == "e" ]]
then
    echo "JBoss SERVER - $SERVER_NAME is Not RUNNING..."
    exit;
fi

$JBOSS_HOME/bin/jboss-cli.sh --connect --controller=$CONTROLLER_IP:$CONTROLLER_PORT --command=:shutdown

