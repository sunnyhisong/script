#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. $BASEDIR/env.sh

printf "===================================================================\n"
printf "%-20s | %-20s | %-20s\n" "SERVER NAME" "Controller" "Process CHECK"
printf "===================================================================\n"

PROCESS_CONTROLLER_PID=`ps -ef | grep "SERVER=$SERVER_NAME " | grep "\[Process Controller\]"|awk '{print $2}'`
HOST_CONTROLLER_PID=`ps -ef | grep "SERVER=$SERVER_NAME " | grep "\[Host Controller\]"|awk '{print $2}'`

PROCESS_CONTROLLER_PID_CNT=`ps -ef | grep java | grep "SERVER=$SERVER_NAME " | grep "\[Process Controller\]"| wc -l`
HOST_CONTROLLER_PID_CNT=`ps -ef | grep java | grep "SERVER=$SERVER_NAME " | grep "\[Host Controller\]"| wc -l`

if [[ e${PROCESS_CONTROLLER_PID_CNT} != "e0" ]];
then
    printf "%-20s | %-20s | %-20s\n" "$SERVER_NAME" "Process Controller" "${PROCESS_CONTROLLER_PID_CNT}  ( PID = ${PROCESS_CONTROLLER_PID} )"
else
    printf "%-20s | %-20s | \e[37;41m %-20s \033[0m \n" "$SERVER_NAME" "Process Controller" "${PROCESS_CONTROLLER_PID_CNT}  ( PID = ${PROCESS_CONTROLLER_PID} )"
fi

if [[ e${HOST_CONTROLLER_PID_CNT} != "e0" ]];
then
    printf "%s\n" "-------------------------------------------------------------------"
    printf "%-20s | %-20s | %-20s \n" "$SERVER_NAME" "Host Controller" "${HOST_CONTROLLER_PID_CNT}  ( PID = ${HOST_CONTROLLER_PID} )"
else
    printf "%s\n" "-------------------------------------------------------------------"
    printf "%-20s | %-20s | \e[37;41m %-20s \033[0m \n" "$SERVER_NAME" "Host Controller" "${HOST_CONTROLLER_PID_CNT}  ( PID = ${HOST_CONTROLLER_PID} )"
fi

NODE_LIST=`ps -ef | grep java | grep "SERVER=$SERVER_NAME " | sed 's/ /\n/g'| grep "\[Server\:"| awk -F':' '{print $2}'| sed 's/]//g'`

for NODE_NAME in $NODE_LIST
do
   NODE_CNT=`ps -ef | grep "\[Server\:$NODE_NAME" | grep -v grep | wc -l`
   NODE_PID=`ps -ef | grep "\[Server\:$NODE_NAME" | grep -v grep | awk '{print $2}'`

        if [[ e${NODE_CNT} != "e0" ]];
        then
                printf "%s\n" "-------------------------------------------------------------------"
                printf "%-20s | %-20s | %-20s \n" "$SERVER_NAME" "$NODE_NAME" "${NODE_CNT}  ( PID = ${NODE_PID} )"
        else
                printf "%s\n" "-------------------------------------------------------------------"
                printf "%-20s | %-20s | \e[37;41m %-20s \033[0m \n" "$SERVER_NAME" "${NODE_NAME}" "${NODE_CNT}  ( PID = ${NODE_PID} )"
        fi
done
                printf "===================================================================\n"
