#!/bin/bash


SAS_TOP_DIR=$(cd "`dirname $0`" ; pwd)

# Load the public configuration library
if [ x"$COM" = x"" ];then
    . ${SAS_TOP_DIR}/../config/common_config
    . ${SAS_TOP_DIR}/../config/common_lib
fi

# Load module configuration library
. ${SAS_TOP_DIR}/config/sas_test_config
. ${SAS_TOP_DIR}/config/sas_test_lib

# Main operation function
# IN : N/A
# OUT: N/A
function main()
{
    echo "Begin to Run SAS Test!"
    cat ${SAS_TOP_DIR}/${TEST_CASE_DB_FILE} | while read line
    do
        exec_script=`echo "${line}" | awk -F '|' '{print $6}'`
        TEST_CASE_FUNCTION_NAME=`echo "${line}" | awk -F '|' '{print $7}'`
        TEST_CASE_FUNCTION_SWITCH=`echo "${line}" | awk -F '|' '{print $8}'`
        #Get the test title from testcase.table
        TEST_CASE_TITLE=`echo "${line}" | awk -F '|' '{print $2}'`
        Tester=`echo "${line}" | awk -F '|' '{print $5}'`
        DateTime=`date "+%G-%m-%d %H:%M:%S"`
        if [ x"${DEVELOPER}" == x"" ]
        then
            Developer=`echo "${line}" | awk -F '|' '{print $4}'`
        else
            Developer=${DEVELOPER}
        fi
        echo "script is "${exec_script}
        echo "CaseInfo "${TEST_CASE_TITLE}" "${exec_script}" "${TEST_CASE_FUNCTION_NAME}" "${TEST_CASE_FUNCTION_SWITCH}

        if [ x"${exec_script}" == x"" ]
        then
            MESSAGE="unimplemented automated test cases."
        else
            if [ ! -f "${SAS_TOP_DIR}/case_script/${exec_script}" ]
            then
                MESSAGE="FILE\tcase_script/${exec_script} execution script does not exist, please check."
            else
		        if [ x"$TEST_CASE_FUNCTION_SWITCH" == x"on" ]
		        then
			        echo "Begin to run script: "${exec_script}
                    source ${SAS_TOP_DIR}/case_script/${exec_script}
		        else
	            	echo "Skip the Scirpt: "${exec_script}
		        fi
            fi
        fi
        # echo -e "${line}\t${MESSAGE}" >> ${SAS_TOP_DIR}/${OUTPUT_TEST_DB_FILE}
        MESSAGE=""
    done
    echo "<<----------------------------------------->>"
    echo "Finish to Run SAS Test"
    echo -e "\033[32mThe test report path locate at \033[0m\033[35m${PLINTH_TEST_WORKSPACE}/${Module}/${Date}/${NowTime}/ \033[0m"
}

# close /dev/sda
#-------------------------------------------------------------------#
#Description: These code check if ENV_OK is exist.if not ,run pre_main to do some common options.
#             then check ENV_OK again , if still not exist,it mean some thing wrong when running pre_main.
#             test will not run but exit.
#
#Coder: luojiaxing 00437090 20180719

check_ENV_OK_exists

if [ $? -eq 1 ]
then
    . ${SAS_TOP_DIR}/../pre_autotest/pre_main.sh
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

get_all_disk_part

cat /proc/kmsg >> /home/log.txt &
main

# clean exit so lava-test can trust the results
exit 0
