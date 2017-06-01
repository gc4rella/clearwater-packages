#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

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

# dns_realm points to bono
# hs = homestead , ralf and homestead are running on dime, thus check for them instead for dime directly
# icscf,scscf are running on the sprout nodes
environement="$dns_realm ellis fhoss homer vellum hs ralf sprout icscf.sprout scscf.sprout"

for serv in $environement; do
	# wait for each service to be reachable
	until ping -c1 $serv &>/dev/null; do : && echo "waiting for $serv" && sleep 2s; done
done
echo "All services are reachable, waiting for ralf connection to be established"
while ! nc -z ralf 10888; do   
	sleep 2s
done
echo "Ralf is reachable, finished"
