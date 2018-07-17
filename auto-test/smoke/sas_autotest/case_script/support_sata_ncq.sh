#!/bin/bash


# SATA ncq keyword query.
# IN : N/A
# OUT: N/A
function ncq_query()
{
    Test_Case_Title="ncq_query"

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
