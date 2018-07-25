#!/bin/bash



# Modify the value of the rate file.
# IN : $1 Need to modify phy file directory.
#      $2 Rate value.
#      $3 Rate file.
# OUT: N/A
function modify_phy_rate()
{
    local path=$1
    local rate=$2
    local name=$3

    echo "${rate}" > ${PHY_FILE_PATH}/${path}/${name}
    sleep 5
    maxminrate=`cat ${PHY_FILE_PATH}/${path}/${name} | awk -F ' ' '{print $1}'`
    mum=`echo "${rate}" | awk -F ' ' '{print $1}'`
    if [ ${maxminrate} != ${mum} ]
    then
        MESSAGE="FAIL\tthe ${name} of ${PHY_FILE_PATH}/${path} set to ${rate} is fail." && echo ${MESSAGE} && return 1
    fi
    negotiated=`cat ${PHY_FILE_PATH}/${path}/negotiated_linkrate | awk -F ' ' '{print $1}'`
    case ${name} in
        "minimum_linkrate")
        bool=`echo "${negotiated} ${mum}" | awk '{if($1<$2 && $1!=$2){print 1}else{print 0}}'`
        if [ ${bool} -eq 1 ]
        then
            MESSAGE="FAIL\tThe negotiation rate is less than the minimum rate, linkrate: ${linkrate} < ${mum}."
            echo ${MESSAGE}
            return 1
        fi
        ;;
        "maximum_linkrate")
        bool=`echo "${negotiated} ${mum}" | awk '{if($1>$2){print 1}else{print 0}}'`
        if [ ${bool} -eq 1 ]
        then
            MESSAGE="FAIL\tThe negotiation rate is bigger  than the maximum rate, linkrate: ${linkrate} > ${mum}."
            echo ${MESSAGE}
            return 1
        fi
        ;;
    esac
    sleep 10
    end_num=`fdisk -l | grep /dev/sd | wc -l`
    if [ "${INIT_DISK_NUM}" -ne "${end_num}" ]
    then
        MESSAGE="FAIL\tDisk missing when setting ${name} rate."
        echo ${MESSAGE}
        return 1
    fi

    return 0
}

# set rate link value
# IN : N/A
# OUT: N/A
function set_rate_link()
{
    Test_Case_Title="set_rate_link"

    for dir in `ls "${PHY_FILE_PATH}"`
    do
	    echo "Begin to check sas type in "${dir}
        type=`cat ${PHY_FILE_PATH}/${dir}/target_port_protocols`
        num=`echo "${dir}" | awk -F ":" '{print $NF}'`
        if [ x"${type}" == x"none" ] || [ ${num} -gt ${EFFECTIVE_PHY_NUM} ]
        then
            continue
        fi
        case ${type} in
            "sata")
            for rate in "${SATA_PHY_VALUE_LIST[@]}"
            do
                modify_phy_rate ${dir} "${rate}" "minimum_linkrate"
                if [ $? -eq 1 ]
                then
                    return 1
                fi
                modify_phy_rate ${dir} "${rate}" "maximum_linkrate"
                if [ $? -eq 1 ]
                then
                    return 1
                fi
            done
            ;;
            "ssp")
            for rate in "${SAS_PHY_VALUE_LIST[@]}"
            do
                modify_phy_rate ${dir} "${rate}" "minimum_linkrate"
                if [ $? -eq 1 ]
                then
                    return 1
                fi
                modify_phy_rate ${dir} "${rate}" "maximum_linkrate"
                if [ $? -eq 1 ]
                then
                    return 1
                fi
            done
            ;;
        esac
        # Reset initial rate value.
        echo "12.0 Gbit" > ${PHY_FILE_PATH}/${dir}/maximum_linkrate
        echo "1.5 Gbit" > ${PHY_FILE_PATH}/${dir}/minimum_linkrate
        sleep 5
    done
    MESSAGE="PASS"
    echo ${MESSAGE}
}
# fio set rate link value
# IN : N/A
# OUT: N/A
function fio_set_rate_link()
{
    Test_Case_Title="fio_set_rate_link"
    disk_num=`fdisk -l | grep /dev/sd | wc -l`
    init_time=`date +%s`
    while true
    do
        if [ ${INIT_DISK_NUM} -eq ${disk_num} ];then
            echo "The Disk Num is OK,Now run IO..."
            sed -i "{s/^bs=.*/bsrange=${BSRANGE}/g;}" ${FIO_CONFIG_PATH}/fio.conf
            ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio ${FIO_CONFIG_PATH}/fio.conf &
            sleep 5
            break
        else
            echo "The Disk Num is not ready,please wait...."
            sleep 10
            ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/lsscsi -t
            sleep 5
            disk_num=`fdisk -l | grep /dev/sd | wc -l`
            end_time=`date +%s`
            time=`expr $end_time - $init_time`
            if [ ${time} -gt ${IO_TIME} ];then
                 MESSAGE="FAIL\tthe number of disk is less when close and open phy, hard and link reset ,1bit ecc." && echo ${MESSAGE} && return 1
            fi
        fi
    done
    for i in `seq ${PHY_CONTROL_COUNT}`
    do
        for dir in `ls "${PHY_FILE_PATH}"`
        do
	        echo "Begin to check sas type in "${dir}
            type=`cat ${PHY_FILE_PATH}/${dir}/target_port_protocols`
            num=`echo "${dir}" | awk -F ":" '{print $NF}'`
            if [ x"${type}" == x"none" ] || [ ${num} -gt ${EFFECTIVE_PHY_NUM} ]
            then
                continue
            fi
            case ${type} in
                "sata" | "ssp")
                echo "${MINIMUM_LINK_VALUE}" > ${PHY_FILE_PATH}/${dir}/minimum_linkrate
                if [ $? -ne 0 ]
                then
                    MESSAGE="FAIL\tthe ${dir} minimum_linkrate set fail." && echo ${MESSAGE} && return 1
                fi
                echo "${MAXIMUM_LINK_VALUE}" > ${PHY_FILE_PATH}/${dir}/maximum_linkrate
                if [ $? -ne 0 ]
                then
                    MESSAGE="FAIL\tthe ${dir} maximum_linkrate set fail." && echo ${MESSAGE} && return 1
                fi
                ;;
            esac
            # Reset initial rate value.
            echo "12.0 Gbit" > ${PHY_FILE_PATH}/${dir}/maximum_linkrate
            echo "1.5 Gbit" > ${PHY_FILE_PATH}/${dir}/minimum_linkrate
            sleep 5
        done
    done
    MESSAGE="PASS"
    echo ${MESSAGE}
}

