#!/bin/sh
. /JBOSS/jboss-fsw/bin/env.sh

$JBOSS_HOME/bin/jboss-cli.sh --connect --controller=$BIND_ADDR:9999 $@
