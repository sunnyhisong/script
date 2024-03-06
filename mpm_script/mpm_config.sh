#!/bin/bash


###CPU CORE COUNT###
APACHE_CORE_COUNT=4

###APACHE SERVER COUNT###
APACHE_SERVER_COUNT=4

###MPM TYPE(prefork,worker,event,winnt###
APACHE_MPM_TYPE=winnt

###There is firewall between WEB and WAS(yes or no)###
SAME_SERVER=no

###typo counter###
function typo_counter {
if [[ $counter -eq 3 ]] ;
then
	exit
fi
}



function server_default_value {

###SERVER CORE COUNT###
counter=0 ##ERROR COUNTER
while [ $counter -le 2 ]
do

	re='^[0-9]+$'
read -p "apache core count (default : 1 ) : " APACHE_CORE_COUNT
APACHE_CORE_COUNT=${APACHE_CORE_COUNT:-1}

if ! [[ $APACHE_CORE_COUNT =~ $re ]] ; 
then
	echo "NO NUMBER"
	((counter++)) 

else
	echo "core count : $APACHE_CORE_COUNT"
	break;
fi

done

typo_counter



###APACHE SERVER COUNT###
counter=0 ##ERROR COUNTER
while [ $counter -le 2 ]
do

re='^[0-9]+$'
read -p "apache server count (default: 1) : " APACHE_SERVER_COUNT
APACHE_SERVER_COUNT=${APACHE_SERVER_COUNT:-1}

if ! [[ $APACHE_SERVER_COUNT =~ $re ]] ; 
then
	echo "NO NUMBER"
else
	echo "server count : $APACHE_SERVER_COUNT"
	break;
fi

done

typo_counter


###APACHE MPM TYPE###
counter=0 ##ERROR COUNTER
while [ $counter -le 2 ]
do

read -p "mpm type (default: worker) : " APACHE_MPM_TYPE \n
APACHE_MPM_TYPE=${APACHE_MPM_TYPE:-worker}

if [[ $APACHE_MPM_TYPE = "prefork" ]]||
   [[ $APACHE_MPM_TYPE = "worker" ]] ||
   [[ $APACHE_MPM_TYPE = "event" ]] ||
   [[ $APACHE_MPM_TYPE = "winnt" ]] ;
then
	echo "mpm : ${APACHE_MPM_TYPE}"
	break;
else
	echo "MPM is without"
	((counter++))
fi

done

typo_counter



###WEB/WAS SAME SERVER###
counter=0 ##ERROR COUNTER
while [ $counter -le 2 ]
do

read -p "WEB WAS SAME SERVER (yes(y) or no(n)) : " SAME_SERVER \n
SAME_SERVER=${SAME_SERVER:-no}

case $SAME_SERVER in
	yes|y)
		echo "yes"	
		break;
		;;
	no|n)
		echo "no"
		break;
		;;
	*)
		echo "uhm"
		((counter++))
esac

done

typo_counter

}



function mpm_value {
## apacheTotalInstances
APACHE_TOTAL_INSTANCES=$APACHE_SERVER_COUNT


## apache_max_clients
if [[ $APACHE_MPM_TYPE = "prefork" ]] ;
then	
	APACHE_MAX_CLIENTS=$((APACHE_CORE_COUNT * 200))
    
elif [[ $APACHE_MPM_TYPE = "worker" ]] ||
     [[ $APACHE_MPM_TYPE = "event" ]] ||
     [[ $APACHE_MPM_TYPE = "winnt" ]] ;
then
	APACHE_MAX_CLIENTS=$((APACHE_CORE_COUNT * 300))
fi


if [[ $SAME_SERVER = "yes" ]] ||
   [[ $SAME_SERVER = "y" ]] ;
then
	APACHE_MAX_CLIENTS=$((APACHE_MAX_CLIENTS / 2))
fi   


### apache_threads_per_child_worker
if [[ $APACHE_MPM_TYPE = "worker" ]] ||
   [[ $APACHE_MPM_TYPE = "event" ]] ;
then
	if [[ $APACHE_MAX_CLIENTS -le 1200 ]] ;
	then
		APACHE_THREADS_PER_CHILD_WORKER=$((APACHE_MAX_CLIENTS / 10))
	elif [[ $APACHE_MAX_CLIENTS -gt 1200 ]] && [[ $APACHE_MAX_CLIENTS -le 2400 ]] ;
	then
		APACHE_THREADS_PER_CHILD_WORKER=$((APACHE_MAX_CLIENTS / 16))
	else
		APACHE_THREADS_PER_CHILD_WORKER=$((APACHE_MAX_CLIENTS / 20))
	fi
	APACHE_PROCESSES=$((APACHE_MAX_CLIENTS / APACHE_THREADS_PER_CHILD_WORKER)) 
				

elif [[ $APACHE_MPM_TYPE = "winnt" ]] ||
     [[ $APACHE_MPM_TYPE = "prefork" ]] ;
then
	APACHE_THREADS_PER_CHILD_WORKER=$APACHE_MAX_CLIENTS	
	APACHE_PROCESSES=1
fi


### apache_total_threads
APACHE_TOTAL_THREADS=$((APACHE_SERVER_COUNT * APACHE_MAX_CLIENTS))


}


