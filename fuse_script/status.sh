#!/bin/sh

. /JBOSS/jboss-fsw/bin/env.sh

ps -ef | grep java | grep "Dserver=$SERVER_NAME " 
