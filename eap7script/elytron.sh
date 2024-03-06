#!/bin/bash
## Variable Definition ##

BASEDIR="$( cd "$( dirname "$0" )" && pwd -P )"

SNAME=$1

PASSWORD=$2

DBNAME=$3

ALIAS=$4



## DBNAME CHECK ##

str_chk=`echo "$DBNAME" | egrep "(.*)\/(.*)$" | wc -l`



if [[ $str_chk ]];

then

        DBNAME=`echo "$DBNAME" | sed -e 's/\//\\\\\//g'`

fi



## CHECK INPUT DATA ##

if [ e$DBNAME == "e" ];

then

        echo " input DATASOURCE Info ....."

        echo " ex ) ./elytron_credential.sh \"Credential store name\" \"passwd\" \"datasource name\" \"alias\" "

        exit 1

fi



cat << EOF > elytron.cli

/subsystem=elytron/credential-store=$SNAME:add(location="$BASEDIR/credentials/$SNAME.jceks",credential-reference={clear-text=rockplace},create=true)

/subsystem=elytron/credential-store=$SNAME:add-alias(alias=$ALIAS,secret-value=$PASSWORD)

/subsystem=datasources/data-source=$DBNAME:undefine-attribute(name=password)

/subsystem=datasources/data-source=$DBNAME:write-attribute(name=credential-reference,value={store=$SNAME,alias=$ALIAS})



EOF



../bin/jboss-cli.sh --file=elytron.cli



rm -f elytron.cli



##############################

echo "Credential store name : $SNAME"

echo "password : $PASSWORD"

echo "Datasource pool name : $DBNAME"

echo "Alias : $ALIAS"

echo "## END ##"

