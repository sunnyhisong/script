#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. $BASEDIR/env.sh

printf "================================================\n"
printf "%-20s | %-20s \n" "INSTANCE NAME" "PROCESS CHECK"
printf "================================================\n"

PID=`ps -ef | grep java | grep "SERVER=$SERVER_NAME "|awk '{print $2}'`
PID_CNT=`ps -ef | grep java | grep "SERVER=$SERVER_NAME "| wc -l`

if [[ e${PID_CNT} != "e0" ]];
then
    printf "%-20s | %-20s \n" "${SERVER_NAME}" "${PID_CNT}  ( PID = ${PID} )"
    printf "================================================\n"
else
    printf "%-20s | \e[37;41m %-20s \033[0m \n" "${SERVER_NAME}" "${PID_CNT}  ( PID = ${PID} )"
    printf "================================================\n"
fi

