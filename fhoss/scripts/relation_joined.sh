#########################
#	Openbaton	#
#########################
# Author : lgr

# clearwater relation script, generic to be sourced into the specific relation

# initially the log should be empty
if [ ! -z "$(cat $LOGFILE | grep $clearwater_role\_$foreign\_relation_finished)" ];then
	echo "relation for $clearwater_role\_$foreign was already done"
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

# save the variables
if [ -f "$SCRIPTS_PATH/$relation_bucket" ]; then
	printf "$foreign$private=%s\n" \"$(eval echo \$$foreign$private)\" >> $SCRIPTS_PATH/$relation_bucket
	printf "$foreign$public=%s\n" \"$(eval echo \$$foreign$public)\" >> $SCRIPTS_PATH/$relation_bucket
fi


# throw the install finish into the log file so we wont run this script twice
echo "$clearwater_role\_$foreign\_relation_finished" >> $LOGFILE