function mpm_config {

if [[ $APACHE_MPM_TYPE = "event" ]] ;
then
     echo       "<IfModule mpm_event_module>" #>> httpd-mpm.conf
     echo       "ThreadLimit              $APACHE_THREADS_PER_CHILD_WORKER" #>> httpd-mpm.conf
     echo       "ServerLimit              $APACHE_PROCESSES" #>> httpd-mpm.conf
     echo       "StartServers             3" #>> httpd-mpm.conf
     echo       "MinSpareThreads          5" #>> httpd-mpm.conf
     echo       "MaxSpareThreads          20" #>> httpd-mpm.conf
     echo       "AsyncRequestWorkerFactor 2" #>> httpd-mpm.conf
     echo       "ThreadsPerChild          $APACHE_THREADS_PER_CHILD_WORKER" #>> httpd-mpm.conf
     echo       "MaxRequestWorkers        $APACHE_MAX_CLIENTS" #>> httpd-mpm.conf
     echo       "MaxConnectionsPerChild   0" #>> httpd-mpm.conf
     echo       "</IfModule>"		      #>> httpd-mpm.conf

fi

if [[ $APACHE_MPM_TYPE = "prefork" ]] ;
then
     echo       "<IfModule mpm_prefork_module>" #>> httpd-mpm.conf
     echo       "ServerLimit              $APACHE_MAX_CLIENTS" #>> httpd-mpm.conf
     echo       "StartServers             5" #>> httpd-mpm.conf
     echo       "MinSpareThreads          5" #>> httpd-mpm.conf
     echo       "MaxSpareThreads          20" #>> httpd-mpm.conf
     echo       "MaxRequestWorkers        $APACHE_MAX_CLIENTS" #>> httpd-mpm.conf
     echo       "MaxConnectionsPerChild   0" #>> httpd-mpm.conf
     echo       "</IfModule>"                 #>> httpd-mpm.conf

fi

if [[ $APACHE_MPM_TYPE = "worker" ]] ;
then
     echo       "<IfModule mpm_worker_module>" #>> httpd-mpm.conf
     echo       "ThreadLimit              $APACHE_THREADS_PER_CHILD_WORKER " #>> httpd-mpm.conf
     echo       "ServerLimit              $APACHE_PROCESSES" #>> httpd-mpm.conf
     echo       "StartServers             3" #>> httpd-mpm.conf
     echo       "MinSpareThreads          5" #>> httpd-mpm.conf
     echo       "MaxSpareThreads          20" #>> httpd-mpm.conf
     echo       "ThreadsPerChild          $APACHE_THREADS_PER_CHILD_WORKER" #>> httpd-mpm.conf
     echo       "MaxRequestWorkers        $APACHE_MAX_CLIENTS" #>> httpd-mpm.conf
     echo       "MaxConnectionsPerChild   0" #>> httpd-mpm.conf
     echo       "</IfModule>"                 #>> httpd-mpm.conf

fi

if [[ $APACHE_MPM_TYPE = "winnt" ]] ;
then
     echo       "<IfModule mpm_winnt_module>" #>> httpd-mpm.conf
     echo       "ThreadLimit              $APACHE_THREADS_PER_CHILD_WORKER" #>> httpd-mpm.conf
     echo       "ThreadsPerChild          $APACHE_THREADS_PER_CHILD_WORKER" #>> httpd-mpm.conf
     echo       "MaxConnectionsPerChild   0" #>> httpd-mpm.conf
     echo       "</IfModule>"                 #>> httpd-mpm.conf

fi


}



#server_default_value
mpm_value
mpm_config
