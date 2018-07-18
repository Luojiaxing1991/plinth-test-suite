#!/bin/bash


# SATA ncq keyword query.
# IN : N/A
# OUT: N/A
function ncq_query()
{
    Test_Case_Title="ncq_query"
    expander=`ls /dev/bsg | grep "expander"`
    sata_num=`${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/smp_discover /dev/bsg/${expander} | grep "SATA" | wc -l`
    if [ ${sata_num} -le 0 ]
    then
        MESSAGE="FAIL\thave not sata disk when query \"NCQ\". " && echo ${MESSAGE} && return 1
    fi
    info=`dmesg | grep 'NCQ'`
    if [ x"${info}" = x"" ] 
    then
        MESSAGE="FAIL\tQuery keyword \"NCQ\" failed." && echo ${MESSAGE} && return 1
    fi

    MESSAGE="PASS"
    echo ${MESSAGE}
}

function main()
{
    # call the implementation of the automation use cases
    test_case_function_run
}

main
