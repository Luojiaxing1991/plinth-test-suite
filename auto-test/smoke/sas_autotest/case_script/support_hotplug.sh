#!/bin/bash


# disk running business, Reset the enable file status.
# IN : N/A
# OUT: N/A
function cycle_fio_multiple_enable()
{
    Test_Case_Title="cycle_fio_multiple_enable"

    beg_count=`fdisk -l | grep /dev/sd | wc -l`
    sed -i "{s/^runtime=.*/runtime=${FIO_ENABLE_TIME}/g;}" ${FIO_CONFIG_PATH}/fio.conf
    for i in `seq ${RESET_PHY_COUNT}`
    do
    ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio ${FIO_CONFIG_PATH}/fio.conf &

    change_sas_phy_file 0 "enable"

    wait
    change_sas_phy_file 1 "enable"
    sleep 60
    done
    end_count=`fdisk -l | grep /dev/sd | wc -l`
    if [ ${beg_count} -ne ${end_count} ]
    then
        MESSAGE="FAIL\tdisk runing business, switch enable disk, the number of disks is missing." && echo ${MESSAGE} && return 1
    fi
    MESSAGE="PASS"
    echo ${MESSAGE}

}

# disk running business, Reset the enable file status.
# IN : N/A
# OUT: N/A
function fio_multiple_enable()
{
    Test_Case_Title="fio_multiple_enable"

    beg_count=`fdisk -l | grep /dev/sd | wc -l`
    sed -i "{s/^runtime=.*/runtime=${FIO_ENABLE_TIME}/g;}" ${FIO_CONFIG_PATH}/fio.conf
    ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio ${FIO_CONFIG_PATH}/fio.conf &

    change_sas_phy_file 0 "enable"

    wait
    change_sas_phy_file 1 "enable"
    sleep 60
    end_count=`fdisk -l | grep /dev/sd | wc -l`
    if [ ${beg_count} -ne ${end_count} ]
    then
        MESSAGE="FAIL\tdisk runing business, switch enable disk, the number of disks is missing." && echo ${MESSAGE} && return 1
    fi
    MESSAGE="PASS"
    echo ${MESSAGE}
}

# disk running business, Reset the enable file status.
# IN : N/A
# OUT: N/A
function fio_single_enable()
{
    Test_Case_Title="fio_single_enable"

    sed -i "{s/^runtime=.*/runtime=${FIO_ENABLE_TIME}/g;}" ${FIO_CONFIG_PATH}/fio.conf
    ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio ${FIO_CONFIG_PATH}/fio.conf &

    phy_dir_list=`ls ${PHY_FILE_PATH}`
    for dir in ${phy_dir_list}
    do
        num=`echo "${dir}" | awk -F ":" '{print $NF}'`
        type=`cat ${PHY_FILE_PATH}/${dir}/target_port_protocols`
        if [ "${type}" == x"none" ]
        then
            continue
        fi
        if [ x"${type}" == x"ssp" -o x"${type}" == x"sata" ] \
        && [ ${num} -le ${EFFECTIVE_PHY_NUM} ]
        then
            echo 0 > ${PHY_FILE_PATH}/${dir}/enable
            wait
            echo 1 > ${PHY_FILE_PATH}/${dir}/enable
            sleep 2
            break
        fi
    done
    sleep 60
    end_count=`fdisk -l | grep /dev/sd | wc -l`
    if [ ${INIT_DISK_NUM} -ne ${end_count} ]
    then
        MESSAGE="FAIL\tdisk runing business, switch enable disk, the number of disks is missing." && echo ${MESSAGE} && return 1
    fi
    MESSAGE="PASS"
    echo ${MESSAGE}
}

function main()
{
    #get system disk partition information.
    fio_config

    # call the implementation of the automation use cases
    test_case_function_run
}

main
