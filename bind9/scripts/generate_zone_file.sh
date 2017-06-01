#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# bind9 generate zone file scripts.

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

# Check to not run the script twice
if [ ! -z "$(cat $LOGFILE | grep bind9_generate_zone_finished)" ];then
	echo "zone generation for bind9 was already done"
	exit 0
fi

if [ -z "$realm" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no realm for bind9!"
	exit 1
fi

# Copy the zone template file to the final destination
if [ ! -d "/etc/bind" ]; then
 	mkdir /etc/bind
fi
cp $SCRIPTS_PATH/$ZONEFILE $REALMFILE

# find the correct ip addresses
com=private\=\$$clearwater_net
echo "executing : $com"
eval $com
com=public\=\$$clearwater_net$floating
echo "executing : $com"
eval $com

if [ ! $useFloatingIpsForEntries = "false" ]; then
	if [ -z "$public" ]; then
		echo "$SERVICE : there is no floatingIP for the mgmt network for bind9 !"
		exit 1
	else
		# Else we just overwrite the environment variable
		dns_ip=$public
	fi
else
	dns_ip=$private
fi

# Fill the Bind9 related information

cat $REALMFILE | sed "s/VAR_DNS_REALM/$realm/g" > $tmp_var && mv $tmp_var $REALMFILE
cat $REALMFILE | sed "s/VAR_DNS_MGMT/$dns_ip/g" > $tmp_var && mv $tmp_var $REALMFILE

# Add zone entry if it has not been added yet
check=$(cat $CONFIG_FILE | grep "$realm")
if [ -z "$check" ];then
	echo "" >> $CONFIG_FILE
	echo "zone \"$realm\" {" >> $CONFIG_FILE
	echo "	type master;" >> $CONFIG_FILE
	echo "	file \"$REALMFILE\";" >> $CONFIG_FILE
	echo "};" >> $CONFIG_FILE
	echo "" >> $CONFIG_FILE
fi

echo "bind9_generate_zone_finished" >> $LOGFILE

