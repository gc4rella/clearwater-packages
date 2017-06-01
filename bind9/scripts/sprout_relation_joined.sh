#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# clearwater relation script

#foreign="sprout"
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

# copy sprout related information
if [ -f "$REALMFILE" ] && [ -z "$(cat $REALMFILE | grep $foreign)" ];then
cat >> $REALMFILE <<EOL
sprout-1               IN A     VAR_SPROUT_MGMT
sprout                 IN A     VAR_SPROUT_MGMT
scscf.sprout           IN A     VAR_SPROUT_MGMT
sprout                 IN NAPTR 1 1 "S" "SIP+D2T" "" _sip._tcp.sprout
_sip._tcp.sprout       IN SRV   0 0 5054 sprout-1
scscf.sprout           IN NAPTR 1 1 "S" "SIP+D2T" "" _sip._tcp.scscf.sprout
_sip._tcp.scscf.sprout IN SRV   0 0 5054 sprout-1
icscf.sprout           IN A     VAR_SPROUT_MGMT
icscf.sprout           IN NAPTR 1 1 "S" "SIP+D2T" "" _sip._tcp.icscf.sprout
_sip._tcp.icscf.sprout IN SRV   0 0 5052 sprout-1
EOL
fi

# TODO : enable scaling 
source $SCRIPTS_PATH/relation_joined.sh

# the generic relation_joined handles replacing the ip afterwards
