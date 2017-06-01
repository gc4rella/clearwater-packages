#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# clearwater scscf script

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
	cp $SCRIPTS_PATH/s-cscf.json $clearwater_conf_dir/s-cscf_template.json
	cat $clearwater_conf_dir/s-cscf_template.json | sed "s/\VAR_DNS_REALM/$dns_realm/g" > $tmp_var && mv $tmp_var $clearwater_conf_dir/s-cscf_template.json
	if [ -f "$clearwater_conf_dir/s-cscf.json" ];then
		rm $clearwater_conf_dir/s-cscf.json
	fi
	cp $clearwater_conf_dir/s-cscf_template.json $clearwater_conf_dir/s-cscf.json
	# try to upload the scscf config a few times
	for i in {0..10}
	do
		sudo cw-upload_scscf_json >> $log 2>&1
	 	sleep 5s
	done
fi 


