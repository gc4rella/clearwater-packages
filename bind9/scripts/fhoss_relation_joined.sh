#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# clearwater relation script

#foreign="fhoss"
# we can read the relation name by the name of the script!
foreign=$(echo $0 | rev | cut -d "/" -f 1 | rev | cut -d "_" -f 1)

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

# copy fhoss related information
if [ -f "$REALMFILE" ] && [ -z "$(cat $REALMFILE | grep $foreign)" ];then
	echo "fhoss                IN A     VAR_FHOSS_MGMT" >> $REALMFILE
	echo "$fhoss_hostname      IN A     VAR_FHOSS_MGMT" >> $REALMFILE
	echo "hss                  IN A     VAR_FHOSS_MGMT" >> $REALMFILE
fi

# TODO : enable scaling 
source $SCRIPTS_PATH/relation_joined.sh
