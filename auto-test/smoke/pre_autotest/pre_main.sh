#!/bin/bash

if [ -f /home/plinth/ENV_OK ];then
	exit 0
fi


SAS_TOP_DIR=$(cd "`dirname $0`" ; pwd)

# Load the public configuration library
if [ x"$COM" = x"" ];then
	. ${SAS_TOP_DIR}/../config/common_config
	. ${SAS_TOP_DIR}/../config/common_lib
fi

#check the image commit id

commit_id=`cat /proc/version | awk -F' ' '{print $3}'`

echo "kernel commit ID is $commit_id"

aptlist=`ps -e | grep apt | awk -F' ' '{print $1}'`
for a in ${aptlist[@]}
do
	echo $a
	#id=`echo $a | awk -F '{print $1}'`
	#echo $id
	kill $a
done

# update filesystem
if [ x"$jump_apt_get" = x"FALSE" ];then
	apt-get update
	[ $? -ne 0 ]  && echo "apt-get is fail, try rm /var/lib/dpkg/lock, dpkg --configure -a  To fix it"
fi

echo 0 > /sys/class/sas_phy/phy-1\:0\:5/enable

# install expect
which expect
[ $? != 0 ] && apt-get -y install expect

#echo -e 'export ENV_OK="TRUE"' > ~/.bashrc
#source ~/.bashrc

#echo ${ENV_OK}
mkdir -p /home/plinth
touch /home/plinth/ENV_OK

#lava_report "Prepare_cmd" "pass" ${commit_id}
lava_report "Prepare_test" "pass" ${commit_id}

COM=true

#new a file to save result for debug
#if [ -d g ];then
        mkdir -p /home/plinth

	if [ -f /home/plinth/result.txt ];then
		rm /home/plinth/result.txt

        touch /home/plinth/result.txt
	#echo "#Save the fail test suit result description here" > ${SAS_TOP_DIR}/../config/result.txt
#fi

# clean exit so lava-test can trust the results
