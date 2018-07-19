#!/bin/bash


# fio tool to read and write disk.
# IN  : N/A
# OUT : N/A
function FIO_IO_read_write()
{
    Test_Case_Title="FIO_IO_read_write"

    # Generate FIO configuration file
    fio_config
    echo "Begin to run FIO_IO_RW"
    IO_read_write
    [ $? -eq 1 ] && MESSAGE="FAIL\tFIO tool read and write disk failure." && echo "Fail fio tool rw" && return 1

    sed -i "{s/^bs=.*/bsrange=${BSRANGE}/g;}" fio.conf
    for rw in "${FIO_RW[@]}"
    do
        sed -i "{s/^rw=.*/rw=${rw}/g;}" fio.conf
        ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio fio.conf
        if [ $? -ne 0 ]
        then
            MESSAGE="FAIL\tFIO tool in \"${rw}\" disk operation, error."
            echo ${MESSAGE}
            return 1
        fi
     done
    echo "Success fio tool rw"
    MESSAGE="PASS"
    echo ${MESSAGE}
}

# fio tools mixed io read and write
# IN  : N/A
# OUT : N/A
function FIO_IO_RAIO_randrw()
{
    Test_Case_Title="FIO_IO_RAIO_randrw"

    # Generate FIO configuration file
    fio_config

    sed -i '/rw/a\rwmixread=' fio.conf
    sed -i "{s/^bs=.*/bsrange=${BSRANGE}/g;}" fio.conf
    sed -i "{s/^rw=.*/rw=randrw/g;}" fio.conf

    ratio=$(echo ${TEST_CASE_TITLE} | awk -F "_" '{print $2}' | awk -F "read" '{print $NF}')
    echo "Begin FIO_IO_RAIO_randrw cycle: "${ratio}
    sed -i "{s/^rwmixread=.*/rwmixread=${ratio}/g;}" fio.conf
    ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio fio.conf
    [ $? -ne 0 ] && MESSAGE="FAIL\tfio tool ${ratio} raio mixed io read and write failed." && echo "Fail fio tool "${ratio} && return 1
    echo "Success fio tool "${ratio}
    MESSAGE="PASS"
    echo ${MESSAGE}
}

# fio tools only io read-only write.
# IN  : N/A
# OUT : N/A
function FIO_IO_RAIO_read_write()
{
    Test_Case_Title="FIO_IO_RAIO_read_write"

    # Generate FIO configuration file
    fio_config

    sed -i "{s/^bs=.*/bsrange=${BSRANGE}/g;}" fio.conf

    rw=$(echo ${TEST_CASE_TITLE} | awk -F "_" '{print $2}')
    [ $rw == "ReadOnly" -o $rw == "ReadDeep512" ] && rw="read"
    [ $rw == "WriteOnly" -o $rw == "WriteDeep512" ] && rw="write"
    if [ $rw == "ReadDeep512" -o $rw == "WriteDeep512" ];then
        sed -i '/bsrange/a\bssplit=' fio.conf
        sed -i "{s/^bssplit=.*/bssplit=${BSSPLIT}/g;}" fio.conf
    fi
    echo "Begin FIO IO RAIO rw cycle: "${rw}
    sed -i "{s/^rw=.*/rw=${rw}/g;}" fio.conf
    ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio fio.conf
    [ $? -ne 0 ] && MESSAGE="FAIL\tfio tool ${rw} io read and write failed." && echo "Fail fio tool "${rw} && return 1
    echo "Success fio tool "${rw}

    MESSAGE="PASS"
    echo ${MESSAGE}
}

function main()
{
    # call the implementation of the automation use cases
    test_case_function_run
}

main
