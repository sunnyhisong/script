#!/bin/sh
# That make script for controller
# Enter servername to list file 

SLAVE_DIR="/WAS/JBOSS/DOMAINS/SLAVE02"
ENV_FILE="$SLAVE_DIR/bin/env.sh";
SERVER_DIR="$SLAVE_DIR/servers";

if [ ! -f "./SET/server.list" ]
then
    echo "server.list file is required"
    exit
fi

# without password from remote controller
if [ "e$2" != "e" ];
then
  user="--user='$2'" 
  if [ "e$3" != "e" ];
  then
    password="--password='$3'"
  else
    echo "Password is required : Remote Controller"
    echo $"Remote Usage: $0 set --user='username' --password='password'"
    exit
  fi
fi


make_start(){
    echo "#!/bin/sh" > $SERVER_DIR/$servername/bin/start.sh
    echo ". $ENV_FILE" >> $SERVER_DIR/$servername/bin/start.sh
    echo "" >> $SERVER_DIR/$servername/bin/start.sh
    echo "echo \"$servername start...\"" >> $SERVER_DIR/$servername/bin/start.sh
    echo "unset JAVA_OPTS" >> $SERVER_DIR/$servername/bin/start.sh 
    echo "rm -rf $SERVER_DIR/$servername/tmp/*" >> $SERVER_DIR/$servername/bin/start.sh 
    echo "\$JBOSS_HOME/bin/jboss-cli.sh $user $password --connect --controller=\$DOMAIN_MASTER_ADDR:\$DOMAIN_MASTER_PORT --command=/host=\$SERVER_NAME/server-config=$servername:start" >> $SERVER_DIR/$servername/bin/start.sh 
}

make_stop(){
    echo "#!/bin/sh" > $SERVER_DIR/$servername/bin/stop.sh
    echo ". $ENV_FILE" >> $SERVER_DIR/$servername/bin/stop.sh
    echo "" >> $SERVER_DIR/$servername/bin/stop.sh
    echo "echo \"$servername stop...\"" >> $SERVER_DIR/$servername/bin/stop.sh
    echo "unset JAVA_OPTS" >> $SERVER_DIR/$servername/bin/stop.sh
    echo "\$JBOSS_HOME/bin/jboss-cli.sh $user $password --connect --controller=\$DOMAIN_MASTER_ADDR:\$DOMAIN_MASTER_PORT --command=/host=\$SERVER_NAME/server-config=$servername:stop" >> $SERVER_DIR/$servername/bin/stop.sh
}

make_kill(){
    echo "#!/bin/sh" > $SERVER_DIR/$servername/bin/kill.sh
    echo "" >> $SERVER_DIR/$servername/bin/kill.sh
    echo "ps -ef | grep java | grep \"\-D\[Server:$servername\] \" | awk {'print \"kill -9 \" \$2'} | sh -x" >> $SERVER_DIR/$servername/bin/kill.sh
}

make_status(){
    echo "#!/bin/sh" > $SERVER_DIR/$servername/bin/status.sh
    echo "" >> $SERVER_DIR/$servername/bin/status.sh
    echo "ps -ef | grep java | grep --color \"\-D\[Server:$servername\] \"" >> $SERVER_DIR/$servername/bin/status.sh
}

make_tail(){
    echo "#!/bin/sh" > $SERVER_DIR/$servername/bin/tail.sh
    echo "" >> $SERVER_DIR/$servername/bin/tail.sh
    echo "tail -f $SERVER_DIR/$servername/log/server.log" >> $SERVER_DIR/$servername/bin/tail.sh
}

make_dump(){
    echo "#!/bin/sh" > $SERVER_DIR/$servername/bin/dump.sh
    echo "" >> $SERVER_DIR/$servername/bin/dump.sh
    echo "ps -ef | grep java | grep \"\-D\[Server:$servername\] \" | awk {'print \"kill -3 \" \$2'} | sh -x" >> $SERVER_DIR/$servername/bin/dump.sh
}

make_all_start(){
    if [ ! -f "$SERVER_DIR/all_start.sh" ];
    then
        echo "#!/bin/sh" > $SERVER_DIR/all_start.sh
        echo "" >> $SERVER_DIR/all_start.sh
    fi

    echo "$SERVER_DIR/$servername/bin/start.sh" >> $SERVER_DIR/all_start.sh
}

make_all_stop(){
    if [ ! -f "$SERVER_DIR/all_stop.sh" ];
    then
        echo "#!/bin/sh" > $SERVER_DIR/all_stop.sh
        echo "" >> $SERVER_DIR/all_stop.sh
    fi

    echo "$SERVER_DIR/$servername/bin/stop.sh" >> $SERVER_DIR/all_stop.sh
}
 
make_dir(){
    rm -rf $SERVER_DIR/$servername/bin
    mkdir -p $SERVER_DIR/$servername/bin -p
}

remove_all_script(){
    #rm -rf $SERVER_DIR
    rm -f $SERVER_DIR/all_*.sh 
}

make_symbolic(){
    ln -s $SERVER_DIR/$servername/bin $servername
    mv $servername $SLAVE_DIR/bin/.
}

# See how we were called.
case "$1" in
  init) 
    echo "Remove $SERVER_DIR ..."
    remove_all_script
    ;;
  set)
    for servername in $(cat ./SET/server.list)
    do
	if [[ $servername =~ ^# ]]; then
          continue 
        fi	

        echo "setting $SERVER_DIR/$servername ..."

        make_dir

        # make script
        make_start
        make_stop
        make_status
        make_kill
        make_tail
        make_dump
        make_symbolic
        

        make_all_start
        make_all_stop

        chmod 700 $SERVER_DIR/$servername/bin/*.sh
        chmod 700 $SERVER_DIR/all_*.sh
    done
    ;;
  *)
    echo $"Local Usage: $0 {set|init}"
    echo $"Remote Usage: $0 set --user='username' --password='password'"
    exit 2
esac

exit $?
