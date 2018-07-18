#!/bin/bash






function iost_axi_err()
{
    Test_Case_Title="iost_axi_err"

    ECC_INFO_KEY_QUERIES="corrected"
    init_bit_count=`dmesg | grep ${ECC_INFO_KEY_QUERIES} | wc -l`

    ${DEVMEM} ${IOST_BASE_ADDRL} 32 0x0
    ${DEVMEM} ${IOST_BASE_ADDRU} 32 0xf0
    RW=$(echo ${TEST_CASE_TITLE} | awk -F "_" '{print $5}')
    sed -i "{s/^bs=.*/bsrange=${BSRANGE}/g;}" fio.conf
    sed -i "{s/^rw=.*/rw=${RW}/g;}" fio.conf
    ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio fio.conf
    sleep 5
    end_bit_count=`dmesg | grep ${ECC_INFO_KEY_QUERIES} | wc -l`
    if [ ${init_bit_count} -ne ${end_bit_count} ];then
        MESSAGE="FAIL\tiost axi error failed,no exist${ECC_INFO_KEY_QUERIES}.${IOST_BASE_ADDRL} ${IOST_BASE_ADDRU}" && echo ${MESSAGE} && return 1
    fi
    addrl_value=`${DEVMEM} ${IOST_BASE_ADDRL} 32`
    addru_value=`${DEVMEM} ${IOST_BASE_ADDRU} 32`
    if [ x"${addrl_value}" == x"0x0" -o x"${addru_value}" == x"0xf0" ]
    then
        MESSAGE="FAIL\tiost axi error failed,${IOST_BASE_ADDRL} and ${IOST_BASE_ADDRU} no recover original value" && echo ${MESSAGE} && return 1
    fi
    MESSAGE="PASS"
    echo ${MESSAGE}
}

