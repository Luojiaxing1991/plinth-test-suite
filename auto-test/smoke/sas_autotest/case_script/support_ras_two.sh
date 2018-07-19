#!/bin/bash






function iost_itct_axi_err()
{
    Test_Case_Title="iost_itct_axi_err"

    ECC_INFO_KEY_QUERIES="corrected"
    init_bit_count=`dmesg | grep ${ECC_INFO_KEY_QUERIES} | wc -l`
    info=$(echo ${TEST_CASE_TITLE} | awk -F "_" '{print $2}')
    if [ $info == "IOST" ];then
        ${DEVMEM} ${IOST_BASE_ADDRL} 32 0x0
        ${DEVMEM} ${IOST_BASE_ADDRU} 32 0xf0
    elif [ $info == "ITCT" ];then
        ${DEVMEM} ${ITCT_BASE_ADDRL} 32 0x0
        ${DEVMEM} ${ITCT_BASE_ADDRU} 32 0xf0
    fi
    RW=$(echo ${TEST_CASE_TITLE} | awk -F "_" '{print $5}')
    sed -i "{s/^bs=.*/bsrange=${BSRANGE}/g;}" fio.conf
    sed -i "{s/^rw=.*/rw=${RW}/g;}" fio.conf
    ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio fio.conf
    sleep 5
    end_bit_count=`dmesg | grep ${ECC_INFO_KEY_QUERIES} | wc -l`
    if [ ${init_bit_count} -ne ${end_bit_count} ];then
        MESSAGE="FAIL\tiost itct axi error failed,no exist${ECC_INFO_KEY_QUERIES}." && echo ${MESSAGE} && return 1
    fi
    if [ $info == "IOST" ];then
        addrl_value=`${DEVMEM} ${IOST_BASE_ADDRL}`
        addru_value=`${DEVMEM} ${IOST_BASE_ADDRU}`
    elif [ $info == "ITCT" ];then
        addrl_value=`${DEVMEM} ${ITCT_BASE_ADDRL}`
        addru_value=`${DEVMEM} ${ITCT_BASE_ADDRU}`
    fi
    if [ x"${addrl_value}" == x"0x0" -o x"${addru_value}" == x"0xf0" ]
    then
        MESSAGE="FAIL\tiost itct axi error failed,no recover original value" && echo ${MESSAGE} && return 1
    fi
    MESSAGE="PASS"
    echo ${MESSAGE}
}



function hard_reset_axi_err()
{
    Test_Case_Title="hard_reset_axi_err"

    ECC_INFO_KEY_QUERIES="corrected"
    init_bit_count=`dmesg | grep ${ECC_INFO_KEY_QUERIES} | wc -l`
    info=$(echo ${TEST_CASE_TITLE} | awk -F "_" '{print $3}')
    if [ $info == "DEQ" ];then
        ${DEVMEM} ${DLVRY_QUEUE_BASE_ADDRL} 32 0x0
        ${DEVMEM} ${DLVRY_QUEUE_BASE_ADDRU} 32 0xf0
    elif [ $info == "CEQ" ];then
        ${DEVMEM} ${CMPLTN_QUEUE_BASE_ADDRL} 32 0x0
        ${DEVMEM} ${CMPLTN_QUEUE_BASE_ADDRU} 32 0xf0
    fi

    change_sas_phy_file 1 "hard_reset"
    sleep 5

    end_bit_count=`dmesg | grep ${ECC_INFO_KEY_QUERIES} | wc -l`
    if [ ${init_bit_count} -ne ${end_bit_count} ];then
        MESSAGE="FAIL\thard reset axi error failed,no exist${ECC_INFO_KEY_QUERIES}." && echo ${MESSAGE} && return 1
    fi
    if [ $info == "IOST" ];then
        addrl_value=`${DEVMEM} ${DLVRY_QUEUE_BASE_ADDRL}`
        addru_value=`${DEVMEM} ${DLVRY_QUEUE_BASE_ADDRU}`
    elif [ $info == "ITCT" ];then
        addrl_value=`${DEVMEM} ${CMPLTN_QUEUE_BASE_ADDRL}`
        addru_value=`${DEVMEM} ${CMPLTN_QUEUE_BASE_ADDRU}`
    fi
    if [ x"${addrl_value}" == x"0x0" -o x"${addru_value}" == x"0xf0" ]
    then
        MESSAGE="FAIL\tiost axi error failed,${IOST_BASE_ADDRL} and ${IOST_BASE_ADDRU} no recover original value" && echo ${MESSAGE} && return 1
    fi
    MESSAGE="PASS"
    echo ${MESSAGE}
}



