#!/bin/bash




# cycle all proximal phy switchec, query whether there is an event.
# IN :N/A
# OUT:N/A
function devmem_switch_all_phy()
{
    Test_Case_Title="devmem_switch_all_phy"

    begin_count=`fdisk -l | grep /dev/sd | wc -l`
    for i in `seq ${LOOP_PHY_COUNT}`
    do
        # clear the contents of the ring buffer.
        time dmesg -c > /dev/null

        phy_ops close all
        sleep 2
        phydown_count=`dmesg | grep 'phydown' | wc -l`
        [ ${phydown_count} -eq 0 ] && MESSAGE="FAIL\tclose all proximal phy, did not produce out event." && return 1

        phy_ops open all
        sleep 2
        phyup_count=`dmesg | grep 'phyup' | wc -l`
        [ ${phyup_count} -eq 0 ] && MESSAGE="FAIL\topen all proximal phy, did not produce in event." && return 1
    done

    sleep 60
    end_count=`fdisk -l | grep /dev/sd | wc -l`
    if [ ${begin_count} -ne ${end_count} ]
    then
        MESSAGE="FAIL\tloop all proximal phy switches, the number of disks is missing."
        return 1
    fi
    MESSAGE="PASS"
}


# loop hard_reset distal phy.
# IN : N/A
# OUT: N/A
function cycle_hard_reset_phy()
{
    Test_Case_Title="cycle_hard_reset_phy"

    beg_count=`fdisk -l | grep /dev/sd | wc -l`
    for i in `seq ${RESET_PHY_COUNT}`
    do
        change_sas_phy_file 1 "hard_reset"
    done
    end_count=`fdisk -l | grep /dev/sd | wc -l`

    if [ ${beg_count} -ne ${end_count} ]
    then
        MESSAGE="FAIL\tloop hard_reset distal phy, the number of disks is missing."
        return 1
    fi
    MESSAGE="PASS"
}

# loop link_reset distal phy.
# IN : N/A
# OUT: N/A
function cycle_link_reset_phy()
{
    Test_Case_Title="cycle_link_reset_phy"

    beg_count=`fdisk -l | grep /dev/sd | wc -l`
    for i in `seq ${RESET_PHY_COUNT}`
    do
        change_sas_phy_file 1 "link_reset"
    done
    end_count=`fdisk -l | grep /dev/sd | wc -l`

    if [ ${beg_count} -ne ${end_count} ]
    then
        MESSAGE="FAIL\tloop link_reset distal phy, the number of disks is missing."
        return 1
    fi
    MESSAGE="PASS"
}

# recycle enable distal phy.
# IN : N/A
# OUT: N/A
function cycle_enable_phy()
{
    Test_Case_Title="cycle_link_reset_phy"

    beg_count=`fdisk -l | grep /dev/sd | wc -l`
    for i in `seq ${RESET_PHY_COUNT}`
    do
        change_sas_phy_file 0 "enable"

        change_sas_phy_file 1 "enable"
    done
    end_count=`fdisk -l | grep /dev/sd | wc -l`

    if [ ${beg_count} -ne ${end_count} ]
    then
        MESSAGE="FAIL\trecycle enable distal phy, the number of disks is missing."
        return 1
    fi
    MESSAGE="PASS"
}

function main()
{
    # call the implementation of the automation use cases
    test_case_function_run
}

main
