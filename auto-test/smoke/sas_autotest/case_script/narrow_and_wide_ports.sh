#!/bin/bash


# disk running business, Reset the single_hard_reset single_link_reset cycle_hard_reset cycle_link_reset file status.
# IN : N/A
# OUT: N/A

function fio_reset()
{
    Test_Case_Title="fio_reset"
    RESET_TYPE=$(echo ${TEST_CASE_TITLE} | awk -F "_" '{print $2}')
    FIO_RESET_COUNT=$(echo ${TEST_CASE_TITLE} | awk -F "_" '{print $4}')

    beg_count=`fdisk -l | grep /dev/sd | wc -l`
    sed -i "{s/^runtime=.*/runtime=${FIO_RESET_TIME}/g;}" fio.conf
    ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio fio.conf &
    for i in `seq ${FIO_RESET_COUNT}`
    do
        change_sas_phy_file 1 "${RESET_TYPE}_reset"
        sleep 2
    done

    wait
    end_count=`fdisk -l | grep /dev/sd | wc -l`
    if [ ${beg_count} -ne ${end_count}  ]
    then
        MESSAGE="FAIL\tdisk running business, cycle hard_reset remote phy, the number of disks is missing."
        echo ${MESSAGE}
        return 1
    fi
    MESSAGE="PASS"
    echo ${MESSAGE}
}

# disk running business, cycle reset the hard_reset and link_reset file status.
# IN : N/A
# OUT: N/A
function fio_cycle_hard_link_reset_phy()
{
    Test_Case_Title="fio_cycle_hard_link_reset_phy"

     beg_count=`fdisk -l | grep /dev/sd | wc -l`
    sed -i "{s/^runtime=.*/runtime=${FIO_RESET_TIME}/g;}" fio.conf
    ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio fio.conf &

    for i in `seq ${FIO_RESET_COUNT}`
    do
        change_sas_phy_file 1 "hard_reset"
        sleep 5
        change_sas_phy_file 1 "link_reset"
        sleep 2
    done

    wait
    end_count=`fdisk -l | grep /dev/sd | wc -l`
    if [ ${beg_count} -ne ${end_count}  ]
    then
        MESSAGE="FAIL\tdisk running business, cycle link_reset remote phy, the number of disks is missing."
        echo ${MESSAGE}
        return 1
    fi
    MESSAGE="PASS"
    echo ${MESSAGE}


}

function main()
{
    #Get system disk partition information.
    fio_config

    # call the implementation of the automation use cases
    test_case_function_run
}

main
