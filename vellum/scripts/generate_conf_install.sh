#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# clearwater conf generation

perform_screen_install()
{
	if [ -z "$command" ];then
		echo "no command specified"
		exit 0
	fi
	if [ -z "$serv" ];then
		echo "no service specified"
		exit 0
	fi
	screen -dmS $serv
	screen -S $serv -p 0 -X stuff "bash$(printf \\r)"
	sleep 1s
	screen -S $serv -p 0 -X stuff "PATH=$(echo $PATH:/usr/local/bin)$(printf \\r)"
	sleep 1s
	screen -S $serv -p 0 -X stuff "sudo su ubuntu$(printf \\r)"
	if [ -d "$virtual_env/$clearwater_role" ];then
		sleep 1s
		screen -S $serv -p 0 -X stuff "cd $virtual_env/$clearwater_role/bin $(printf \\r)"
		screen -S $serv -p 0 -X stuff "source activate $(printf \\r)"
	else
		echo "Did not found virtual environment for $clearwater_role"
	fi

	sleep 1s
	chown ubuntu:ubuntu $log
	command="$command && echo "$clearwater_role\_generate_finished" >> $log"
	screen -S $serv -p 0 -X stuff "$command $(printf \\r)"
	# At this point the script keeps running , we just outsourced the install to the screen
}

install_bono()
{
	command='sudo DEBIAN_FRONTEND=noninteractive apt-get install bono restund -y && sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management -y'
	serv="bono_install"
	perform_screen_install
	
}
install_dime()
{
	command='sudo DEBIAN_FRONTEND=noninteractive apt-get install dime clearwater-prov-tools -y && sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management -y'
	serv="dime_install"
	perform_screen_install
}
install_ellis()
{
	command='sudo DEBIAN_FRONTEND=noninteractive apt-get install ellis -y && sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management -y'
	serv="ellis_install"
	perform_screen_install
}
install_homer()
{
	command='sudo DEBIAN_FRONTEND=noninteractive apt-get install homer -y && sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management -y'
	if [ "$install_clearwater_cassandra" = "true" ];then
		command="$command && sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-cassandra -y"
	fi
	serv="homer_install"
	perform_screen_install
}
install_sprout()
{
	command='sudo DEBIAN_FRONTEND=noninteractive apt-get install sprout -y && sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management -y'
	if [ "$install_clearwater_cassandra" = "true" ];then
		command="$command && sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-cassandra -y"
	fi
	if [ "$install_clearwater_memento" = "true" ];then
		command="$command && sudo DEBIAN_FRONTEND=noninteractive apt-get install memento memento-nginx -y"
	fi
	if [ "$install_clearwater_as" = "true" ];then
		command="$command && sudo DEBIAN_FRONTEND=noninteractive apt-get install memento-as memento-nginx -y"
	fi
	if [ "$install_clearwater_memento" = "$install_clearwater_as" ];then
		echo "You are trying to install packages for precise and trusty at the same time, seems you messed up the default config file..."
		exit 1
	fi
	serv="sprout_install"
	perform_screen_install
}
install_vellum()
{
	command='sudo DEBIAN_FRONTEND=noninteractive apt-get install vellum -y && sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management -y'
	if [ "$install_memento_cassandra" = "true" ];then
		command="$command && sudo DEBIAN_FRONTEND=noninteractive apt-get install memento-cassandra -y"
	fi
	serv="vellum_install"
	perform_screen_install
}
install_ralf()
{
	command='sudo DEBIAN_FRONTEND=noninteractive apt-get install ralf -y && sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management -y'
	serv="ralf_install"
	perform_screen_install
}
install_homestead()
{
	command='sudo DEBIAN_FRONTEND=noninteractive apt-get install homestead homestead-prov -y && sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management -y'
	if [ "$install_clearwater_cassandra" = "true" ];then
		command="$command && sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-cassandra -y"
	fi
	serv="homestead_install"
	perform_screen_install
}



export DEBIAN_FRONTEND=noninteractive

# If there are default options load them 
if [ -f "$SCRIPTS_PATH/default_options" ]; then
	source $SCRIPTS_PATH/default_options
fi

