#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# clearwater conf generation

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
if [ ! -z "$(cat $log | grep $clearwater_role\_chronos_generate_finished)" ];then
	echo "config generation for $clearwater_role chronos was already done"
	exit 0
fi

# get the variables
if [ -f "$SCRIPTS_PATH/$relation_bucket" ]; then
	source $SCRIPTS_PATH/$relation_bucket
fi

local_ip=$(cat $SCRIPTS_PATH/$relation_bucket | grep $clearwater_role | grep "private" | cut -d "=" -f2 | cut -d "\"" -f2)
public_ip=$(cat $SCRIPTS_PATH/$relation_bucket | grep $clearwater_role | grep "public" | cut -d "=" -f2 | cut -d "\"" -f2)

if [ -z "$hostname" ];then
	hostname=$(hostname)
fi

echo "local_ip=$local_ip"

if [ ! -d "$clearwater_chronos_conf_dir" ];then
	mkdir $clearwater_chronos_conf_dir
fi
chron_path="$clearwater_chronos_conf_dir/$clearwater_chronos_conf_file"
if [ ! -f "$chron_path" ];then
	if [ -f "$SCRIPTS_PATH/$clearwater_chronos_conf_file" ];then
		cp $SCRIPTS_PATH/$clearwater_chronos_conf_file $chron_path
	else
		echo "There was no chronos.conf in $SCRIPTS_PATH"
	fi
fi 

# check if the config file exists
if [ -f "$chron_path" ];then
	echo "found chronos config"
	cat $chron_path | sed "s/\.*bind-address =.*/bind-address = $local_ip/" > $tmp_var && mv $tmp_var $chron_path
else
	echo "did not found chronos config file at $chron_path"
fi

# throw the generate finish into the log file so we wont run this script twice
echo "$clearwater_role\_chronos_generate_finished" >> $log

