#!/bin/sh
. ./env.sh

export JAVA_OPTS=" -Djava.awt.headless=false $JAVA_OPTS"

$RHDG_HOME/bin/cli.sh -c http://admin:rpjboss1!@$BIND_ADDR:$CMD_PORT $@
