#!/bin/bash

ROCE_TOP_DIR=$( cd "`dirname $0`" ; pwd )
ROCE_CASE_DIR=${ROCE_TOP_DIR}/case_script

# Load the public configuration library
. ${ROCE_TOP_DIR}/../config/common_config
. ${ROCE_TOP_DIR}/../config/common_lib

# Load module configuration library
. ${ROCE_TOP_DIR}/config/roce_test_config
. ${ROCE_TOP_DIR}/config/roce_test_lib

# Main operation function
# IN : N/A
# OUT: N/A
function main()
{
    Module_Name="ROCE"
    echo "Begin to run "$Module_Name" test"
	local MaxRow=$(sed -n '$=' "${ROCE_TOP_DIR}/${TEST_CASE_DB_FILE}")
	local RowNum=0

	while [ ${RowNum} -lt ${MaxRow} ]
	do
		let RowNum+=1
		local line=$(sed -n "${RowNum}p" "${ROCE_TOP_DIR}/${TEST_CASE_DB_FILE}")

		exec_script=`echo "${line}" | awk -F '\t' '{print $6}'`
		TEST_CASE_FUNCTION_NAME=`echo "${line}" | awk -F '\t' '{print $7}'`
		TEST_CASE_FUNCTION_SWITCH=`echo "${line}" | awk -F '\t' '{print $8}'`
        TEST_CASE_TITLE=`echo "${line}" | awk -F '\t' '{print $3}'`
        echo "TestCaseInfo "${TEST_CASE_TITLE}" "${exec_script}" "${TEST_CASE_FUNCTION_NAME}" "${TEST_CASE_FUNCTION_SWITCH}
        clear_send_read_write_envir

		if [ x"${exec_script}" == x"" ]
		then
			MESSAGE="unimplemented automated test cases."
			echo ${MESSAGE}
		else
			if [ ! -f "${ROCE_CASE_DIR}/${exec_script}" ]
			then
				MESSAGE="FILE\tcase_script/${exec_script} execution script does not exist, please check."
				echo ${MESSAGE}
			else
				if [ x"${TEST_CASE_FUNCTION_SWITCH}" == x"on"  ]
				then
		            echo "Begint to run test "${TEST_CASE_TITLE}
					source ${ROCE_CASE_DIR}/${exec_script}
				else
					echo "Skip the script!"
				fi
			fi
		fi
		echo -e "${line}${MESSAGE}" >> ${ROCE_TOP_DIR}/${OUTPUT_TEST_DB_FILE}
		MESSAGE=""
		#echo "Done test: "${TEST_CASE_TITLE}
	done
    echo "Finish to Run ROCE Test"
}

function roce_init() {
    if [ "${USER_DRV_VERSION}"x != ""x ]
    then
        ROCE_USERDRV_BRANCH="plinth-"${USER_DRV_VERSION}
    else
	USER_DRV_VERSION="it18"
    fi
    res=$(env | grep "BOARD_TYPE")
    if [ "${res}"x = ""x ]
    then
        ROCE_BOARD_TYPE="D06"
    else
        ROCE_BOARD_TYPE=${res}
    fi
}
roce_init
#insmod /home/kernel/output/hns-roce.ko
#insmod /home/kernel/output/hns-roce-hw-v1.ko

# LOCAL_ETHX=`cat /sys/class/infiniband/hns_0/ports/${ROCE_PORT}/gid_attrs/ndevs/0`

##check the env_ok is ok
check_ENV_OK_exists
if [ $? -eq 1 ]
then
    . ${ROCE_TOP_DIR}/../pre_autotest/pre_main.sh
fi

# #checkout if roce user driver repo is exit or not!
check_roce_drv
if [ $? == 0 ];then
    echo "Finish the test env set for ROCE test!"
else
    echo "Something wrong when prepare the test evv!"
    exit 1
fi

##kill roce process running before
/${ROCE_TOP_DIR}/case_script/roce-test -m 2 -c 0xff -r
sleep 5
#
writeLogHeader
#
# find tp or fibre
init_local_fibre_or_tp

main
#
#
## clean exit so lava-test can trust the results
exit 0

