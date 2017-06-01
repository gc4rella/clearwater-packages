#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# fhoss generate config script.

# First step is to check if fhoss is running already to avoid messing up the config
# files due to a component scaling 
check=$(screen -ls | grep fhoss )
if [ ! -z "$check" ];then
	exit 0
fi

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


# TODO : reenable the usage of the configuration
fhoss_port="3868"
name="fhoss"


# TODO : the values for homestead connection ( actually a connection to dime in the view of vnf-packages ) 
#	 should be dynamic and not static
homestead="hs"
homestead_port="3868"


VARIABLE_BUCKET="$SCRIPTS_PATH/.variables"

HSS_VARIABLE_USERS_FILE="$SCRIPTS_PATH/var_user_data.sql"
HSS_VARIABLE_DIAMETER_PEER="$SCRIPTS_PATH/var_dia_peer.xml"

if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
fi

if [ -z "$realm" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no realm for bind9!"
	exit 1
fi

# First thing to do is to add the cdp peer to dime to our template config file
if [ -f "$HSS_VARIABLE_DIAMETER_PEER" ];then
	python $SCRIPTS_PATH/$ADD_CDP_SCRIPT $homestead $realm $homestead_port $HSS_VARIABLE_DIAMETER_PEER $HSS_VARIABLE_DIAMETER_PEER
fi

# Copy our template files to the correct location
if [ -f "$HSS_USERS_FILE" ];then
	rm $HSS_USERS_FILE
fi
cp $HSS_VARIABLE_USERS_FILE $HSS_USERS_FILE	
if [ -f "$HSS_DIAMETER_PEER_FILE" ];then
	rm $HSS_DIAMETER_PEER_FILE
fi
cp $HSS_VARIABLE_DIAMETER_PEER $HSS_DIAMETER_PEER_FILE	

# clearwater specific, these can be changed by the shared config which is uploaded by bono, another way would be to
# join the etcd cluster and receive these values directly
scscf_name="scscf.sprout"
scscf_port="5054"

# TODO : reanble scscf ( OpenIMSCore ) relation , disabled for clearwater

# Fill the templates

if [ -f "$HSS_VARIABLE_USERS_FILE" ];then
	cat $HSS_VARIABLE_USERS_FILE | sed "s/\VAR_DNS_REALM/$realm/g" > $TMP_FILE && mv $TMP_FILE $HSS_VARIABLE_USERS_FILE
	cat $HSS_VARIABLE_USERS_FILE | sed "s/\VAR_SCSCF_NAME/$scscf_name/g" > $TMP_FILE && mv $TMP_FILE $HSS_VARIABLE_USERS_FILE
	cat $HSS_VARIABLE_USERS_FILE | sed "s/\VAR_SCSCF_PORT/$scscf_port/g" > $TMP_FILE && mv $TMP_FILE $HSS_VARIABLE_USERS_FILE
fi
if [ -f "$HSS_DIAMETER_PEER_FILE" ];then
	cat $HSS_DIAMETER_PEER_FILE | sed "s/\VAR_DNS_REALM/$realm/g" > $TMP_FILE && mv $TMP_FILE $HSS_DIAMETER_PEER_FILE
	cat $HSS_DIAMETER_PEER_FILE | sed "s/\VAR_FHOSS_NAME/$name/g" > $TMP_FILE && mv $TMP_FILE $HSS_DIAMETER_PEER_FILE
	cat $HSS_DIAMETER_PEER_FILE | sed "s/\VAR_FHOSS_DIA_PORT/$fhoss_port/g" > $TMP_FILE && mv $TMP_FILE $HSS_DIAMETER_PEER_FILE
	cat $HSS_DIAMETER_PEER_FILE | sed "s/\VAR_FHOSS_DIA_BIND/$mgmt/g" > $TMP_FILE && mv $TMP_FILE $HSS_DIAMETER_PEER_FILE
fi

# Check if we have database related information and if needed change the entries

# TODO : reanable mysql relation, disabled for clearwater 
mysql_mgmt="127.0.0.1"

if [ -f "$HSS_DATABASE_FILE" ];then
	mysql -u root < $HSS_DATABASE_FILE >> $LOGFILE 2>&1
fi
if [ -f "$HSS_VARIABLE_USERS_FILE" ];then
	# now finally import userdata.sql since it has been overwritten
	mysql -u root < $HSS_VARIABLE_USERS_FILE >> $LOGFILE 2>&1
fi

# Do not forget to replace the diameter file :)
mv $HSS_DIAMETER_PEER_FILE $HSS_ORIG_DIAMETER_PEER_FILE
