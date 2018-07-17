#!/bin/bash

# Reset backplane
# IN : N/A
# OUT: N/A
function smp_discover()
{

    Test_Case_Title="smp_discover"

    init_disk_num=`fdisk -l | grep /dev/sd | wc -l`
    for i in `seq ${SMP_DISCOVER_COUNT}`
    do
    expander=`ls /dev/bsg | grep "expander"`
            ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/smp_discover /dev/bsg/${expander}
    sleep 2
    end_disk_num=`fdisk -l | grep /dev/sd | wc -l`
    if [ ${end_disk_num} -ne ${init_disk_num} ]
    then
        echo "the number of disk is less than before"
        MESSAGE="FAIL\tReset backplane \"${expander}\" failed." && return 1
    fi
    done
    MESSAGE="PASS"
}

function main()
{
    #Judge the current environment, directly connected environment or expander environment.
    judgment_network_env
    if [ $? -ne 0 ]
    then
        MESSAGE="BLOCK\tthe current environment direct connection network, do not execute test cases."
        echo "the current environment direct connection network, do not execute test cases."
        return 0
    fi
    # call the implementation of the automation use cases
    test_case_function_run
}

main

