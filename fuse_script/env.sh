#!/bin/sh

DATE=`date +%Y%m%d%H%M%S`
JBOSS_HOME=/JBOSS/jboss-fsw/jboss-eap-6.1/
LOG_HOME=$JBOSS_HOME/standalone/log

SERVER_NAME="traxonFSW1"
SERVER_USER="traxon01"
BIND_ADDR="203.251.151.75"

if [ "x$JBOSS_MODULES_SYSTEM_PKGS" = "x" ]; then
   JBOSS_MODULES_SYSTEM_PKGS="org.jboss.byteman"
fi

JAVA_OPTS="-server -Dserver=$SERVER_NAME "
JAVA_OPTS="$JAVA_OPTS -Xms1303m "
JAVA_OPTS="$JAVA_OPTS -Xmx1303m "
JAVA_OPTS="$JAVA_OPTS -XX:PermSize=256m " 
JAVA_OPTS="$JAVA_OPTS -XX:MaxPermSize=256m "
JAVA_OPTS="$JAVA_OPTS -Djava.net.preferIPv4Stack=true"

JAVA_OPTS="$JAVA_OPTS -verbose:gc"
JAVA_OPTS="$JAVA_OPTS -Xloggc:$LOG_HOME/${SERVER_NAME}_gc.log"
JAVA_OPTS="$JAVA_OPTS -XX:+PrintGCDetails"
JAVA_OPTS="$JAVA_OPTS -XX:+PrintGCTimeStamps"
JAVA_OPTS="$JAVA_OPTS -XX:+PrintHeapAtGC"
JAVA_OPTS="$JAVA_OPTS -XX:+HeapDumpOnOutOfMemoryError"
JAVA_OPTS="$JAVA_OPTS -XX:HeapDumpPath=$LOG_HOME/logs/${SERVER_NAME}_java_pid_$DATA.hprof"

JAVA_OPTS="$JAVA_OPTS -Djboss.modules.system.pkgs=$JBOSS_MODULES_SYSTEM_PKGS -Djava.awt.headless=true"

JAVA_OPTS="$JAVA_OPTS -Djboss.bind.address.management=$BIND_ADDR"
JAVA_OPTS="$JAVA_OPTS -Djboss.bind.address=$BIND_ADDR"

export JBOSS_HOME JAVA_OPTS
