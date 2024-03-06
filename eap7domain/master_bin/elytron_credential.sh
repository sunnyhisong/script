#!/bin/bash

## Variable Definition ##
BASEDIR=`pwd`
SNAME=$1
PASSWORD=$2
DBNAME=$3
HOST=$4
NODENAME=$5


## DBNAME CHECK ##
str_chk=`echo "$DBNAME" | egrep "(.*)\/(.*)$" | wc -l`

if [[ $str_chk ]];
then
        DBNAME=`echo "$DBNAME" | sed -e 's/\//\\\\\//g'`
fi

## CHECK INPUT DATA ##
if [ e$DBNAME == "e" ];
then
        echo " Input Datasource Info ....."
        echo " ex ) ./elytron_credential.sh 'Credential Store Name' 'PASSWORD' 'Pool Name' 'Host name' 'instance name'"
        exit 1
fi

## CREATE CLI ##
echo "/profile=ha/subsystem=elytron/credential-store=$SNAME:add(location="$BASEDIR/credentials/$SNAME.jceks",credential-reference={clear-text=rockplace},create=true)" > elytron.cli
#echo "/subsystem=elytron/credential-store=$SNAME:add-alias(alias=$SNAME,secret-value=$PASSWORD)" >> elytron.cli
echo "/host=$HOST/server=$NODENAME/subsystem=elytron/credential-store=$SNAME:add-alias(alias=$SNAME,secret-value=$PASSWORD)" >> elytron.cli 
echo "/profile=ha/subsystem=datasources/data-source=$DBNAME:undefine-attribute(name=password)" >> elytron.cli
echo "/profile=ha/subsystem=datasources/data-source=$DBNAME:write-attribute(name=credential-reference,value={store=$SNAME,alias=$SNAME})" >> elytron.cli

#./jboss-cli.sh --file=elytron.cli

#rm -f elytron.cli

##############################
echo "Credential store name : $SNAME"
echo "password : $PASSWORD"
echo "Datasource pool name : $DBNAME"
echo "Host name : $HOST"
echo "instance name : $NODENAME"
echo "## END ##"
