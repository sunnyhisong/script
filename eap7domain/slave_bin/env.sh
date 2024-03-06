#!/bin/sh
###### JBOSS EAP 7.x ######
###### SLAVE env.sh  ######

DATE=`date +%Y%m%d_%H%M%S`

##### JBOSS Directory Setup #####
#export JAVA_HOME=/WAS/JAVA/jdk1.8.0_144
export JBOSS_HOME=/was/jboss/domainmode/jboss-eap-7.4
export DOMAIN_BASE=/was/jboss/domainmode
export SERVER_NAME=slave11
export LOG_HOME=$DOMAIN_BASE/$SERVER_NAME/log

if [ ! -d $LOG_HOME ];
then
    mkdir $LOG_HOME
fi

export DOMAIN_BASE_DIR=$DOMAIN_BASE/$SERVER_NAME

##### Configration File #####
#export DOMAIN_CONFIG_FILE=domain.xml
export HOST_CONFIG_FILE=host-slave.xml

export HOST_NAME=$SERVER_NAME

export JBOSS_USER=was

##### Bind Address #####
export BIND_ADDR=10.65.40.70

export MGMT_ADDR=${BIND_ADDR}
export DOMAIN_MASTER_ADDR=10.65.40.70
export DOMAIN_MASTER_PORT=9990

export HOST_CONTROLLER_PORT=19990

export LAUNCH_JBOSS_IN_BACKGROUND=true

##### JBoss System module and User module directory #####
export JBOSS_MODULEPATH=$JBOSS_HOME/modules:$JBOSS_HOME/modules.ext

# JVM Options : Server
export JAVA_OPTS="-server $JAVA_OPTS"

# JVM Options : Memory 
export JAVA_OPTS="$JAVA_OPTS -Xms256m"
export JAVA_OPTS="$JAVA_OPTS -Xmx256m"
export JAVA_OPTS=" $JAVA_OPTS -XX:MetaspaceSize=256m"
export JAVA_OPTS=" $JAVA_OPTS -XX:MaxMetaspaceSize=256m"
#export JAVA_OPTS=" $JAVA_OPTS -Xss256k"

#export JAVA_OPTS=" $JAVA_OPTS -XX:+UseParallelOldGC "
#export JAVA_OPTS=" $JAVA_OPTS -XX:+UseParallelGC "
#export JAVA_OPTS=" $JAVA_OPTS -XX:+UseConcMarkSweepGC "
export JAVA_OPTS=" $JAVA_OPTS -XX:+UseG1GC -XX:MaxGCPauseMillis=1000 "


export JAVA_OPTS=" $JAVA_OPTS -verbose:gc"


### GC OPTIONS JAVA11###
#export JAVA_OPTS=" $JAVA_OPTS -Xlog:gc*,gc+heap=trace:$LOG_HOME/gclog/gc_$DATE.log:time"


### GC OPTIONS JAVA8###
export JAVA_OPTS=" $JAVA_OPTS -XX:+PrintGCTimeStamps "
export JAVA_OPTS=" $JAVA_OPTS -XX:+PrintGCDetails "
export JAVA_OPTS=" $JAVA_OPTS -XX:+PrintHeapAtGC"
export JAVA_OPTS=" $JAVA_OPTS -Xloggc:$LOG_HOME/gclog/gc_$DATE.log "

export JAVA_OPTS=" $JAVA_OPTS -XX:+DisableExplicitGC "
export JAVA_OPTS=" $JAVA_OPTS -XX:+HeapDumpOnOutOfMemoryError "
export JAVA_OPTS=" $JAVA_OPTS -XX:HeapDumpPath=$LOG_HOME/gclog/${SERVER_NAME}_java_pid_${DATE}.hprof"
export JAVA_OPTS=" $JAVA_OPTS -XX:+ExplicitGCInvokesConcurrent "
export JAVA_OPTS=" $JAVA_OPTS -Djava.net.preferIPv4Stack=true"
export JAVA_OPTS=" $JAVA_OPTS -Dorg.jboss.resolver.warning=true"
export JAVA_OPTS=" $JAVA_OPTS -Djboss.modules.system.pkgs=org.jboss.byteman"
export JAVA_OPTS=" $JAVA_OPTS -Djava.awt.headless=true"


#for darwin
export JBOSS_BASE_DIR="$DOMAIN_BASE_DIR"

export JAVA_OPTS="$JAVA_OPTS -DDATE=$DATE"
export JAVA_OPTS="$JAVA_OPTS -Djboss.host.default.config=$HOST_CONFIG_FILE"
export JAVA_OPTS="$JAVA_OPTS -Djboss.domain.base.dir=$DOMAIN_BASE_DIR"
export JAVA_OPTS="$JAVA_OPTS -Djboss.domain.master.address=$DOMAIN_MASTER_ADDR"
export JAVA_OPTS="$JAVA_OPTS -Djboss.bind.address.management=$MGMT_ADDR"
export JAVA_OPTS="$JAVA_OPTS -Djboss.bind.address=$BIND_ADDR"
export JAVA_OPTS="$JAVA_OPTS -Djboss.domain.master.port=$DOMAIN_MASTER_PORT"
export JAVA_OPTS="$JAVA_OPTS -Djboss.management.http.port=$HOST_CONTROLLER_PORT"
export JAVA_OPTS="$JAVA_OPTS -Djboss.host.name=$SERVER_NAME"

export JAVA_OPTS=" $JAVA_OPTS -Djboss.domain.log.dir=$LOG_HOME"

# jgroups setting
#export JAVA_OPTS=" $JAVA_OPTS -Djboss.bind.address.private=$BIND_ADDR"

# servers log directory
export JAVA_OPTS=" $JAVA_OPTS -Djboss.server.log.dir=$LOG_HOME"

echo "================================================"
echo "JBOSS_HOME=$JBOSS_HOME"
echo "DOMAIN_BASE=$DOMAIN_BASE"
echo "SERVER_NAME=$SERVER_NAME"
#echo "DOMAIN_CONFIG_FILE=$DOMAIN_CONFIG_FILE"
echo "HOST_CONFIG_FILE=$HOST_CONFIG_FILE"
echo "DOMAIN_CONTROLLER=$DOMAIN_MASTER_ADDR:$DOMAIN_MASTER_PORT"
echo "================================================"
