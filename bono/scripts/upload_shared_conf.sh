#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# clearwater shared conf script

serv="bono_install"

#cw_root_config_path="/root/clearwater-config-manager"
cw_root_config_path="/home/ubuntu/clearwater-config-manager"

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

# First step download existing versions of the shared_config which we will be replacing anyway..
# cw-config --autoconfirm --force download shared_config >> $log 2>&1
screen -S $serv -p 0 -X stuff "sudo cw-config --autoconfirm --force download shared_config $(printf \\r)"

if [ -f "$clearwater_conf_dir/shared_config" ];then
	rm $clearwater_conf_dir/shared_config
fi

if [ ! -d "$cw_root_config_path" ];then
	mkdir $cw_root_config_path
fi

if [ ! -d "$cw_root_config_path/root" ];then
	mkdir $cw_root_config_path/root
fi

if [ -f "$clearwater_conf_dir/shared_config_template" ];then
	#cp $clearwater_conf_dir/shared_config_template $clearwater_conf_dir/shared_config
	#cp $clearwater_conf_dir/shared_config_template $cw_root_config_path/shared_config
	echo "Replacing shared_config file in $cw_root_config_path/root"
	if [ -f "$cw_root_config_path/root/shared_config" ];then
		rm $cw_root_config_path/root/shared_config -fr
	fi
	cp $clearwater_conf_dir/shared_config_template $cw_root_config_path/root/shared_config
fi

#if [ ! -f "$cw_root_config_path/root/.shared_config.index" ];then
#	echo "14" > $cw_root_config_path/root/.shared_config.index
#fi

#sleep 10s

# try to upload the shared config a few times
for i in {0..10}
do
	#sudo cw-upload_shared_config >> $log 2>&1 
        #cw-config --autoconfirm --force upload shared_config >> $log 2>&1
	screen -S $serv -p 0 -X stuff "sudo cw-config --autoconfirm --force upload shared_config $(printf \\r)"
 	sleep 5s
done