# fio set rate host reset value
# IN : N/A
# OUT: N/A
function fio_set_rate_host_reset()
{
    Test_Case_Title="fio_set_rate_host_reset"
    disk_num=`fdisk -l | grep /dev/sd | wc -l`
    init_time=`date +%s`
    while true
    do
        if [ ${INIT_DISK_NUM} -eq ${disk_num} ];then
            echo "The Disk Num is OK,Now run IO..."
            sed -i "{s/^bs=.*/bsrange=${BSRANGE}/g;}" ${FIO_CONFIG_PATH}/fio.conf
            ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio ${FIO_CONFIG_PATH}/fio.conf &
            sleep 5
            break
        else
            echo "The Disk Num is not ready,please wait...."
            sleep 10
            ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/lsscsi -t
            sleep 5
            disk_num=`fdisk -l | grep /dev/sd | wc -l`
            end_time=`date +%s`
            time=`expr $end_time - $init_time`
            if [ ${time} -gt ${IO_TIME} ];then
                 MESSAGE="FAIL\tthe number of disk is less when close and open phy, hard and link reset ,1bit ecc." && echo ${MESSAGE} && return 1
            fi
        fi
    done
    for i in `seq ${PHY_CONTROL_COUNT}`
    do
        for dir in `ls "${PHY_FILE_PATH}"`
        do
	        echo "Begin to check sas type in "${dir}
            type=`cat ${PHY_FILE_PATH}/${dir}/target_port_protocols`
            num=`echo "${dir}" | awk -F ":" '{print $NF}'`
            if [ x"${type}" == x"none" ] || [ ${num} -gt ${EFFECTIVE_PHY_NUM} ]
            then
                continue
            fi
            case ${type} in
                "sata" | "ssp")
                echo "${MINIMUM_LINK_VALUE}" > ${PHY_FILE_PATH}/${dir}/minimum_linkrate
                if [ $? -ne 0 ]
                then
                    MESSAGE="FAIL\tthe ${dir} minimum_linkrate set fail." && echo ${MESSAGE} && return 1
                fi
                echo "${MAXIMUM_LINK_VALUE}" > ${PHY_FILE_PATH}/${dir}/maximum_linkrate
                if [ $? -ne 0 ]
                then
                    MESSAGE="FAIL\tthe ${dir} maximum_linkrate set fail." && echo ${MESSAGE} && return 1
                fi
                ;;
            esac
            # Reset initial rate value.
            echo "12.0 Gbit" > ${PHY_FILE_PATH}/${dir}/maximum_linkrate
            echo "1.5 Gbit" > ${PHY_FILE_PATH}/${dir}/minimum_linkrate
            sleep 2
        done
            sleep 2
            echo "begin to adapter host_reset."
            hostx=`ls ${HOST_RESET_PATH} | grep "host"`
            echo "adapter" > ${HOST_RESET_PATH}/${hostx}/scsi_host/${hostx}/host_reset
            sleep 2
    done
    MESSAGE="PASS"
    echo ${MESSAGE}
}

# Rate set up
# IN : N/A
# OUT: N/A
function rate_set_up()
{
    Test_Case_Title="rate_set_up"

    set_rate_link
    [ $? -ne 0 ] && return 1

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
