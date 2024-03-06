#!/bin/sh
##################################
# JBoss DataGrid 8.x  Script Ver 0.1 #
##################################

DATE=`date +%Y%m%d_%H%M%S`

#export JAVA_HOME=/RPIMDG/JAVA/java-11.0.22
export RHDG_HOME=/RPWAS/JDG/engine/infinispan-server-14.0.22.Final
export DOMAIN_BASE=/RPWAS/JDG/idomains
export SERVER_NAME=testSvr11
export LOG_HOME=${DOMAIN_BASE}/${SERVER_NAME}/log


##### Configration File #####
export CONFIG_FILE=infinispan-ha.xml
export NODE_NAME=$SERVER_NAME
export PORT_OFFSET=0

##### JDG USER #####
export JDG_USER=jboss

##### Bind Address #####
export BIND_ADDR=10.65.40.153
export BIND_PORT=11222
let CMD_PORT=11222+$PORT_OFFSET
export CMD_PORT

##### RHDG System module and User module directory #####
export RHDG_MODULEPATH=${DOMAIN_BASE}/${SERVER_NAME}/lib

# JVM Options : Server
export JAVA_OPTS="-server $JAVA_OPTS"

# JVM Options : Memory
export JAVA_OPTS=" $JAVA_OPTS -Xmx1024m"
export JAVA_OPTS=" $JAVA_OPTS -Xms1024m"
export JAVA_OPTS=" $JAVA_OPTS -XX:MetaspaceSize=256m"
export JAVA_OPTS=" $JAVA_OPTS -XX:MaxMetaspaceSize=256m"
export JAVA_OPTS=" $JAVA_OPTS -Xss256k"

#java 11
export JAVA_OPTS=" $JAVA_OPTS -XX:+UseG1GC -XX:MaxGCPauseMillis=1000 "

export JAVA_OPTS=" $JAVA_OPTS -verbose:gc"

### GC OPTIONS JAVA 11 && 17###
export JAVA_OPTS=" $JAVA_OPTS -Xlog:gc*,gc+heap=trace:$LOG_HOME/gclog/gc_$DATE.log:time"


### GC OPTIONS JAVA8###
#export JAVA_OPTS=" $JAVA_OPTS -XX:+PrintGCTimeStamps "
#export JAVA_OPTS=" $JAVA_OPTS -XX:+PrintGCDetails "
#export JAVA_OPTS=" $JAVA_OPTS -XX:+PrintHeapAtGC"
#export JAVA_OPTS=" $JAVA_OPTS -Xloggc:$ISPN_LOG_DIR/gclog/gc_$DATE.log "

#export JAVA_OPTS=" $JAVA_OPTS -XX:+DisableExplicitGC "
export JAVA_OPTS=" $JAVA_OPTS -XX:+HeapDumpOnOutOfMemoryError "
export JAVA_OPTS=" $JAVA_OPTS -XX:HeapDumpPath=$LOG_HOME/gclog/${SERVER_NAME}_java_pid_${DATE}.hprof"
#export JAVA_OPTS=" $JAVA_OPTS -XX:+ExplicitGCInvokesConcurrent "

#export   JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote"
#export   JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.port=8086" 
#export   JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.ssl=false" 
#export   JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.authenticate=false"

export JAVA_OPTS=" $JAVA_OPTS -Dinfinispan.bind.address=$BIND_ADDR"
export JAVA_OPTS=" $JAVA_OPTS -Dinfinispan.bind.port=$BIND_PORT"
export JAVA_OPTS=" $JAVA_OPTS -Dinfinispan.socket.binding.port-offset=$PORT_OFFSET"
export JAVA_OPTS=" $JAVA_OPTS -Dsys:infinispan.server.log.path=$LOG_HOME"
export JAVA_OPTS=" $JAVA_OPTS -Dinfinispan.node.name=$NODE_NAME"


#export JAVA_OPTS=" $JAVA_OPTS -Dinfinispan.cluster.stack=tcp"
#export JAVA_OPTS=" $JAVA_OPTS -Djgroups.bind.address=$BIND_ADDR"
#export JAVA_OPTS=" $JAVA_OPTS -Djgroups.bind.port=7800"

echo "================================================"
echo "RHDG_HOME=$RHDG_HOME"
echo "DOMAIN_BASE=$DOMAIN_BASE"
echo "SERVER_NAME=$SERVER_NAME"
echo "CONFIG_FILE=$CONFIG_FILE"
echo "BIND_ADDR=$BIND_ADDR"
echo "CMD_PORT=$CMD_PORT"
echo "PORT_OFFSET=$PORT_OFFSET"
echo "================================================"
