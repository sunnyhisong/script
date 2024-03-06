#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. $BASEDIR/env.sh

ps -ef | grep java | grep $SERVER_NAME | grep --color "Process Controller"
ps -ef | grep java | grep $SERVER_NAME | grep --color "Host Controller"
ps -ef | grep java | grep $SERVER_NAME | grep --color "\[Server\:"

