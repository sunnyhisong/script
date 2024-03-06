#!/bin/sh

##### DEFAULT ENV  #####
export ROCK_JAVA_HOME=ROCK_JAVA_HOME
export ROCK_JBOSS_VERSION=ROCK_JBOSS_VERSION
export ROCK_JBOSS_HOME=ROCK_JBOSS_HOME
export ROCK_DOMAIN_BASE=ROCK_DOMAIN_BASE
export ROCK_SERVER_NAME=ROCK_SERVER_NAME
export ROCK_LOG_HOME=ROCK_LOG_HOME
export ROCK_CONFIG_FILE=ROCK_CONFIG_FILE
export ROCK_PORT_OFFSET=ROCK_PORT_OFFSET
export ROCK_JBOSS_USER=ROCK_JBOSS_USER
export ROCK_BIND_ADDR=ROCK_BIND_ADDR
export ROCK_HEAP_MAX=ROCK_HEAP_MAX
export ROCK_HEAP_MIN=ROCK_HEAP_MIN
export ROCK_META_MAX=ROCK_META_MAX
export ROCK_META_MIN=ROCK_META_MIN

##### NEW ENV Setup #####
export JAVA_HOME='\/usr\/lib\/jvm\/java-1.8.0-openjdk'
export JBOSS_VERSION="jboss-eap-7.3"
export FULL_PATH=$(cd  "$(dirname "$0")" %&& pwd)
export JBOSS_HOME=`echo ${FULL_PATH}|rev|cut -d '/' -f 4-|rev`
export DOMAIN_BASE=`echo ${FULL_PATH}|rev|cut -d '/' -f 3-|rev`   
export SERVER_NAME=`echo ${FULL_PATH}|rev|cut -d '/' -f 2|rev`	        
export LOG_HOME=${DOMAIN_BASE}/${SERVER_NAME}/log
export CONFIG_FILE=standalone.xml
export PORT_OFFSET=200
export JBOSS_USER=jboss
export BIND_ADDR=10.65.40.215
export HEAP_MAX=Xmx512m
export HEAP_MIN=Xms512m
export META_MAX=256m
export META_MIN=256m

##### create env.sh ######
env_create()
{
cp eap7_env.sh ./env.sh
chmod 700 ./env.sh
}

##### setup env.sh ######
env_setup()
{
sed -i "s/${ROCK_JAVA_HOME}/${JAVA_HOME}/g" ./env.sh
sed -i "s/${ROCK_JBOSS_VERSION}/${JBOSS_VERSION}/g" ./env.sh
sed -i "s/${ROCK_JBOSS_HOME}/${JBOSS_HOME//\//\\/}/g" ./env.sh
sed -i "s/${ROCK_DOMAIN_BASE}/${DOMAIN_BASE//\//\\/}/g" ./env.sh
sed -i "s/${ROCK_SERVER_NAME}/${SERVER_NAME}/g" ./env.sh
sed -i "s/${ROCK_LOG_HOME}/${LOG_HOME//\//\\/}/g" ./env.sh
sed -i "s/${ROCK_CONFIG_FILE}/${CONFIG_FILE}/g" ./env.sh
sed -i "s/${ROCK_PORT_OFFSET}/${PORT_OFFSET}/g" ./env.sh
sed -i "s/${ROCK_JBOSS_USER}/${JBOSS_USER}/g" ./env.sh
sed -i "s/${ROCK_BIND_ADDR}/${BIND_ADDR}/g" ./env.sh
sed -i "s/${ROCK_HEAP_MAX}/${HEAP_MAX}/g" ./env.sh
sed -i "s/${ROCK_HEAP_MIN}/${HEAP_MIN}/g" ./env.sh
sed -i "s/${ROCK_META_MAX}/${META_MAX}/g" ./env.sh
sed -i "s/${ROCK_META_MIN}/${META_MIN}/g" ./env.sh
}

log_dir_create()
{
mkdir -p $LOG_HOME
}

env_create
env_setup
#log_dir_create

