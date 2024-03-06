#!/bin/sh

. ./env.sh 

tail -f $JBOSS_LOG_DIR/nohup/$SERVER_NAME.out
