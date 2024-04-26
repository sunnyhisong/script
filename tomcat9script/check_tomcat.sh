#!/bin/sh

. ./env.sh


printf "\e[1;34m %-10s\e[0m \n" "## DATA ##"
date=`date "+%Y-%m"`
date "+%Y-%m"

PID=`ps -ef | grep java | grep "SERVER_NAME=$SERVER_NAME" | grep -v grep | awk '{print $2}'`

if [ "e$PID" == e ]
then
    echo "Tomcat SERVER - $SERVER_NAME is Not RUNNING..."
    exit;
fi

printf "\e[1;34m %-10s\e[0m \n" "## Disk Usage ##"
df -h $CATALINA_BASE

printf "\e[1;34m %-10s\e[0m \n" "## LOG Usage ##"
df -h $LOG_HOME

printf "\e[1;34m %-10s\e[0m \n" "## Total memory ##"
free -m

printf "\e[1;34m %-10s\e[0m \n" "## MAX/MIN Memory ##"
cat ./env.sh | egrep "Xms|Xmx"

printf "\e[1;34m %-10s\e[0m \n" "## PORT ##"
cat ./env.sh | grep "export PORT_OFFSET="

printf "\e[1;34m %-10s\e[0m \n" "## HEAP Memory ##"
jstat -gcutil $PID 200 5

printf "\e[1;34m %-10s\e[0m \n" "## Server LOG1 ##"
#LOG=`egrep "java.lang.outofmemory|Too many open files|Closing a connection|Unable to get managed connection|Statement cancelled due to timeout or client request|Maximum number of threads" $LOG_HOME/catalina.$date*` > LOG1_$date.out
LOG=`egrep -i "java.lang.OutOfMem|Too many open files|Broken pipe|Error looking up data source for name" $LOG_HOME/catalina.${date}*` > LOG1_$date.out

LOG=`egrep -i "java.lang.OutOfMem|Too many open files|Broken pipe|Error looking up data source for name" $LOG_HOME/catalina.$(date --date '1 month ago' +%Y-%m)*` > LOG1_$(date --date '1 month ago' +%Y-%m).out

find .  -name '*.out' -size 0c -exec rm -rf {} -v  \;

if [ "e$LOG" == e ]
then
        printf "%-15s\n" "ERROR LOG [N/A]"
else
        printf "%-15s\n" "$LOG"
fi
