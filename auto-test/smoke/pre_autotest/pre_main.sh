#!/bin/bash


SAS_TOP_DIR=$(cd "`dirname $0`" ; pwd)

# Load the public configuration library
. ${SAS_TOP_DIR}/../config/common_config
. ${SAS_TOP_DIR}/../config/common_lib

#check the image commit id

commit_id=`cat /proc/version | awk -F' ' '{print $3}'`

echo "kernel commit ID is $commit_id"

#lava_report "Prepare_cmd" "pass" ${commit_id}

lava_report "Prepare_test" "pass" ${commit_id}

# update filesystem
apt-get update
[ $? -ne 0 ]  && echo "apt-get is fail, try rm /var/lib/dpkg/lock, dpkg --configure -a  To fix it"

# install expect
which expect
[ $? != 0 ] && apt-get -y install expect

export ENV_OK="TRUE"

echo 0 > /sys/class/sas_phy/phy-1\:0\:5/enable

# clean exit so lava-test can trust the results
