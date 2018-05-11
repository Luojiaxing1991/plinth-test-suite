#!/bin/bash

HNS_TOP_DIR=$(cd "`dirname $0`" ; pwd)

# Load common function
. ${HNS_TOP_DIR}/config/xge_test_config
. ${HNS_TOP_DIR}/config/xge_test_lib

# Load the public configuration library
. ${HNS_TOP_DIR}/../config/common_config
. ${HNS_TOP_DIR}/../config/common_lib


# Main operation function
# IN : N/A
# OUT: N/A

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
        exec_script=`echo "${line}" | awk -F '\t' '{print $6}'`
        TEST_CASE_FUNCTION_NAME=`echo "${line}" | awk -F '\t' '{print $7}'`
        TEST_CASE_FUNCTION_SWITCH=`echo "${line}" | awk -F '\t' '{print $8}'`
        TEST_CASE_TITLE=`echo "${line}" | awk -F '\t' '{print $3}'`
        TEST_CASE_NUM=`echo "${line}" | awk -F '\t' '{print $3}'`

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
        echo -e "${line}${MESSAGE}" >> ${HNS_TOP_DIR}/${OUTPUT_TEST_DB_FILE}
        #MESSAGE=""
    done
    echo "Finish to run XGE test!"
}

#Output log file header
writeLogHeader

#Xge test is only excute in 159 dash board
#Find the local MAC

#ifconfig IP
#initLocalIP
LOCAL_IP="192.168.1.19"
echo ${LOCAL_IP}

#init_client_ip

BACK_IP="192.168.1.130"
echo "The client ip is "${BACK_IP}

#set passwd
#setTrustRelation

#ifconfig net export
init_net_export

#performance init
perf_init

main

# clean exit so lava-test can trust the results
exit 0

