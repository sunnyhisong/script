#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. $BASEDIR/env.sh


PID=`ps -ef | grep java | grep "SERVER=$SERVER_NAME " | awk '{print $2}'`

echo "JDG ( $SERVER_NAME ) PROCESS : $PID "

if [[ e$PID == "e" ]]
then
    echo "JDG SERVER - $SERVER_NAME is Not RUNNING..."
    exit;
fi

#$JBOSS_HOME/bin/jboss-cli.sh --connect --controller=$CONTROLLER_IP:$CONTROLLER_PORT --command=:shutdown
$RHDG_HOME/bin/cli.sh -c $BIND_ADDR:$BIND_PORT admin rpjboss1! --command=:shutdown server $SERVER_NAME 
#$RHDG_HOME/bin/shutdown cluster
