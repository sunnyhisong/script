#!/bin/sh

DATE=`date +%Y%m%d%H%M%S`

. ./env.sh

PID=`ps -ef | grep java | grep "=$SERVER_NAME " | grep "Host Controller" | awk '{print $2}'`
echo $PID

if [ e$PID != "e" ]
then
    echo "JBoss SERVER - $SERVER_NAME is already RUNNING..."
    exit;
fi

UNAME=`id -u -n`
if [ e$UNAME != "e$JBOSS_USER" ]
then
    echo "Use $JBOSS_USER account to start JBoss SERVER - $SERVER_NAME..."
    exit;
fi


if [ ! -d "$LOG_HOME/gclog" ];
then
    mkdir "$LOG_HOME/gclog" 
fi  

if [ ! -d "$LOG_HOME/nohup" ];
then
    mkdir "$LOG_HOME/nohup" 
fi  

mv $LOG_HOME/nohup/$SERVER_NAME.out $LOG_HOME/nohup/$SERVER_NAME.out.$DATE

nohup $JBOSS_HOME/bin/domain.sh -DSERVER=$SERVER_NAME  -b $BIND_ADDR --backup >> $LOG_HOME/nohup/$SERVER_NAME.out 2>&1 &
#nohup $JBOSS_HOME/bin/domain.sh -DSERVER=$SERVER_NAME -P=$DOMAIN_BASE/$SERVER_NAME/bin/env.properties -b 0.0.0.0 --backup >> $LOG_HOME/nohup/$SERVER_NAME.out &
#nohup $JBOSS_HOME/bin/domain.sh -DSERVER=$SERVER_NAME -P=$DOMAIN_BASE/$SERVER_NAME/bin/env.properties -b 0.0.0.0 --cached-dc >> $LOG_HOME/nohup/$SERVER_NAME.out &

#$DOMAIN_BASE/$SERVER_NAME/bin/tail.sh
