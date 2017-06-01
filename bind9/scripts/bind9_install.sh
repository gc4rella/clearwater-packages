#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# bind9 installation script.

# If there are default options load them 
if [ -f "$SCRIPTS_PATH/default_options" ]; then
	source $SCRIPTS_PATH/default_options
fi

# Check to not run the script twice
if [ ! -z "$(cat $LOGFILE | grep bind9_install_finished)" ];then
	echo "installation for bind9 was already done"
	exit 0
fi

echo "$SERVICE : Installing packages"
# Install packages and redirect stderr to our logfile

if [ ! $downloadPackages = "false" ];then
	apt-get update >> $LOGFILE 2>&1 && echo "$SERVICE : Finished update now installing packages" && apt-get install -y -q bind9 >> $LOGFILE 2>&1
	echo "$SERVICE : Finished installing packages"
fi

echo "bind9_install_finished" >> $LOGFILE



