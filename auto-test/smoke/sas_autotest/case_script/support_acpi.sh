#!/bin/bash



# check the system startup method.
# IN : N/A
# OUT: N/A
function check_acpi_start()
{
    Test_Case_Title="check_acpi_start"

    info=`cat /proc/cmdline | grep ${ACPI_KEY_INFO}`
    if [ x"${info}" == x"" ] 
    then
        MESSAGE="FAIL\tThe current system is not acpi way to start." && echo ${MESSAGE} && return 1
    fi
    MESSAGE="PASS"
    echo ${MESSAGE}
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

