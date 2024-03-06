#!/bin/sh
. ../../env.sh

#java -cp jgroups-3.0.14.Final.jar org.jgroups.tests.McastSenderTest -mcast_addr 224.10.10.10 -port 5555
java -cp $JBOSS_HOME/bin/client/jboss-client.jar org.jgroups.tests.McastSenderTest -mcast_addr  230.11.11.11 -port 5555
