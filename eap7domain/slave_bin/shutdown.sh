#!/bin/sh

. ./env.sh 

$JBOSS_HOME/bin/jboss-cli.sh --connect --controller=$DOMAIN_MASTER_ADDR:$DOMAIN_MASTER_PORT --command=/host=$HOST_NAME:shutdown
