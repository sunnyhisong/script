#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. $BASEDIR/env.sh


DATE=`date +%Y%m%d%H%M%S`
PID=`ps -ef | grep java | grep "=$SERVER_NAME " | awk '{print $2}'`
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
   
echo  $JAVA_OPTS
   
if [ ! -d "$LOG_HOME/nohup" ];
then
    mkdir -p $LOG_HOME/nohup
fi
  
if [ ! -d "$LOG_HOME/gclog" ];
then
    mkdir -p $LOG_HOME/gclog
fi
   
if [ -f $LOG_HOME/nohup/$SERVER_NAME.out ]
then
    mv $LOG_HOME/nohup/$SERVER_NAME.out $LOG_HOME/nohup/$SERVER_NAME.out.$DATE
fi

   
nohup $JBOSS_HOME/bin/standalone.sh -DSERVER=$SERVER_NAME -c $CONFIG_FILE >> $LOG_HOME/nohup/$SERVER_NAME.out  2>&1 &
#nohup $JBOSS_HOME/bin/standalone.sh -DSERVER=$SERVER_NAME -P=$DOMAIN_BASE/$SERVER_NAME/bin/env.properties -c $CONFIG_FILE >> $LOG_HOME/nohup/$SERVER_NAME.out  2>&1 &

#find ${LOG_HOME} -type f | xargs chmod 640

#if [ e$1 = "enotail" ]
#then
#    echo "Starting... $SERVER_NAME"
#    exit;
#fi

