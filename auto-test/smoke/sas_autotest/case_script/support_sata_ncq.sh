#!/bin/bash


# SATA ncq keyword query.
# IN : N/A
# OUT: N/A
function ncq_query()
{
    Test_Case_Title="ncq_query"
    BType=1
    sata="sata"
    for dir in `ls "${PHY_FILE_PATH}"`
    do
        echo "Begin to check sas type in "${dir}
        type=`cat ${PHY_FILE_PATH}/${dir}/target_port_protocols`
        if [ $(echo "${type} ${sata}"| awk '{if($1=$2){print 0}else{print 1}}') -eq 0 ];then
            BType=0
            break
        fi
    done
    if [ $BType -eq 1 ];then
        MESSAGE="FAIL\t there are not sata disk, do not execute test case. " && echo ${MESSAGE} && return 1
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
