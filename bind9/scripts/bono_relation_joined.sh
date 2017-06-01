#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# clearwater relation script

#foreign="bono"
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

# copy bono related information
if [ -f "$REALMFILE" ] && [ -z "$(cat $REALMFILE | grep $foreign)" ];then
cat >> $REALMFILE <<EOL
bono-1                 IN A     VAR_BONO_MGMT
@                      IN A     VAR_BONO_MGMT
@                      IN NAPTR 1 1 "S" "SIP+D2T" "" _sip._tcp
@                      IN NAPTR 2 1 "S" "SIP+D2U" "" _sip._udp
_sip._tcp              IN SRV   0 0 5060 bono-1
_sip._udp              IN SRV   0 0 5060 bono-1
EOL
fi

# TODO : enable scaling 
source $SCRIPTS_PATH/relation_joined.sh

# the generic relation_joined handles replacing the ip afterwards
