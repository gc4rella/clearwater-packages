#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# clearwater shared conf script

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

if [ -f "$clearwater_conf_dir/shared_config" ];then
	rm $clearwater_conf_dir/shared_config
fi

if [ -f "$clearwater_conf_dir/shared_config_template" ];then
	cp $clearwater_conf_dir/shared_config_template $clearwater_conf_dir/shared_config
fi

sleep 10s

# try to upload the shared config a few times
for i in {0..10}
do
	sudo cw-upload_shared_config >> $log 2>&1
 	sleep 5s
done



