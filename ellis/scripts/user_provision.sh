#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# clearwater ellis user script

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

while [ ! -f "$clearwater_conf_dir/shared_config" ];do
	echo "shared conf has not been created yet, waiting"
	sleep 5s
done

while [ ! -z "$(cat $clearwater_conf_dir/shared_config | grep 'No Shared Config has been provided')" ];do
	echo "shared conf has not been shared yet, waiting for an update"
	sleep 5s
done

if [ "$provision_users" = "false" ];then
	echo "no users need to be provisioned"
	exit 0
fi

sleep 120s

sudo bash -c "export PATH=/usr/share/clearwater/ellis/env/bin:$PATH ; cd /usr/share/clearwater/ellis/src/metaswitch/ellis/tools/ ; python create_numbers.py --start 6505550000 --count 1000"
