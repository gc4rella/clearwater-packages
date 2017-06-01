#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# fhoss installation script.

# fhoss will be configured to use a local database!

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

# Check for the ipv4 address
if [ -z "$mgmt" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no mgmt network !"
	exit 1
fi

# Install packages
install_packages(){
        # Update the apt repository list and install packages
        echo "$SERVICE : Installing packages"
	# Set env variables so mysql will not ask for password when being installed
	export DEBIAN_FRONTEND=noninteractive
	# Install packages and redirect stderr to our logfile
        apt-get update >> $LOGFILE 2>&1 && echo "$SERVICE : Finished update now installing packages" && apt-get install -q -y $PACKAGES >> $LOGFILE 2>&1
        echo "$SERVICE : Finished installing packages"
}

if [ ! -z "$download_packages" ];then
	if [ $download_packages = "true" ];then
		install_packages
	fi
fi

# Set correct environment variables to allow usage of java
export PATH=$PATH:$JAVA_BIN_PATH
export JAVA_HOME="$JAVA_PATH"
# Also set encoding to be able to compile without problems
export JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8 >> $LOGFILE 2>&1

if [ ! -z "$download_packages" ];then
	if [ $download_packages = "true" ];then
		echo "$SERVICE : Checking out sources"
		svn checkout $FHOSS_REPO $INSTALLATION_PATH >> $LOGFILE 2>&1
		cd $INSTALLATION_PATH

		echo "$SERVICE : Compiling sources"
		ant compile >> $LOGFILE 2>&1
		ant deploy >> $LOGFILE 2>&1
	fi
fi

# Tell tomcat server to listen to the correct ipv4 address ( to allow access to fhoss gui when using a floatingIp )
sed -i -e "s/host=127.0.0.1/host=$mgmt/g" $HSS_PROPERTIES_FILE

