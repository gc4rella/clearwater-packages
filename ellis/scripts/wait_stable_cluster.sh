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

# Wait until the cluster is stable

while [ -z "$(cw-check_cluster_state | grep stable)" ];do
	echo "cluster is not yet created"
	sleep 5s
done

while [ ! -z "$(cw-check_cluster_state | grep stable | grep not)" ];do
	echo "cluster is not yet stable"
	sleep 5s
done

