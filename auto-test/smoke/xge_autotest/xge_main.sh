#!/bin/bash

HNS_TOP_DIR=$(cd "`dirname $0`" ; pwd)

# Load common function
. ${HNS_TOP_DIR}/config/xge_test_config
. ${HNS_TOP_DIR}/config/xge_test_lib

# Load the public configuration library
if [ x"$COM" = x"" ];then
    . ${HNS_TOP_DIR}/../config/common_config
    . ${HNS_TOP_DIR}/../config/common_lib
fi

COM=true

# Main operation function
# IN : N/A
# OUT: N/A

## ---------start for chenjing
function check_environment() {
    Title="Check the HNS"
    echo ${eth_map[*]}
    echo "--------------------------------------------"
    for i in ${!eth_map[*]}
    do
        remote_mac=$( ssh root@${BACK_IP} "ifconfig ${eth_map_r[${i}]} | grep "HWaddr"")
        remote_mac=$( echo ${remote_mac} | awk '{print $NF}' )
        echo "remote mac is " ${remote_mac}
        local_mac=$( ifconfig ${eth_map[${i}]} | grep "HWaddr" | awk '{print $NF}' )
        echo "local mac is " ${local_mac}
        if [ "${remote_mac}"x == "${local_mac}"x ]
        then
            lava_report "check envir" "check the mac is fail"
            exit 1
        fi
    done
}
## ---------end-------------

function main()
{
    echo "Begin to Run XGE Test"

    if [ x"${BACK_IP}" = x"192.168.3.229" ]
    then
	return 1
    fi

    local MaxRow=$(sed -n '$=' "${HNS_TOP_DIR}/${TEST_CASE_DB_FILE}")
    local RowNum=0
    while [ ${RowNum} -lt ${MaxRow} ]
    do
        let RowNum+=1
        local line=$(sed -n "${RowNum}p" "${HNS_TOP_DIR}/${TEST_CASE_DB_FILE}")
        exec_script=`echo "${line}" | awk -F '|' '{print $6}'`
        TEST_CASE_FUNCTION_NAME=`echo "${line}" | awk -F '|' '{print $7}'`
        TEST_CASE_FUNCTION_SWITCH=`echo "${line}" | awk -F '|' '{print $8}'`
        TEST_CASE_TITLE=`echo "${line}" | awk -F '|' '{print $2}'`
        TEST_CASE_NUM=`echo "${line}" | awk -F '|' '{print $1}'`
        Tester=`echo "${line}" | awk -F '|' '{print $5}'`
        DateTime=`date "+%G-%m-%d %H:%M:%S"`
        if [ x"${DEVELOPER}" == x"" ]
        then
            Developer=`echo "${line}" | awk -F '|' '{print $4}'`
        else
            Developer=${DEVELOPER}
        fi

        echo "CaseInfo "${TEST_CASE_TITLE}" "$exec_script" "$TEST_CASE_FUNCTION_NAME" "$TEST_CASE_FUNCTION_SWITCH

        if [ x"${exec_script}" == x"" ]
        then
            MESSAGE="unimplemented automated test cases."
	    echo ${MESSAGE}
        else
            if [ ! -f "${HNS_TOP_DIR}/case_script/${exec_script}" ]
            then
                MESSAGE="case_script/${exec_script} execution script does not exist, please check."
		echo ${MESSAGE}
            else
		if [ x"${TEST_CASE_FUNCTION_SWITCH}" == x"on" ]
		then
			echo "Begin to run script: "${exec_script}
                        source ${HNS_TOP_DIR}/case_script/${exec_script}
		else
			echo "Skip the script: "${exec_script}
		fi
            fi
        fi
        # echo -e "${line}${MESSAGE}" >> ${HNS_TOP_DIR}/${OUTPUT_TEST_DB_FILE}
        #MESSAGE=""
    done
    echo "<<----------------------------------------->>"
    echo "Finish to run XGE test!"
    echo -e "\033[32mThe test report path locate at \033[0m\033[35m${PLINTH_TEST_WORKSPACE}/${Module}/${Date}/${NowTime}/ \033[0m"
}


#get the parameter of $1 $2
#$1:  it mean the server ip set by CI env,actually sip is not using in test 
#$2:  it mean the client ip set by CI env
if [ x"$1" = x"" ];then
    echo "No $1 para pass to xge_main.sh!"
else
    g_server_ip=$1
    echo "Set server ip used $1 as $g_server_ip "
fi

if [ x"$2" = x"" ];then
    echo "No $2 para pass to xge_main.sh"
else
    g_client_ip=$2
    echo "Set client ip used $2 as $g_client_ip"
fi

if [ x"$3" = x"" ];then
    echo "No $3 para pass to xge_main.sh"
else
    jump_apt_get=$3
    echo "Set jump_apt_get used $3 to jump the apt-get action"
fi

if [ x"$4" = x"" ];then
    echo "No $4 para pass to xge_main.sh"
else
    g_ctrlNIC=$4
    echo "Set ctrl NIC used $4"
fi



#-------------------------------------------------------------------#
#Description: These code check if ENV_OK is exist.if not ,run pre_main to do some common options.
#             then check ENV_OK again , if still not exist,it mean some thing wrong when running pre_main.
#             test will not run but exit.
#
#Coder: luojiaxing 00437090 20180719

check_ENV_OK_exists

if [ $? -eq 1 ]
then
    . ${HNS_TOP_DIR}/../pre_autotest/pre_main.sh
fi

check_ENV_OK_exists

if [ $? -eq 1 ];then
	echo "pre_main meet some problem,please check...."
	exit 1
fi
#-------------------------------------------------------------------------#

#mkdir the log path
InitDirectoryName

#mkdir test path
MkdirPath

#Output CI log header
LogHeader

#------------------------------------------------------------------------#
#Description:   these code get sip and cip from parameter. Client ip is import to xge test ,so if it
#		is empty , this shell will exit.
#		when cip is not empty, I will check the connect between server and client by ping. if
#               connect is not good,this shell will exit too.
#
#Coder: luojiaxing 00437090 20180625
#

if [ x"$g_server_ip" == x"" ];then
	echo "server ip is not set. but it may be no influence"
fi

echo "Get the server ip as $g_server_ip"

LOCAL_IP=$g_server_ip
echo ${LOCAL_IP}

#init_client_ip
if [ x"$g_client_ip" = x"" ];then
	echo "client ip is not set! It mean fail...exit!"
	exit 1
else
        BACK_IP=$g_client_ip
fi

echo "The client ip is "${BACK_IP}

#check connect between server and client
ping $BACK_IP -c 5 | grep " 0% packet loss"

if [ $? -eq 0 ];then
	echo "Connect between server and client is OK!"
else
	echo "Client is not good!"
	exit 1
fi
#----------------------------------------------------------------------------------#

#set passwd
setTrustRelation

#ifconfig net export
init_net_export

#check mac
check_environment

#check iperf/qperf/netperf is ok
# install_iperf_netperf

#install qperf
# qperf_install

# iperf, qperf, netperf
Prepare_PerfTool

#performance init
perf_init

main

# clean exit so lava-test can trust the results
exit 0

