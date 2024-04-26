#!/usr/bin/env bash
# env.sh - start a new shell with instance variables set

DATE=`date +%Y%m%d%H%M%S`

## env base set
export TOMCAT_VERSION=apache-tomcat-8.5.82
export SERVER_HOME=`echo $(dirname $(realpath 0))|rev| cut -d '/' -f 4-|rev`	# /sw/was/
export CATALINA_HOME=${SERVER_HOME}/${TOMCAT_VERSION}				# /sw/was/tomcat version
export SERVER_NAME=`echo $(dirname $(realpath 0))|rev| cut -d '/' -f 2|rev`	# SERVER_NAME
export CATALINA_BASE=${SERVER_HOME}/domains/${SERVER_NAME}			# DOMAIN BASE
export LOG_HOME=${SERVER_HOME}/logs/${SERVER_NAME}				# /sw/was/logs/INSTANCE_NAME
#export LOG_HOME=/logs/was/${SERVER_NAME}

export SERVER_USER=`echo $(stat -c "%U" ./env.sh)`

#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CATALINA_HOME}/lib:${SERVER_HOME}/commons/native
#export CLASSPATH=${CLASSPATH}:${SERVER_HOME}/commons/lib:${SERVER_HOME}/commons/conf

# JAVA set
#export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
export PATH=${JAVA_HOME}/bin:$PATH

# port offset group
export HOSTNAME=`/bin/hostname`
export JMX_BIND_ADDR=`/bin/hostname -I | cut -d ' ' -f 2`
export PORT_OFFSET=0

let HTTP_PORT=8080+${PORT_OFFSET}
let HTTPS_PORT=8443+${PORT_OFFSET}
let AJP_PORT=8009+${PORT_OFFSET}
let SHUTDOWN_PORT=8005+${PORT_OFFSET}
export HTTP_PORT HTTPS_PORT AJP_PORT SHUTDOWN_PORT

#let MGT_PORT=9990+${PORT_OFFSET}
#let JMX_PORT=9999+${PORT_OFFSET}
#export MGT_PORT JMX_PORT

JAVA_OPTS="-server"
JAVA_OPTS="${JAVA_OPTS} -D[SERVER_NAME=${SERVER_NAME}]"
JAVA_OPTS="${JAVA_OPTS} -Dserver.base=${SERVER_HOME}"
JAVA_OPTS="${JAVA_OPTS} -Dcatalina.base.log=${LOG_HOME}" 

JAVA_OPTS="${JAVA_OPTS} -Dfile.encoding=UTF-8"
JAVA_OPTS="${JAVA_OPTS} -Dserver.encoding=UTF-8" 
JAVA_OPTS="${JAVA_OPTS} -Dserver.name=${SERVER_NAME}"

JAVA_OPTS="${JAVA_OPTS} -Xms1024m"
JAVA_OPTS="${JAVA_OPTS} -Xmx1024m"
JAVA_OPTS="${JAVA_OPTS} -XX:MetaspaceSize=256m"
JAVA_OPTS="${JAVA_OPTS} -XX:MaxMetaspaceSize=256m"
#JAVA_OPTS="${JAVA_OPTS} -XX:PermSize=256m"
#JAVA_OPTS="${JAVA_OPTS} -XX:MaxPermSize=256m" 


### GC ###
JAVA_OPTS="${JAVA_OPTS} -XX:+UseParallelGC" 
#JAVA_OPTS="${JAVA_OPTS} -XX:+UseParallelOldGC"  
#JAVA_OPTS="${JAVA_OPTS} -XX:+UseConcMarkSweepGC" 
#JAVA_OPTS="${JAVA_OPTS} -XX:+UseG1GC -XX:MaxGCPauseMillis=1000"  


### GC OPTIONS JAVA11###
#export JAVA_OPTS=" $JAVA_OPTS -verbose:gc"
#export JAVA_OPTS=" $JAVA_OPTS -Xlog:gc*,gc+heap=trace:$LOG_HOME/gclog/gc_$DATE.log:time"
#export JAVA_OPTS=" $JAVA_OPTS -XX:+DisableExplicitGC "

### GC OPTIONS JAVA8###
export JAVA_OPTS=" $JAVA_OPTS -verbose:gc"
export JAVA_OPTS=" $JAVA_OPTS -XX:+PrintGCTimeStamps "
export JAVA_OPTS=" $JAVA_OPTS -XX:+PrintGCDetails "
export JAVA_OPTS=" $JAVA_OPTS -XX:+PrintHeapAtGC"
export JAVA_OPTS=" $JAVA_OPTS -Xloggc:$LOG_HOME/gclog/${SERVER_NAME}_gc.log"

### HEAP ####
JAVA_OPTS="${JAVA_OPTS} -XX:+HeapDumpOnOutOfMemoryError"
JAVA_OPTS="${JAVA_OPTS} -XX:HeapDumpPath=$LOG_HOME/${SERVER_NAME}_java_pid_$DATE.hprof"

### JMX REMOTE ###
#JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote"
#JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
#JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.authenticate=true"
#JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.access.file=${SERVER_HOME}/commons/conf/jmxremote.access"
#JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.password.file=${SERVER_HOME}/commons/conf/jmxremote.password"
#JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.port=${JMX_PORT}"
#JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.host=${JMX_BIND_ADDR}"
#JAVA_OPTS="${JAVA_OPTS} -Djava.rmi.server.hostname=${JMX_BIND_ADDR}"

# BINDING PORT GROUP - edit server.xml
JAVA_OPTS="${JAVA_OPTS} -Dhttp.bind.port=${HTTP_PORT}"
JAVA_OPTS="${JAVA_OPTS} -Dhttps.bind.port=${HTTPS_PORT}"
JAVA_OPTS="${JAVA_OPTS} -Dajp.bind.port=${AJP_PORT}"
JAVA_OPTS="${JAVA_OPTS} -Dshutdown.bind.port=${SHUTDOWN_PORT}"
#JAVA_OPTS="${JAVA_OPTS} -Dmanagement.bind.port=${MGT_PORT}"

# SecureRandom Bug
# http://wiki.apache.org/tomcat/HowTo/FasterStartUp
JAVA_OPTS="${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom"

JAVA_OPTS="${JAVA_OPTS} -Djava.net.preferIPv4Stack=true"
# tomcat 8 -> conf/web.xml : strict_quote_escaping
#JAVA_OPTS="${JAVA_OPTS} -Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=false"
#JAVA_OPTS="${JAVA_OPTS} -Dorg.apache.tomcat.util.http.ServerCookie.ALLOW_HTTP_SEPARATORS_IN_V0=false"

export JAVA_OPTS

printf "\e[1;34m%s\n" "================================================"
#printf " %-15s = %-20s \n" "SERVER_HOME" "${SERVER_HOME}"
printf " %-15s = %-20s \n" "CATALINA_HOME" "${CATALINA_HOME}"
printf " %-15s = %-20s \n" "CATALINA_BASE" "${CATALINA_BASE}"
printf " %-15s = %-20s \n" "SERVER_NAME" "${SERVER_NAME}"
#printf " %-15s = %-20s \n" "JAVA_OPTS" "${JAVA_OPTS}"
printf "%s\e[0m\n" "================================================"

UNAME=$USER 

if [ e${UNAME} != "e${SERVER_USER}" ]
then 
    printf "\033[0;31m%-10s\033[0m\n" "Opps! you are logged in as \"${UNAME}\" now, Run script as \"${SERVER_USER}\""
    exit;
fi 
