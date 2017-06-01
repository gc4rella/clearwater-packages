#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# bind9 relation joined script

#foreign="bind9"
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

# initially the log should be empty
if [ ! -z "$(cat $log | grep $clearwater_role\_bind9_relation_finished)" ];then
	echo "relation for $clearwater_role\_bind9 was already done"
	exit 0
fi

echo "Building up relation with : $foreign"

# find the correct ip addresses
com=$foreign\_private\=\$$foreign$binding$clearwater_net
echo "executing : $com"
eval $com
com=$foreign\_public\=\$$foreign$binding$clearwater_net$floating
echo "executing : $com"
eval $com


if [ -z "$(eval echo \$$foreign$private)" ];then
	echo "$foreign does not seem to have a private ip on $clearwater_net"
fi
if [ -z "$(eval echo \$$foreign$public)" ];then
	echo "$foreign does not seem to have a public ip on $clearwater_net"
fi

VARIABLE_BUCKET="$SCRIPTS_PATH/$relation_bucket"

# TODO : make this more generic

# Check for bind9 realm related information
if [ -z "$bind9_realm" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$foreign_realm not defined, will use default : example.com"
	bind9_realm="example.com"
fi

if [ -z "$(eval echo \$$foreign$private)" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "there is not $clearwater_net network for $foreign!"
	exit 1
fi

# TODO : we may need to allow floating IPs for bind9 if we think of a multidatacenter deployment
# Check if we want to use floatingIPs for the entries
if [ ! $bind9_useFloatingIpsForEntries = "false" ]; then
	if [ -z "$(eval echo \$$foreign$public)" ]; then
		echo "there is no floatingIP for the $clearwater_net network for $foreign !"
		#exit 1
	else
		# Else we just overwrite the environment variable
		com=bind9_mgmt\=$(eval echo \$$foreign$public)
		echo "executing : $com"
		eval $com
	fi
else
	com=bind9_mgmt\=$(eval echo \$$foreign$private)
	echo "executing : $com"
	eval $com
fi

IPV4_ADDRESS=$(eval echo \$$clearwater_net)

# Save variables related to bind9 into a file to access it in a later phase
if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
else
	touch $VARIABLE_BUCKET
fi
printf "dns_realm=%s\n" \"$bind9_realm\" >> $VARIABLE_BUCKET
printf "dns_ip=%s\n" \"$bind9_mgmt\" >> $VARIABLE_BUCKET

echo "$SERVICE: Establishing nameserver"

# Get the network interface name to be able to add a search line to it permanently
_real_iface=$(ip addr | grep -B 2 "$IPV4_ADDRESS" | head -1 | awk '{ print $2 }' | sed 's/://')

# Use a python function to adapt the /etc/resolv.conf permanently
# What we will do is the write the new bind9 nameserver into the head file...
# Thus we ensure it will always be the first nameserver in the /etc/resolv.conf
cd $SCRIPTS_PATH && python << END
import dns_utils
dns_utils.resolver_adapt_config_light("$_real_iface","$bind9_mgmt","$bind9_realm", 'novalocal.')
END

# Update the /etc/resolv.conf to be sure we have added the new nameserver
resolvconf -u

# prepare the shared config
if [ -f "$SCRIPTS_PATH/shared_config" ];then
	if [ ! -f "$clearwater_conf_dir/shared_conf" ];then
		cp $SCRIPTS_PATH/shared_config $clearwater_conf_dir/shared_config_template
		cat $clearwater_conf_dir/shared_config_template | sed "s/\VAR_DNS_REALM/$bind9_realm/g" > $tmp_var && mv $tmp_var $clearwater_conf_dir/shared_config_template
	fi
fi

# throw the install finish into the log file so we wont run this script twice
echo "$clearwater_role\_bind9_relation_finished" >> $log
