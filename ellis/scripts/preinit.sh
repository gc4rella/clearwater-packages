#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# clearwater install script



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

# initially the log should be empty
if [ ! -z "$(cat $log | grep $clearwater_role\_preinit_finished)" ];then
	echo "preinit for $clearwater_role was already done"
	exit 0
fi

# install clearwater from packages
if [ ! $downloadPackages = "false" ];then
	# clear the log
	echo "" > $log
	# check if we have already created the apt repo file
	if [ ! -f "$clearwater_apt_file" ];then
		echo "$clearwater_apt_repo" >> $clearwater_apt_file
	fi
	# install signing key
	curl -L $clearwater_key_repo | sudo apt-key add -
	# update repo list
	apt-get update >> $log 2>&1
	apt-get install -y -q $install_packages >> $log 2>&1
fi

# check if the config file exists
if [ ! -d "$clearwater_conf_dir" ];then
	mkdir $clearwater_conf_dir
	cp $SCRIPTS_PATH/local_config $clearwater_conf_dir/$clearwater_conf_file
else
	if [ ! -f "$clearwater_conf_file" ];then
		cp $SCRIPTS_PATH/local_config $clearwater_conf_dir/$clearwater_conf_file
	fi
fi

# if there is not yet the file where we store our relation depending information, create it 
if [ ! -f "$SCRIPTS_PATH/$relation_bucket" ];then
	touch $SCRIPTS_PATH/$relation_bucket
fi

if [ -z "$(eval echo \$$clearwater_net)" ];then
	echo "$clearwater_role does not seem to have a private ip on $clearwater_net"
fi 
if [ -z "$(eval echo \$$clearwater_net_$floating)" ];then
	echo "$clearwater_role does not seem to have a public ip on $clearwater_net"
fi 

# save the variables
if [ -f "$SCRIPTS_PATH/$relation_bucket" ]; then
	source $SCRIPTS_PATH/$relation_bucket
	printf "$clearwater_role$private=%s\n" \"$(eval echo \$$clearwater_net)\" >> $SCRIPTS_PATH/$relation_bucket
	printf "$clearwater_role$public=%s\n" \"$(eval echo \$$clearwater_net$floating)\" >> $SCRIPTS_PATH/$relation_bucket
fi

# create a virtual environment to work in
if [ ! -d "$virtual_env" ];then
	mkdir $virtual_env
	cd $virtual_env
	virtualenv $clearwater_role --no-site-packages	
fi

# throw the install finish into the log file so we wont run this script twice
echo "$clearwater_role\_preinit_finished" >> $log

