#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# clearwater scscf script

serv="sprout_install"

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

# get the variables
if [ -f "$SCRIPTS_PATH/$relation_bucket" ]; then
	source $SCRIPTS_PATH/$relation_bucket
fi

if [ -f "$SCRIPTS_PATH/s-cscf.json" ];then
	# First step download existing versions of the scscf-json which we will be replacing anyway..
	#cw-config --autoconfirm --force download scscf_json >> $log 2>&1
	screen -S $serv -p 0 -X stuff "sudo cw-config --autoconfirm --force download scscf_json $(printf \\r)"
	cp $SCRIPTS_PATH/s-cscf.json $clearwater_conf_dir/s-cscf_template.json
	cat $clearwater_conf_dir/s-cscf_template.json | sed "s/\VAR_DNS_REALM/$dns_realm/g" > $tmp_var && mv $tmp_var $clearwater_conf_dir/s-cscf_template.json
	if [ ! -d "$cw_root_config_path" ];then
		mkdir $cw_root_config_path
	fi
	if [ ! -d "$cw_root_config_path/root" ];then
		mkdir $cw_root_config_path/root
	fi
	if [ -f "$clearwater_conf_dir/s-cscf.json" ];then
		rm $clearwater_conf_dir/s-cscf.json
	fi
	#cp $clearwater_conf_dir/s-cscf_template.json $clearwater_conf_dir/s-cscf.json
	#cp $clearwater_conf_dir/s-cscf_template.json $cw_root_config_path/s-cscf.json
	echo "Replacing s-cscf.json file in $cw_root_config_path/root/"
	if [ -f "$cw_root_config_path/root/s-cscf.json" ];then
		rm $cw_root_config_path/root/s-cscf.json -fr
	fi
	cp $clearwater_conf_dir/s-cscf_template.json $cw_root_config_path/root/s-cscf.json
	#if [ ! -f "$cw_root_config_path/root/.s-cscf.json.index" ];then
	#	echo "26" > $cw_root_config_path/root/.s-cscf.json.index
	#fi
	# try to upload the scscf config a few times
	for i in {0..10}
	do
		#sudo cw-upload_scscf_json >> $log 2>&1
		#cw-config --autoconfirm --force upload scscf_json >> $log 2>&1
		screen -S $serv -p 0 -X stuff "sudo cw-config --autoconfirm --force upload scscf_json $(printf \\r)"
	 	sleep 5s
	done
fi 


