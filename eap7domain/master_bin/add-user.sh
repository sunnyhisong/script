#!/usr/bin/env bash
BASEDIR=$(dirname "$0")
. $BASEDIR/env.sh

#JAVA_OPTS="$JAVA_OPTS -Djboss.server.config.user.dir=../standalone/configuration"
JAVA_OPTS="$JAVA_OPTS  -Djboss.domain.config.user.dir=$DOMAIN_BASE/$SERVER_NAME/configuration "

$JBOSS_HOME/bin/add-user.sh $@
