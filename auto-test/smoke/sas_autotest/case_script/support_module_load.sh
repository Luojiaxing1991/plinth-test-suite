#!/bin/bash


# module load and uninstall.
# IN : N/A
# OUT: N/A
function module_load_uninstall()
{
    Test_Case_Title="module_load_uninstall"

    local ko_info
    ko_info=`echo ${MODULE_KO_FILE} | sed 's/|/ /g'`
    for ko in ${ko_info}
    do
        insmod ${SAS_TOP_DIR}/${MODULE_KO_PATH}/${ko}
        return_num=$?
        info=`lsmod | grep ${ko%.*}`

        if [ ${return_num} -ne 0 -o x"${info}" == x"" ]
        then
            MESSAGE="FAIL\tinsmod load ${ko} fail."
            echo ${MESSAGE}
            return 1
        fi
    done

    #Get system disk partition information.
    get_all_disk_part
    if [ ${#ALL_DISK_PART_NAME[@]} -eq 0 ]
    then
        MESSAGE="FAIL\tload ko file, identify the disk failed" && echo ${MESSAGE} && return 1
    fi

    #Mount the disk partition to the local.
    for dev in "${ALL_DISK_PART_NAME[@]}"
    do
        mount_disk ${dev}
        return_num=$?
        if [ ${return_num} -ne 0 ] 
        then
            MESSAGE="FAIL\tfailed to mount \"${dev}\"" && echo ${MESSAGE} && return 1
        fi
        umount ${dev}
    done

    for ko in ${ko_info}
    do
        rmmod ${SAS_TOP_DIR}/${MODULE_KO_PATH}/${ko}
        return_num=$?
        info=`lsmod | grep ${ko%.*}`

        if [ ${return_num} -ne 0 -o x"${info}" == x"" ]
        then
            MESSAGE="FAIL\trmmod uninstall  ${ko} fail."
            echo ${MESSAGE}
            return 1
        fi
    done
    MESSAGE="PASS"
    echo ${MESSAGE}
}

function main()
{
    # call the implementation of the automation use cases
    test_case_function_run
}

main
