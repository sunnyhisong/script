#!/bin/bash


###홈디렉터리에 파일 떨어집니다.###

DATE_1month_ago=`date +%Y-%m- -d '1 month ago'`
DATE_month_ago=`date +%Y-%m-`


sum=0
PID=`ps -ef | grep java | grep jboss | awk '{sum=sum+ ARGC} END {print sum}'`

echo "mem size"
free -g

printf "\n"

echo "logs size"
df -h 


if [[ "${PID}" -gt "0" ]];
then

for ((i=1; i <= ${PID}; i++))
  do
    JBOSS_PID=`ps -ef | grep java | grep jboss | awk 'NR=='${i}'{print $2}'`
    LOG_TRACE=`ps -ef | grep java | grep jboss | awk 'NR=='${i}''| sed -e "s/[[:space:]]/\n/g" | awk '/^-Djboss.server.log.dir/{print $NF}'`
    DOMAIN_HOME=`ps -ef | grep java | grep jboss | awk 'NR=='${i}''| sed -e "s/[[:space:]]/\n/g" | awk '/^-Djboss.server.base.dir=/'|sed -n '1p'`
    LOG_HOME=${LOG_TRACE#*=}

    printf "\n"
    printf "DOMAIN_HOME : ${DOMAIN_HOME#*=}\n"
    printf "PID : ${JBOSS_PID}\n"
    printf "LOG_HOME : ${LOG_HOME}\n" # remove
    printf "\n"

    jstat -gcutil ${JBOSS_PID}
    printf "\n"
     
    egrep -i 'OutOfMemoryError|Unable to get managed connection|timeout or client request|Maximum number of threads|Closing a connection for you|too many open files' ${LOG_HOME}/server.log.${DATE_1month_ago}*
    
    egrep -i 'OutOfMemoryError|Unable to get managed connection|timeout or client request|Maximum number of threads|Closing a connection for you|too many open files' ${LOG_HOME}/server.log.${DATE_month_ago}*

# 
  done


else
	printf "WAS IS NULL\n"
fi
