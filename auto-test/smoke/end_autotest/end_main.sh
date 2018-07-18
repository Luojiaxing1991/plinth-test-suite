#!/bin/bash
# Description: this shell mean to do some options which end of test and only run once
#
# Function:    1.get the commit id of kernel now testing
#              2.run apt-get update when nessary
#              3.close sata phy when nessary
#              4.install expect cmd
#	       5.record dmesg of eth renamed
#              6.new result.txt for save fail testcase message
#               
#
# Generater:  luojiaxing 00437090
#
# Maintainer: luojiaxing,chenjing



END_TOP_DIR=$(cd "`dirname $0`" ; pwd)

# Load the public configuration library
. ${END_TOP_DIR}/../config/common_config
#. ${END_TOP_DIR}/../config/common_lib

#-----------------------------------------------------------#
#Description: collect the result file ,upload to tftp server
#
#Coder: luojiaxing 00437090 20180608
#
pushd ${END_TOP_DIR}

#get the name of dir which save lava lib
lava_dir=`ls -a / | grep "lava-"`

if [ $? -eq 0 ];then
	echo "Lava lib dir is exist!"
else
	echo "No found the lava lib!exit"
	exit 1
fi

#get the lava id to mkdir result dir
lava_id=`echo $lava_dir | awk -F'-' '{print $NF}'`

echo "Get the lava id as $lava_id"

#new the dir to save result
if [ -d ${END_TOP_DIR}/${lava_id} ];then
	rm -rf ${END_TOP_DIR}/${lava_id}
fi	

mkdir ${END_TOP_DIR}/${lava_id} 

#check out the result file
if [ -f /home/plinth/result.txt ];then
	echo "Something wrong when test running!"
	cp /home/plinth/result.txt ${lava_id}
else
	touch ${lava_id}/result.txt 
	#echo -e 'ST.FUNC.029\tyou\n' >> ${lava_id}/result.txt
fi

#####
##cp the result file to tftp server
#####

#check tftp server is online or not
ping ${TFTP_SERVER_IP} -c 5 | grep "0% packet loss"

if [ $? -eq 0 ];then
	echo "TFTP server is online!"
else
	echo "TFTP server is offline!"
	exit 1
fi

#copy the result txt to tftp server
expect -c '
	set timeout 5
	set tmpdir '${lava_id}'
	set ip '${TFTP_SERVER_IP}'
	spawn scp -r ${tmpdir} root@${ip}:/root/estuary/fileserver_data/plinth
	expect {
           "Are you sure" {send "yes\r"; exp_continue}
	    "password" {send "root\r"}
        }

	expect eof
	exit 0
'
#---------------------------------------------------------------------------#
popd
# clean exit so lava-test can trust the results
