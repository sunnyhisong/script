#!/usr/bin/env bash 

BASEDIR=$(dirname "$0")
. $BASEDIR/env.sh

# ------------------------------------
PID=`ps -ef | grep java | grep "=$SERVER_NAME" | awk '{print $2}'`

if [ e$PID == "e" ]
then
    echo "TOMCAT($SERVER_NAME) is not RUNNING..."
    exit;
fi
# ------------------------------------
UNAME=`id -u -n`
if [ e$UNAME != "e$SERVER_USER" ]
then
    echo "$SERVER_USER USER to healtcheck $SERVER_NAME Server ..."
    exit;
fi
# ------------------------------------


## TOMCAT System Check ##
printf "%s\n" "--------------------------------------------------"
printf "\e[1;34m %-10s\e[0m \n" "## TOMCAT SYSTEM CHECK ##"
printf "%s\n" "--------------------------------------------------"
HARDWARE()
{
  Kernel_info=`uname -a |awk '{print $3}'`
  OS_info=`cat /etc/redhat-release`
  Hostname=`hostname`
  CPU_model_name=`grep "model name" /proc/cpuinfo |head -1 |awk -F':' '{print $NF}'`
  CPU_basic_core=`grep "cpu cores" /proc/cpuinfo |head -1 |awk -F':' '{print $NF}' |sed 's/ //g'`
  CPU_total_count=`grep "core id" /proc/cpuinfo |sort -u |wc -l |awk '{print $1}'`
  Total_Core=`grep "core id" /proc/cpuinfo |wc -l |awk '{print $1}'`
  Memory_size_kb=`grep MemTotal /proc/meminfo |awk '{print $2}'`
  Memory_size_mb=`expr ${Memory_size_kb} / 1024`
  TOMCAT_DISK_USAGE=`df -h $SERVER_HOME|grep -v "File" |awk '{print $5}'`
  TOMCAT_LOG_DISK_USAGE=`df -h $SERVER_HOME|grep -v "File" |awk '{print $5}'`
# Print output 
  printf " %-20s : %-20s \n" "HOSTNAME" "${Hostname}"
  printf " %-20s : %-20s \n" "OS INFO" "${OS_info}"
  printf " %-20s : %-20s \n" "Kernel INFO" "${Kernel_info}"
  printf " %-20s : %-20s \n" "CPU model" "$(echo -e "${CPU_model_name}" | tr -d '[:space:]')"
  printf " %-20s : %-20s \n" "Total cores" "${Total_Core}"
  printf " %-20s : %-20s \n" "Memory size" "${Memory_size_mb}MB"
  printf " %-20s : %-20s \n" "JBoss disk usage" "${TOMCAT_DISK_USAGE}"
  printf " %-20s : %-20s \n" "JBoss Log disk usage" "${TOMCAT_LOG_DISK_USAGE}"
}

## TOMCAT Version Check ##
VERSION()
{
printf "%s\n" "--------------------------------------------------"
printf "\e[1;34m %-10s\e[0m \n" "## TOMCAT VERSION CHECK ##"
printf "%s\n" "--------------------------------------------------"
 
## version INFO ##
TOMCAT_VERSION=`$CATALINA_HOME/bin/version.sh |grep "Server version" | awk -F':' '{print $2}'` 
TOMCAT_RELEASE=`$CATALINA_HOME/bin/version.sh |grep "Server number" | awk -F':' '{print $2}'` 
JAVA_VERSION=`$CATALINA_HOME/bin/version.sh |grep "JVM Version" | awk -F':' '{print $2}'`

# Print output 
printf " %-20s : %-10s\n" "TOMCAT_HOME" "$CATALINA_HOME"
printf " %-20s : %-10s\n" "JAVA_HOME" "$JAVA_HOME"
printf " %-20s : %-10s\n" "TOMCAT_VERSION" "$(echo -e "${TOMCAT_VERSION}" | tr -d '[:space:]')" 
printf " %-20s : %-10s\n" "TOMCAT_RELEASE" "$(echo -e "${TOMCAT_RELEASE}" | tr -d '[:space:]')" 
printf " %-20s : %-10s\n" "JAVA_VERSION" "$(echo -e "${JAVA_VERSION}" | tr -d '[:space:]')" 
}


JMX(){
JMX_MON=`$BASEDIR/jmxsh $BASEDIR/ext/healthcheck.jmxsh`
printf "%s\n" "--------------------------------------------------"
printf "\e[1;34m %-10s\e[0m \n" "## TOMCAT JMX CHECK ##"
printf "%s\n" "--------------------------------------------------"

  
 #Arr=`echo $JMX_MON | awk '{n=split($0, array, "|")} END{print n}'`

 echo $JMX_MON | awk -v FS="|" '{for (i=1;i<NF;i++) print  $i}' | awk -F">>" '{printf " %-20s : %-10s\n",$1,$2}' 

 #echo $JMX_MON | awk -F'|' '{print $1}' |awk -F">>" '{printf " %-20s : %-10s\n",$1,$2}'
 #echo $JMX_MON | awk -F'|' '{print $2}' |awk -F">>" '{printf " %-20s : %-10s\n",$1,$2}'
 #echo $JMX_MON | awk -F'|' '{print $3}' |awk -F">>" '{printf " %-20s : %-10s\n",$1,$2}'
 #echo $JMX_MON | awk -F'|' '{print $4}' |awk -F">>" '{printf " %-20s : %-10s\n",$1,$2}'
 #echo $JMX_MON | awk -F'|' '{print $5}' |awk -F">>" '{printf " %-20s : %-10s\n",$1,$2}'

printf "\n" 
#printf "%s\n" "--------------------------------------------------"
printf "\e[1;34m %-10s\e[0m \n" "* TOMCAT JMX Description"
printf "\e[1;34m %-20s : %-10s\e[0m \n" "threads" "max,active,idle,largest"
printf "\e[1;34m %-20s : %-10s\e[0m \n" "session" "context,active,largest"
printf "\e[1;34m %-20s : %-10s\e[0m \n" "db" "jndi,max,active,idle"
printf "%s\n" "--------------------------------------------------"
}

HARDWARE
VERSION
JMX
