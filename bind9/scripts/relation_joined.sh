#########################
#	Openbaton	#
#########################
# Author : lgr

# clearwater relation script, generic to be sourced into the specific relation

binding="_"

# initially the log should be empty
if [ ! -z "$(cat $LOGFILE | grep bind9_$foreign\_relation_finished)" ];then
	echo "relation for bind9_$foreign was already done"
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

# Check if we want to use floatingIPs for the entries
if [ ! $useFloatingIpsForEntries = "false" ]; then
	if [ -z "$(eval echo \$$foreign$public)" ]; then
		echo "$SERVICE : there is no floatingIP for the $clearwater_net network for $foreign !"
		#exit 1
	else
		# Else we just overwrite the environment variable
		com=$foreign$private\=$(eval echo \$$foreign$public)
		echo "executing : $com"
		eval $com
	fi
fi

# This value will be used to replace the 
substitute=$(eval echo \$$foreign$private)
key="VAR_$(echo $foreign | awk '{print toupper($0)}')_MGMT"
echo "substituting $key"

cat $REALMFILE | sed "s/$key/$substitute/g" > $tmp_var && mv $tmp_var $REALMFILE

# throw the install finish into the log file so we wont run this script twice
echo "bind9_$foreign\_relation_finished" >> $LOGFILE

