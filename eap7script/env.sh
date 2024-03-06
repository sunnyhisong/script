#!/bin/sh
##################################
# JBoss EAP 7.4.x Script Ver 0.1 #
##################################

DATE=`date +%Y%m%d_%H%M%S`

#export JAVA_HOME=/was/java/java-11-openjdk
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
export JBOSS_VERSION=jboss-eap-7.4
export JBOSS_HOME=/was/jboss/jboss74/${JBOSS_VERSION}
export DOMAIN_BASE=/was/jboss/jboss74/domains
export SERVER_NAME=node11
export LOG_HOME=${DOMAIN_BASE}/${SERVER_NAME}/logs
export ACCESS_LOG_HOME=$LOG_HOME/access-log/


##### Configration File #####
export CONFIG_FILE=standalone-ha.xml
export NODE_NAME=$SERVER_NAME
export PORT_OFFSET=0
   
##### JBOSS USER #####
export JBOSS_USER=was

##### Bind Address #####
export BIND_ADDR=10.65.40.70
#export JGROUPS_BIND_ADDR=192.168.56.215
#export MULTICAST_ADDR=230.1.0.1
#export MULTICAST_PORT=55200
#export JMS_MULTICAST_ADDR=230.2.0.1
#export MODCLUSTER_MULTICAST_ADDR=224.1.1.115
#export MGMT_ADDR=127.0.0.1                               # admin console binding
export MGMT_ADDR=$BIND_ADDR
export CONTROLLER_IP=$MGMT_ADDR
let CONTROLLER_PORT=9990+$PORT_OFFSET
export CONTROLLER_PORT
export LAUNCH_JBOSS_IN_BACKGROUND=true
   
##### JBoss System module and User module directory #####
export JBOSS_MODULEPATH=$JBOSS_HOME/modules:$JBOSS_HOME/modules.ext:${JBOSS_HOME}/lib
# JVM Options : Server
export JAVA_OPTS="-server $JAVA_OPTS"
   
# JVM Options : Memory
export JAVA_OPTS=" $JAVA_OPTS -Xmx1024m"
export JAVA_OPTS=" $JAVA_OPTS -Xms1024m"
export JAVA_OPTS=" $JAVA_OPTS -XX:MetaspaceSize=256m"
export JAVA_OPTS=" $JAVA_OPTS -XX:MaxMetaspaceSize=256m"
export JAVA_OPTS=" $JAVA_OPTS -Xss256k"

#java 1.7
#export JAVA_OPTS=" $JAVA_OPTS -XX:+UseParallelOldGC "
#export JAVA_OPTS=" $JAVA_OPTS -XX:+UseParallelGC "

#java 11
export JAVA_OPTS=" $JAVA_OPTS -XX:+UseG1GC -XX:MaxGCPauseMillis=1000 "

#java 17
#export JAVA_OPTS=" $JAVA_OPTS -XX:+UseZGC"


export JAVA_OPTS=" $JAVA_OPTS -verbose:gc"


### GC OPTIONS JAVA 11 && 17###
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
   
#export   JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote"
#export   JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.port=8086" 
#export   JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.ssl=false" 
#export   JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.authenticate=false"

export JAVA_OPTS=" $JAVA_OPTS -Djboss.node.name=$NODE_NAME"
export JAVA_OPTS=" $JAVA_OPTS -Djboss.server.base.dir=$DOMAIN_BASE/$SERVER_NAME"
export JAVA_OPTS=" $JAVA_OPTS -Djboss.server.log.dir=$LOG_HOME"
export JAVA_OPTS=" $JAVA_OPTS -Djboss.socket.binding.port-offset=$PORT_OFFSET"
export JAVA_OPTS=" $JAVA_OPTS -Djboss.bind.address.management=$MGMT_ADDR"
export JAVA_OPTS=" $JAVA_OPTS -Djboss.bind.address=$BIND_ADDR"
export JAVA_OPTS=" $JAVA_OPTS -Djboss.bind_addr=$BIND_ADDR"
export JAVA_OPTS=" $JAVA_OPTS -Dserver.mode=local"


#### Jboss Full XML ####
#export JAVA_OPTS=" $JAVA_OPTS -Djboss.bind.address.unsecure=${BIND_ADDR}"


#### Mod_Cluster ####
#export JAVA_OPTS=" $JAVA_OPTS -Djboss.modcluster.multicast.address=$MODCLUSTER_MULTICAST_ADDR"
#export JAVA_OPTS=" $JAVA_OPTS -Dbalancer=balancer_my"
#export JAVA_OPTS=" $JAVA_OPTS -DbalancerGroup=G_my"


# jboss eap 7.x cluster setting
#CLUSTER_MAMBER_IP=("10.65.40.70" "10.65.40.70")
#CLUSTER_MAMBER_PORT=("7600" "7700")
#CLUSTER_MEMBER_COUNT=${#CLUSTER_MAMBER_IP[*]}
#
#if [ -n "$CLUSTER_MAMBER_IP" ]; then
#	export JAVA_OPTS=" $JAVA_OPTS -Djboss.bind.address.private=${BIND_ADDR}"
#	for (( count=0; count<$CLUSTER_MEMBER_COUNT; count++))
#	do
#
#        export JAVA_OPTS=" $JAVA_OPTS -Djgroups.host$((count+1)).address=${CLUSTER_MAMBER_IP[$count]}"
#        export JAVA_OPTS=" $JAVA_OPTS -Djgroups.host$((count+1)).port=${CLUSTER_MAMBER_PORT[$count]}"
#	done
#fi


# 7.x
export JAVA_OPTS=" $JAVA_OPTS -Djgroups.host1.address=10.65.40.70"
export JAVA_OPTS=" $JAVA_OPTS -Djgroups.host1.port=7600"
export JAVA_OPTS=" $JAVA_OPTS -Djgroups.host2.address=10.65.40.70"
export JAVA_OPTS=" $JAVA_OPTS -Djgroups.host2.port=7700"
export JAVA_OPTS=" $JAVA_OPTS -Djboss.bind.address.private=${BIND_ADDR}"
   
echo "================================================"
echo "JBOSS_HOME=$JBOSS_HOME"
echo "DOMAIN_BASE=$DOMAIN_BASE"
echo "SERVER_NAME=$SERVER_NAME"
echo "CONFIG_FILE=$CONFIG_FILE"
echo "BIND_ADDR=$BIND_ADDR"
echo "PORT_OFFSET=$PORT_OFFSET"
#echo "MULTICAST_ADDR=$MULTICAST_ADDR"
echo "CONTROLLER=$CONTROLLER_IP:$CONTROLLER_PORT"
echo "================================================"
