#!/bin/sh

clear


JBOSS_CLI(){
. ${CLI_HOME#*=}/bin/env.sh
export JAVA_OPTS=" -Djava.awt.headless=false $JAVA_OPTS"
${JBOSS_HOME}/bin/jboss-cli.sh  --controller=$CONTROLLER_IP:$CONTROLLER_PORT --connect $@
}


################################
#1. Server System Check
#2. JBOSS Version Check
#3. JBOSS Memory Check - necessary package : bc
#4. JBOSS Cluster Check
#5. JBOSS Threads Check
#6. JBOSS DB connection Check
#7. Application session Check
#8. GC Check           - necessary package : bc
################################

SystemInfo_Hardware()
{
  Kernel_info=`uname -a |awk '{print $3}'`
  OS_info=`cat /etc/redhat-release`
  Hostname=`hostname`
  CPU_model_name=`grep "model name" /proc/cpuinfo |head -1 |awk -F':' '{print $NF}'`
  CPU_basic_core=`grep "cpu cores" /proc/cpuinfo |head -1 |awk -F':' '{print $NF}' |sed 's/ //g'`
  CPU_total_count=`grep "processor" /proc/cpuinfo |sort -u |wc -l |awk '{print $1}'`
  Total_Core=`grep "processor" /proc/cpuinfo |wc -l |awk '{print $1}'`
  Memory_size_kb=`grep MemTotal /proc/meminfo |awk '{print $2}'`
  Memory_size_mb=`expr ${Memory_size_kb} / 1024`
  JBOSS_DISK_USAGE=`df -h $JBOSS_HOME|grep -v "File" |awk '{print $5}'`
  JBOSS_LOG_DISK_USAGE=`df -h $JBOSS_HOME|grep -v "File" |awk '{print $5}'`

  # Print output
  ## JBOSS System Check ##
  printf "%s\n" "--------------------------------------------------"
  printf "\e[1;34m %-10s\e[0m \n" "## JBOSS SYSTEM CHECK ##"
  printf "%s\n" "--------------------------------------------------"
  printf " %-20s : %-15s \n" "HOSTNAME" "${Hostname}"
  printf " %-20s : %-15s \n" "OS INFO" "${OS_info}"
  printf " %-20s : %-15s \n" "Kernel INFO" "${Kernel_info}"
  printf " %-20s : %-15s \n" "CPU model" "${CPU_model_name}"
  printf " %-20s : %-15s \n" "Total cores" "${Total_Core}"
  printf " %-20s : %-15s \n" "Memory size" "${Memory_size_mb}MB"
  printf " %-20s : %-15s \n" "JBoss disk usage" "${JBOSS_DISK_USAGE}"
  printf " %-20s : %-15s \n" "JBoss Log disk usage" "${JBOSS_LOG_DISK_USAGE}"
printf "%s\n" "--------------------------------------------------"
}


## JBOSS Version Check ##
VERSION_CHECK()
{
### VERSION INFO GET ###
JBOSS_CLI --command=version > version_info.txt

printf "\e[1;34m %-10s\e[0m \n" "## JBOSS VERSION INFO ##"
printf "%s\n" "--------------------------------------------------"

JBOSS_RELEASE=`cat version_info.txt|grep "Release"| awk -F':' '{print $2}'`
JBOSS_PRODUCT=`cat version_info.txt|grep "Product"| awk -F':' '{print $2}'`
JAVA_VERSION=`cat version_info.txt|grep "java.version"| awk -F':' '{print $2}'`
OS_VERSION=`cat version_info.txt|grep "os.version"| awk -F':' '{print $2}'`

### Print output
printf " %-15s : %-10s\n" "OS_VERSION" "$OS_VERSION"
printf " %-15s : %-10s\n" "JBOSS_HOME" "$JBOSS_HOME"
printf " %-15s : %-10s\n" "JBOSS_RELEASE" "$JBOSS_RELEASE"
printf " %-15s : %-10s\n" "JBOSS_PRODUCT" "$JBOSS_PRODUCT"
printf " %-15s : %-10s\n" "JAVA_VERSION" "$JAVA_VERSION"
printf "%s\n" "--------------------------------------------------"

rm -f version_info.txt

}

## Memory Check ##
MEMORY_CHECK()
{
printf "\e[1;34m %-10s\e[0m \n" "## MEMORY USE CHECK ##"
printf "%s\n" "--------------------------------------------------"

export JVM_MEMORY="heap-memory-usage non-heap-memory-usage"

MEMORY_INFO=`JBOSS_CLI --command="/core-service=platform-mbean/type=memory:read-resource(include-runtime=true,recursive=true,recursive-depth=10)" > MEMORY_INFO.txt`

for MEMORY in $JVM_MEMORY
do
## heap-memory-usage ##
HEAP_USAGE_INIT_B=`cat MEMORY_INFO.txt | grep -A 3 "\"${MEMORY}\"" | grep "init" | grep -o [0-9]*`
HEAP_USAGE_INIT_MB=`expr ${HEAP_USAGE_INIT_B} / 1024 / 1024`
HEAP_USAGE_USE_B=`cat MEMORY_INFO.txt | grep -A 3 "\"${MEMORY}\"" |grep "used" | grep -o [0-9]*`
HEAP_USAGE_USE_MB=`echo "${HEAP_USAGE_USE_B}/1024/1024"|bc`
HEAP_USAGE_COMMITTED_B=`cat MEMORY_INFO.txt | grep -A 3 "\"${MEMORY}\"" | grep "committed" | grep -o [0-9]*`
HEAP_USAGE_COMMITTED_MB=`echo "scale=2;${HEAP_USAGE_COMMITTED_B}/1024/1024"|bc`

# Print output
printf " %-15s : %-15s\n" "JVM MEMORY" "$MEMORY"
printf " %-15s : %-15s\n" "INIT" "${HEAP_USAGE_INIT_MB} MB"
printf " %-15s : %-10s\n" "USED" "${HEAP_USAGE_USE_MB} MB"
printf " %-15s : %-10s\n" "COMMITTED" "${HEAP_USAGE_COMMITTED_MB} MB"
printf "%s\n" "--------------------------------------------------"
done

rm -f ./MEMORY_INFO.txt
}


## JBOSS Thread Check ##
THREAD_CHECK()
{
printf "\e[1;34m %-10s\e[0m \n" "## THREAD POOL CHECK ##"
printf "%s\n" "--------------------------------------------------"

### IO Threads INFO ###
JBOSS_CLI --command='/subsystem=io/worker=default:read-resource(include-runtime)' | sed 's/[,|"]//g' > io_status.txt

IO_THREADS=`cat io_status.txt | grep "io-threads" | awk -F'=>' '{print $2}'`
IO_THREAD_COUNT=`cat io_status.txt | grep "io-thread-count" | awk -F'=>' '{print $2}'`
MAX_POOL_SIZE=`cat io_status.txt | grep "max-pool-size" | awk -F'=>' '{print $2}'`
TASK_MAX_THREAS=`cat io_status.txt | grep "task-max-threads" | awk -F'=>' '{print $2}'`
BUSY_TASK_THREAD_COUNT=`cat io_status.txt | grep "busy-task-thread-count " | awk -F'=>' '{print $2}'`
QUEUE_SIZE=`cat io_status.txt | grep "queue-size" | awk -F'=>' '{print $2}'`

# Print output
printf " %-25s : %-10s\n" "IO_THREADS" "$IO_THREADS"
printf " %-25s : %-10s\n" "IO_THREAD_COUNT" "$IO_THREAD_COUNT"
printf " %-25s : %-10s\n" "MAX_POOL_SIZE" "$MAX_POOL_SIZE"
printf " %-25s : %-10s\n" "TASK_MAX_THREAS"  "$TASK_MAX_THREAS"
printf " %-25s : %-10s\n" "BUSY_TASK_THREAD_COUNT" "$BUSY_TASK_THREAD_COUNT"
printf " %-25s : %-10s\n" "QUEUE_SIZE" "$QUEUE_SIZE"
printf "%s\n" "--------------------------------------------------"

rm -f ./io_status.txt
}

## DB Connection Check ##
DB_CONNECT_CHECK()
{
### DS POOL NAME GET ###
JBOSS_CLI --command="/subsystem=datasources:read-resource(recursive=true)"|grep -B 1 "allocation-retry\"" | sed 's/{/\n/g' | sed 's/"//g' > DS_info.txt
DS_NAMES=`cat DS_info.txt |egrep -v "allocation-retry|--" | sed 's/=>/\n/g' |grep -v "data-source"`
#echo $DS_NAMES

printf "\e[1;34m %-10s\e[0m \n" "## DATASOURCE CONNETION POOL CHECK ##"
printf "%s\n" "--------------------------------------------------"


for DS_NAME in $DS_NAMES ;
do
        ### DS Monitoring Check  ###
        JBOSS_CLI --command=/subsystem=datasources/data-source=$DS_NAME:read-resource\(recursive=true,include-runtime=true\) | sed 's/["|,]//g' > conn_info.txt
        ### DS POOL Connection TEST ###
        JBOSS_CLI --command="/subsystem=datasources/data-source=$DS_NAME:test-connection-in-pool" | sed 's/["|,]//g' > conn_test.txt

        TEST_CONNECTION_CHECK=`cat conn_test.txt|grep "outcome"|awk -F'=>' '{print $2}'`
        MAX_POOL_SIZE=`cat conn_info.txt|grep "max-pool-size"|awk -F'=>' '{print $2}'`
        MIN_POOL_SIZE=`cat conn_info.txt|grep "min-pool-size"|awk -F'=>' '{print $2}'`
        ACTIVE_COUNT=`cat conn_info.txt|grep "ActiveCount"|awk -F'=>' '{print $2}'`
        IN_USE_COUNT=`cat conn_info.txt|grep "InUseCount"|awk -F'=>' '{print $2}'`
        MAX_IN_USE_COUNT=`cat conn_info.txt|grep "MaxUsedCount"|awk -F'=>' '{print $2}'`

# Print output
printf " %-15s : %-15s\n" "DATASOURCE" " $DS_NAME"
if [ $TEST_CONNECTION_CHECK == "success" ]
then
        printf " %-15s : %-15s\n" "connection" " OK"
else
        printf " %-15s : \e[37;41m %-15s \033[0m \n" "connection" "DISCONNECT"
fi
printf " %-15s : %-10s\n" "min_pool_size" "$MIN_POOL_SIZE"
printf " %-15s : %-10s\n" "max_pool_size" "$MAX_POOL_SIZE"
printf " %-15s : %-10s\n" "ActiveCount" "$ACTIVE_COUNT"
printf " %-15s : %-10s\n" "InUseCount"  "$IN_USE_COUNT"
printf " %-15s : %-10s\n" "MaxInUseCount" "$MAX_IN_USE_COUNT"
printf "%s\n" "--------------------------------------------------"
done

rm -f ./DS_info.txt ./conn_info.txt  ./conn_test.txt
}


## Application Session Check ##
APP_SESSION_CHECK()
{
### Deployment APPS GET ###
JBOSS_CLI --command="/deployment=*/subsystem=undertow:read-resource(include-runtime=true)" | sed 's/["|,]//g' > session_info.txt
DEPLOY_APPS=`cat session_info.txt|grep "deployment"|awk -F'=>' '{print $2}'`

printf "\e[1;34m %-10s\e[0m \n" "## ACTIVE SESSION CHECK ##"
printf "%s\n" "--------------------------------------------------"

### Deployed APPS Session GET ###
for DEPLOY_APP in $DEPLOY_APPS ;
do

ACTIVE_SESSION=`cat session_info.txt|grep $DEPLOY_APP -A 16 | grep "active-sessions" | grep -v max | awk -F'=>' '{print $2}'`
MAX_ACTIVE_SESSIONS=`cat session_info.txt|grep $DEPLOY_APP  -A 16 | grep "max-active-sessions"| awk -F'=>' '{print $2}'`
SESSION_CREATED=`cat session_info.txt|grep $DEPLOY_APP -A 16 | grep "sessions-created" | awk -F'=>' '{print $2}'`
EXPIRED_SESSION=`cat session_info.txt|grep $DEPLOY_APP -A 16 | grep "expired-sessions" | awk -F'=>' '{print $2}'`

# Print output
APPLICATION=`echo $DEPLOY_APP | sed 's/)//'`
printf " %-20s : %-15s\n" "APPLICATION" "$APPLICATION"
printf " %-20s : %-10s\n" "active-sessions" "$ACTIVE_SESSION"
printf " %-20s : %-10s\n" "max-active-sessions" "$MAX_ACTIVE_SESSIONS"
printf " %-20s : %-10s\n" "sessions-created" "$SESSION_CREATED"
printf " %-20s : %-10s\n" "expired-sessions" "$EXPIRED_SESSION"
printf "%s\n" "--------------------------------------------------"
done

rm -f ./session_info.txt
}


## Cluster Member Check ##
CLUSTER_CHECK()
{
JBOSS_CLI --command="/subsystem=jgroups/channel=ee:read-attribute(name=view,include-defaults)" |sed 's/"//g' > CLUSTER_INFO.txt

ADD_MEMBER=`cat CLUSTER_INFO.txt|grep "result" |awk '{print $3}'`
CURRENT_VIEW=`cat CLUSTER_INFO.txt|grep "result" | awk '{print $5" "$6}'`

printf "\e[1;34m %-10s\e[0m \n" "## JBOSS JGROUPS MEMBER CHECK ##"
printf "%s\n" "---------------------------------------------------"

if [[ e$CURRENT_VIEW == "e" ]]
then
        printf " %-20s : %-30s\n" "Current Members" "N/A"
        printf " %-20s : %-10s\n" "Add Member" "N/A"
else
        printf " %-20s : %-30s\n" "Current Members" "$CURRENT_VIEW"
        printf " %-20s : %-10s\n" "Add Member" "$ADD_MEMBER"
fi
printf "%s\n" "--------------------------------------------------"

rm -f CLUSTER_INFO.txt

}


## GC log Check ##
## JDK 1.8 Ver ##
GC_CHECK()
{
printf "\e[1;34m %-10s\e[0m \n" "## GC CHECK ##"
printf "%s\n" "--------------------------------------------------"

JSTAT=`type jstat 2> /dev/null`

if [[ e$JSTAT == "e" ]]
then
    echo " jstat is required........."
    printf "%s\n" "--------------------------------------------------"
    exit;
fi

$JAVA_HOME/bin/jstat -gcutil $JBOSS_PID |grep -v "S0" > gc.txt 2>&1

OLD=`cat gc.txt |awk '{print $4}'`
META=`cat gc.txt |awk '{print $5}'`
CCS=`cat gc.txt |awk '{print $6}'`
YGC=`cat gc.txt |awk '{print $7}'`
YGCT=`cat gc.txt |awk '{print $8}'`
FGC=`cat gc.txt |awk '{print $9}'`
FGCT=`cat gc.txt |awk '{print $10}'`

if [ ${YGC} == 0 ]
then
        AVG_YGCT=0
else
        AVG_YGCT=`echo "scale=2;${YGCT}/${YGC}"|bc`
fi

if [ ${FGC} == 0 ]
then
        AVG_FGCT=0
else
        AVG_FGCT=`echo "scale=2;${FGCT}/${FGC}"|bc`
fi

printf " %-15s : %-7s | %-12s : %-8s\n" "Meat Space" "${META}%" "Old Usage" "${OLD}%"
printf " %-15s : %-7s | %-12s : %-8s\n" "YGC Count" "$YGC" "FGC Count" "$FGC"
printf " %-15s : %-7s | %-12s : %-8s\n" "YGC Time" "$YGCT" "FGC Time" "$FGCT"
printf " %-15s : %-7s | %-12s : %-8s\n" "Avg YGC Time" "$AVG_YGCT" "Avg FGC Time" "$AVG_FGCT"
printf " %-20s : %-7s\n" "Compressed Class Space" "${CCS}%"
printf "%s\n" "--------------------------------------------------"

rm -f gc.txt

echo
}


JBOSS_LOG_CHECK(){



###홈디렉터리에 파일 떨어집니다.###

DATE_1month_ago=`date +%Y-%m- -d '1 month ago'`
DATE_month_ago=`date +%Y-%m-`


    LOG_TRACE=`ps -ef | grep java | grep jboss | awk 'NR=='${i}| sed -e "s/[[:space:]]/\n/g" | awk '/^-Djboss.server.log.dir/{print $NF}'`
    LOG_HOME=${LOG_TRACE#*=}
   

    printf "\e[1;34m %-10s\e[0m \n" "## JBOSS LOG ANALYSIS ##"
    printf "%s\n" "--------------------------------------------------"
    printf " %-15s : %-7s | %-12s : %-8s\n" "LOG_HOME" "$LOG_HOME" 
    printf "\n"


    egrep -i 'OutOfMemoryError|Unable to get managed connection|timeout or client request|Maximum number of threads|Closing a connection for you|too many open files' ${LOG_HOME}/server.log.${DATE_1month_ago}*

    egrep -i 'OutOfMemoryError|Unable to get managed connection|timeout or client request|Maximum number of threads|Closing a connection for you|too many open files' ${LOG_HOME}/server.log.${DATE_month_ago}*

    printf "%s\n" "--------------------------------------------------"


}

LOG_HOME_SIZE(){

printf "\e[1;34m %-10s\e[0m \n" "## LOG HOME SIZE ##"
printf "%s\n" "--------------------------------------------------"


df -h ${LOG_HOME} >  size.txt 2>&1

Filesystem=`cat size.txt |awk 'NR==2{print $1}'`
Size=`cat size.txt |awk 'NR==2{print $2}'`
Used=`cat size.txt |awk 'NR==2{print $3}'`
Avail=`cat size.txt |awk 'NR==2{print $4}'`
Use=`cat size.txt |awk 'NR==2{print $5}'`
Mounted=`cat size.txt |awk 'NR==2{print $6}'`
      
printf " %-15s : %-7s\n" "Filesystem" "${Filesystem}"
printf " %-15s : %-7s\n" "Size" "${Size}"
printf " %-15s : %-7s | %-12s : %-8s\n" "Used" "$Used" "Avail" "$Avail"
printf " %-15s : %-7s | %-12s : %-8s\n" "Use" "$Use" "Mounted" "$Mounted"
printf "%s\n" "--------------------------------------------------"

rm -f size.txt


}




sum=0
JPID=`ps -ef | grep java | grep jboss | awk '{sum=sum+ ARGC} END {print sum}'`

if [[ "${JPID}" -gt "0" ]];
then

  for ((i=1; i <= ${JPID}; i++))
  do

    CLI_HOME=`ps -ef | grep java | grep jboss | awk 'NR=='${i}| sed -e "s/[[:space:]]/\n/g" | awk '/^-Djboss.server.base.dir=/'|sed -n 1p`
    JBOSS_PID=`ps -ef | grep java | grep jboss | awk 'NR=='${i}'{print $2}'`

    . ${CLI_HOME#*=}/bin/env.sh

printf "%s\n" "=================================================="
printf "\e[1;34m %-10s\e[0m \n" "## JBOSS EAP ${i} SERVER  ##"
printf "%s\n" "=================================================="



	SystemInfo_Hardware
	VERSION_CHECK
	MEMORY_CHECK
	CLUSTER_CHECK
	THREAD_CHECK
	DB_CONNECT_CHECK
	APP_SESSION_CHECK
	GC_CHECK
	JBOSS_LOG_CHECK

  done

        LOG_HOME_SIZE

else
	 echo "JBoss SERVER - $SERVER_NAME is Not RUNNING..."
fi
