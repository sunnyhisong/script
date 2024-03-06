#!/bin/sh

. /JBOSS/jboss-fsw/bin/env.sh

# ------------------------------------
PID=`ps -ef | grep java | grep "server=$SERVER_NAME " | awk '{print $2}'`

if [ e$PID != "e" ]
then
    echo "JBOSS FWS($SERVER_NAME) is already RUNNING..."
    exit;
fi


# ------------------------------------
UNAME=`id -u -n`
if [ e$UNAME != "e$SERVER_USER" ]
then
    echo "$SERVER_USER USER to start JBoss SERVER - $SERVER_NAME..."
    exit;
fi
# ------------------------------------

nohup $JBOSS_HOME/bin/standalone.sh > /dev/null 2>&1 &

#sleep 3
#tail -f $JBOSS_HOME/standalone/log/server.log
