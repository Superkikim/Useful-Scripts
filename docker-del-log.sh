#!/bin/sh

###############################################################################
#
# Author:  Akim Sissaoui
# Website: https://akim.sissaoui.com/en/informatique
#
# Description:
#    This script uses jq to parse docker Id out of docker container inspect 
#    and delete the log file of a specific container
#
# Requirement:
#    The scripts needs jq (https://stedolan.github.io/jq/)
#    User must be allowed sudoer
#
# Usage:
#    ./docker-del-log.sh [container name]
#
# Example:
#
#    Below example will delete the log for a container called hass
#
#    ./docker-del-log.sh hass
#
#
###############################################################################

# Check if value has been provided
# Parse parameters
dockername=$1
noconfirm=$2

# Check if docker name has been provided
if [ -z $dockername ]
then
	echo "Container name is required. Exiting"
exit 1
fi

# Check if docker exists
exists=$(arr=( $(docker container inspect hass | jq -r '.[]."Id"') );printf '%s\n' "${arr[@]}" | wc -l)
if [[ $exist -eq "0" ]]
then
    echo The container $dockername does has not been found. Exiting...
    exit 1
elif [[ $exist -gt "1" ]]
then
    echo Something weird happened. More than one container with the name $dockername have been found... Exiting...
    exit 1
fi

# Parse container Id
container_id=$(docker container inspect $dockername | jq -r '.[]."Id"') );printf '%s\n' "${arr[@]}"

# Set log path variable
logpath="/var/lib/docker/containers/$container_id/$container_id-json.log"

# Check if log exists
if [ -f $logpath ] 
then
   echo "Log file found."
   echo
else
   echo "Log file not found. Please check container name and configuration. Exiting."
   exit 1
fi

# Ask for user confirmation
read -p "Container $dockername has ID #$container_id. Delete the log ? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    rm -f $logpath
    success=$?
    if [[ $success -eq "0" ]]
        echo "File successfully deleted"
        exit 0
    else
        echo "Something went wrong. Check if file $logpath exists."
        exit 1
    fi
else
    echo Action canceled by user
    exit 1
fi
exit 0