if [ -z "$SCRIPTS_PATH" ]; then
	echo "$SERVICE : Using default script path $SCRIPTS_PATH"
	SCRIPTS_PATH="/opt/openbaton/scripts"
else
	echo "$SERVICE : Using custom script path $SCRIPTS_PATH"
fi

# check if we have generated the config already
if [ ! -z "$(cat $log | grep $clearwater_role\_generate_finished)" ];then
	echo "config generation for $clearwater_role was already done"
	exit 0
fi

# get the variables
if [ -f "$SCRIPTS_PATH/$relation_bucket" ]; then
	source $SCRIPTS_PATH/$relation_bucket
fi

# check if we have all necessary information
necessary_relation="bono dime ellis homer sprout vellum ralf homestead"
relation_list=$(cat $SCRIPTS_PATH/$relation_bucket | grep private )

for comp in $necessary_relation; do
        if [ -z "$(echo $relation_list | grep $comp)" ];then
		echo "private ip of $comp is missing!"
	fi
done

# Build up the etcd cluster for the conf file
# there we will use the private ips

cluster=""
for comp in $necessary_relation; do
	ip=$(cat $SCRIPTS_PATH/$relation_bucket | grep private | grep $comp | cut -d "=" -f2 | cut -d "\"" -f2)
	if [ ! -z "$ip" ];then
		echo "$comp is available at $ip"
		if [ -z "$cluster" ];then
			cluster=$ip
		else
			cluster=$cluster,$ip
		fi
	fi
done

local_ip=$(cat $SCRIPTS_PATH/$relation_bucket | grep $clearwater_role | grep "private" | cut -d "=" -f2 | cut -d "\"" -f2)
public_ip=$(cat $SCRIPTS_PATH/$relation_bucket | grep $clearwater_role | grep "public" | cut -d "=" -f2 | cut -d "\"" -f2)

if [ -z "$public_ip" ];then
	public_ip=$local_ip
fi

if [ -z "$hostname" ];then
	hostname=$(hostname)
fi

# TODO : enable scaling, therefor the machine running this script needs to know a few more details
hostname=$clearwater_role-1

echo "local_ip=$local_ip"
echo "public_ip=$public_ip"
echo "hostname=$hostname"
echo "etcd_cluser=\"$cluster\""

# check if the config file exists
if [ -f "$clearwater_conf_dir/$clearwater_conf_file" ];then
	echo "found config"
	cat $clearwater_conf_dir/$clearwater_conf_file | sed "s/\.*local_ip=.*/local_ip=$local_ip/" > $tmp_var && mv $tmp_var $clearwater_conf_dir/$clearwater_conf_file
	cat $clearwater_conf_dir/$clearwater_conf_file | sed "s/\.*public_ip=.*/public_ip=$public_ip/" > $tmp_var && mv $tmp_var $clearwater_conf_dir/$clearwater_conf_file
	cat $clearwater_conf_dir/$clearwater_conf_file | sed "s/\.*public_hostname=.*/public_hostname=$hostname/" > $tmp_var && mv $tmp_var $clearwater_conf_dir/$clearwater_conf_file
	cat $clearwater_conf_dir/$clearwater_conf_file | sed "s/\.*etcd_cluster=.*/etcd_cluster=\"$cluster\"/" > $tmp_var && mv $tmp_var $clearwater_conf_dir/$clearwater_conf_file
else
	echo "did not found config file"
fi

# Workaround to get clearwater working ( so we delete all the stuff the ems was copying! )
# TODO : find a better solution on that since it is very dirty and may blow up other setups!!!
if [ ! -z "$(ls /usr/local/lib/python2.7/dist-packages)" ];then
	rm -fr /usr/local/lib/python2.7/dist-packages/*
fi

install_$clearwater_role

while [ -z "$(cat $log | grep $clearwater_role\_generate_finished )" ];do
	echo "installation is still in progress"
	sleep 5s
done

# Additionally
echo "nameserver $dns_ip" > /etc/dnsmasq.resolv.conf
echo "" >> /etc/default/dnsmasq
echo "RESOLV_CONF=/etc/dnsmasq.resolv.conf" >> /etc/default/dnsmasq
service dnsmasq restart

# start the etcd service to form the cluster...

screen -S $serv -p 0 -X stuff "sudo service clearwater-etcd start $(printf \\r)" 


