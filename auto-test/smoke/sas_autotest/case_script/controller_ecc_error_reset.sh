#!/bin/bash



# 2bit error injection controller reset.
# IN : N/A
# OUT: N/A
function controller_2bit_ecc_reset()
{
    Test_Case_Title="controller_2bit_ecc_reset"

    ${DEVMEM} ${CONTROLLER_ECC_RESET_ADDR} w 0x1
    ${DEVMEM} ${CONTROLLER_ECC_ERROR} w 0x11

    sed -i "{s/^bs=.*/bsrange=${BSRANGE}/g;}" ${FIO_CONFIG_PATH}/fio.conf
    ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio ${FIO_CONFIG_PATH}/fio.conf

    sleep 5

    reset_value=`${DEVMEM} ${CONTROLLER_ECC_RESET_ADDR} w`
    bit_value=`${DEVMEM} ${CONTROLLER_ECC_ERROR} w`

    if [ x"${reset_value}" == x"0x1" -o x"${bit_value}" == x"0x11" ]
    then
        MESSAGE="FAIL\tcontoller reset for 2ecc error failed, ${CONTROLLER_ECC_RESET_ADDR}:${reset_value}, ${CONTROLLER_ECC_ERROR}:${bit_value}"
        echo ${MESSAGE}
        return 1
    fi
    MESSAGE="PASS"
    echo ${MESSAGE}
}

# 1bit error injection controller reset.
# IN : N/A
# OUT: N/A
function controller_1bit_ecc_reset()
{
    Test_Case_Title="controller_1bit_ecc_reset"

    local key_count=0
    time dmesg -c >> /dev/null
    # you must first run business io, then injected ecc error.
    ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio ${FIO_CONFIG_PATH}/fio.conf &

    ${DEVMEM} ${CONTROLLER_ECC_RESET_ADDR} w 0x1
    ${DEVMEM} ${CONTROLLER_ECC_ERROR} w 0x1

    sleep 35
    key_count=`dmesg | grep "corrected" | wc -l`
    if [  ${key_count} -eq 0 ]
    then
        MESSAGE="FAIL\tcontoller reset for 1ecc error failed, no error message reported."
        echo ${MESSAGE}
        return 1
    fi

    ${DEVMEM} ${CONTROLLER_ECC_RESET_ADDR} w 0x0
    ${DEVMEM} ${CONTROLLER_ECC_ERROR} w 0x0
    MESSAGE="PASS"
    echo ${MESSAGE}
}

function main()
{
    #get system disk partition information.
    fio.config

    # call the implementation of the automation use cases
    test_case_function_run

}

main
