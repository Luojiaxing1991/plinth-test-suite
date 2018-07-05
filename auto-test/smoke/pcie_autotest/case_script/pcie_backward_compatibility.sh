#!/bin/bash

# PCIe 3.0 backward compatibility.
# IN : N/A
# OUT: N/A
function backward_compatibility_raid3008()
{
    if [ "${PCIE_LOCAL}"x != "True"x ]
    then
        Test_Case_Title="backward_compatibility_raid3008"

        # device_3008_id=$(lspci -k | grep "${RAID3008_QUERY_KEYWORDS}" | awk -F ' ' '{print $1}' | sed -n '1p')
        device_3008_id=$(ssh root@${BACK_IP} "lspci -k | grep ${RAID3008_QUERY_KEYWORDS}")
        device_3008_id=$(echo ${device_3008_id} | awk -F ' ' '{print $1}' | sed -n '1p')
        if [ x"${device_3008_id}" == x"" ]
        then
            MESSAGE="FAIL\tFailed to query the raid3008. Please check the test environment."
            return 1
        fi
        # speed_value=$(ssh root@${BACK_IP} "lspci -s ${device_3008_id} -vvv | grep "LnkSta:" | awk -F ' ' '{print $3}' | sed s/[,]//g")
        # width_value=$(ssh root@${BACK_IP} "lspci -s ${device_3008_id} -vvv | grep "LnkSta:" | awk -F ' ' '{print $5}' | sed s/[,]//g")
        speed_value=$(ssh root@${BACK_IP} "lspci -s ${device_3008_id} -vvv | grep "LnkSta:"")
        speed_value=$(echo ${speed_value} | awk -F ' ' '{print $3}' | sed s/[,]//g)
        width_value=$(ssh root@${BACK_IP} "lspci -s ${device_3008_id} -vvv | grep "LnkSta:"")
        width_value=$(echo ${width_value} | awk -F ' ' '{print $5}' | sed s/[,]//g)
        echo ${speed_value}
        echo ${width_value}

        if [ x"${speed_value}" != x"${RAID3008_SPEED_VALUE}" -o x"${width_value}" != x"${RAID3008_WIDTH_VALUE}" ]
        then
            MESSAGE="FAIL\tRaid3008 speed or width does not match, Speed: ${speed_value}, Width: ${width_value}"
            return 1
        fi

        # Get raid3008 connection disk list.
        get_all_disk_list
        # Generate the fio tool configuration file.
        fio_config

        tmp_path="/home/tmp_fio"
        ssh root@${BACK_IP} "mkdir -p ${tmp_path}"
        scp ${PCIE_TOP_DIR}/../${COMMON_TOOL_PATH}/fio root@${BACK_IP}:${tmp_path}
        sed -i "{s/^runtime=.*/runtime=${RAID3008_FIO_TIME}/g;}" ${FIO_CONFG}
        for rw in "${FIO_RW[@]}"
        do
            sed -i "{s/^rw=.*/rw=${rw}/g;}" ${FIO_CONFG}
            scp ${FIO_CONFG} root@${BACK_IP}:${tmp_path}
            ssh root@${BACK_IP} "${tmp_path}/fio ${tmp_path}/${FIO_CONFG}"
            # ssh root@${BACK_IP} "${PCIE_TOP_DIR}/../${COMMON_TOOL_PATH}/fio ${FIO_CONFG}"
            if [ $? -ne 0 ]
            then
                MESSAGE="FAIL\tFIO tool in \"${rw}\" raid3008 disk operation, error."
                return 1
            fi
        done

        MESSAGE="PASS"
        echo ${MESSAGE}
    else
        localTest_backward_compatibility_raid3008
    fi

}

# PCIe 3.0 backward compatibility.
# IN : N/A
# OUT: N/A
function backward_compatibility_es3000()
{
    Test_Case_Title="backward_compatibility_es3000"

    device_es3000_id=`lspci -k | grep "${ES3000_QUERY_KEYWORDS}" | awk -F ' ' '{print $1}'`
    if [ x"${device_es3000_id}" == x"" ]
    then
        MESSAGE="FAIL\tFailed to query the es3000. Please check the test environment."
        return 1
    fi

    speed_value=`lspci -s ${device_es3000_id} -vvv | grep "LnkSta:" | awk -F ' ' '{print $3}' | sed s/[,]//g`
    width_value=`lspci -s ${device_es3000_id} -vvv | grep "LnkSta:" | awk -F ' ' '{print $5}' | sed s/[,]//g`

    if [ x"${speed_value}" != x"${ES3000_SPEED_VALUE}" -o x"${width_value}" != x"${ES3000_WIDTH_VALUE}" ]
    then
        MESSAGE="FAIL\tES3000 speed or width does not match, Speed: ${speed_value}, Width: ${width_value}"
        return 1
    fi

    # Get ES3000 connection disk list.
    driver_use=`lspci -s ${device_es3000_id} -vvv | grep "Kernel driver in use" | awk -F ' ' '{print $5}'`
    driver_name=`lsblk -l | grep "${driver_use}" | awk -F ' ' '{print $1}'`
    ALL_DISK_PART_NAME="/dev/${driver_name}"
    # Generate the fio tool configuration file.
    fio_config

    sed -i "{s/^runtime=.*/runtime=${ES3000_FIO_TIME}/g;}" ${FIO_CONFG}
    for rw in "${FIO_RW[@]}"
    do
        sed -i "{s/^rw=.*/rw=${rw}/g;}" ${FIO_CONFG}
        ${PCIE_TOP_DIR}/../${COMMON_TOOL_PATH}/fio ${FIO_CONFG}
        if [ $? -ne 0 ]
        then
            MESSAGE="FAIL\tFIO tool in \"${rw}\" ES3000 disk operation, error."
            return 1
        fi
    done

    MESSAGE="PASS"
    echo ${MESSAGE}
}

# PCIe 3.0 backward compatibility.
# IN : N/A
# OUT: N/A
function backward_compatibility_I350()
{
    eth_list=`ifconfig -a | grep "Link encap:Ethernet" | awk -F ' ' '{print $1}'`
    for eth in ${eth_list}
    do
        i350_marked=`ethtool -i ${eth} | grep "driver" | awk -F ' ' '{print $2}'`
        if [ x"${i350_marked}" != x"igb" ]
        then
            continue
        fi
        # Query the unique identifier of the I350 NIC.
        only_id=`ethtool -i ${eth} | grep "bus-info" | awk -F ' ' '{print $2}'`
        i350_enable_info=`lspci -s ${only_id} -vvv | grep "MSI-X: Enable+"`
        if [ x"${i350_enable_info}" == x"" ]
        then
            MESSAGE="FAIL\tFailed to query the I350(${only_id}) NIC. Please check the test environment."
            return 1
        fi
        speed=`lspci -s ${only_id} -vvv | grep "LnkCap" | awk -F ' ' '{print $5}' | sed s/[,]//g`
        width=`lspci -s ${only_id} -vvv | grep "LnkCap" | awk -F ' ' '{print $7}' | sed s/[,]//g`

        if [ x"${speed}" != x"5GT/s" -o x"${width}" != x"x4" ]
        then
            MESSAGE="FAIL\tI350 speed or width does not match, Speed: ${speed}, Width: ${width}"
            return 1
        fi

        ifconfig ${eth} 192.168.144.214
        lost_rate=`ping -c 10 -w 8 -S 192.168.2.144 127.0.0.1 \
        | grep 'packet loss' \
        | awk -F 'packet loss' '{print $1}' \
        | awk '{print $NF}' | sed 's/%//g'`
        if [ ${lost_rate} -ne 0 ]
        then
            MESSAGE="Packet loss when pinging packet through I350 network card, packet loss: ${lost_rate}%."
            return 1
        fi
        ifconfig ${eth} down
    done

    MESSAGE="PASS"
    echo ${MESSAGE}
    return 0
}

# PCIe 3.0 backward compatibility.
# IN : N/A
# OUT: N/A
function backward_compatibility_82599()
{
    Test_Case_Title=""

    eth_list=`ifconfig -a | grep "Link encap:Ethernet" | awk -F ' ' '{print $1}'`
    for eth in ${eth_list}
    do
        marked_82599=`ethtool -i ${eth} | grep "driver" | awk -F ' ' '{print $2}'`
        if [ x"${marked_82599}" != x"ixgbe" ]
        then
            continue
        fi
        # Query the unique identifier of the 82599 NIC.
        only_id=`ethtool -i ${eth} | grep "bus-info" | awk -F ' ' '{print $2}'`
        # Check is the unique identifier of the 82599 NIC.
        i350_enable_info=`lspci -s ${only_id} -vvv | grep "MSI-X: Enable+"`
        if [ x"${i350_enable_info}" == x"" ]
        then
            MESSAGE="FAIL\tFailed to query the 82599(${only_id}) NIC. Please check the test environment."
            return 1
         fi

        speed=`lspci -s ${only_id} -vvv | grep "LnkCap" | awk -F ' ' '{print $5}' | sed s/[,]//g`
        width=`lspci -s ${only_id} -vvv | grep "LnkCap" | awk -F ' ' '{print $7}' | sed s/[,]//g`

        if [ x"${speed}" != x"5GT/s" -o x"${width}" != x"x8" ]
        then
            MESSAGE="FAIL\t82599ES speed or width does not match, Speed: ${speed}, Width: ${width}"
            return 1
        fi

        ifconfig ${eth} 192.168.144.214
        lost_rate=`ping -c 10 -w 8 -S 192.168.2.144 127.0.0.1 \
        | grep 'packet loss' \
        | awk -F 'packet loss' '{print $1}' \
        | awk '{print $NF}' | sed 's/%//g'`
        if [ ${lost_rate} -ne 0 ]
        then
            MESSAGE="Packet loss when pinging packet through 82599 network card, packet loss: ${lost_rate}%."
            return 1
        fi
        ifconfig ${eth} down
    done

    MESSAGE="PASS"
    echo ${MESSAGE}
    return 0
}

function localTest_backward_compatibility_raid3008()
{
    Test_Case_Title="localTest_backward_compatibility_raid3008"

    echo "local test ----------------------------------->"
    # device_3008_id=$(lspci -k | grep "${RAID3008_QUERY_KEYWORDS}" | awk -F ' ' '{print $1}' | sed -n '1p')
    device_3008_id=$(lspci -k | grep ${RAID3008_QUERY_KEYWORDS})
    device_3008_id=$(echo ${device_3008_id} | awk -F ' ' '{print $1}' | sed -n '1p')
    if [ x"${device_3008_id}" == x"" ]
    then
        MESSAGE="FAIL\tFailed to query the raid3008. Please check the test environment."
        return 1
    fi
    # speed_value=$(ssh root@${BACK_IP} "lspci -s ${device_3008_id} -vvv | grep "LnkSta:" | awk -F ' ' '{print $3}' | sed s/[,]//g")
    # width_value=$(ssh root@${BACK_IP} "lspci -s ${device_3008_id} -vvv | grep "LnkSta:" | awk -F ' ' '{print $5}' | sed s/[,]//g")
    speed_value=$(lspci -s ${device_3008_id} -vvv | grep "LnkSta:")
    speed_value=$(echo ${speed_value} | awk -F ' ' '{print $3}' | sed s/[,]//g)
    width_value=$(lspci -s ${device_3008_id} -vvv | grep "LnkSta:")
    width_value=$(echo ${width_value} | awk -F ' ' '{print $5}' | sed s/[,]//g)
    echo ${speed_value}
    echo ${width_value}

    if [ x"${speed_value}" != x"${RAID3008_SPEED_VALUE}" -o x"${width_value}" != x"${RAID3008_WIDTH_VALUE}" ]
    then
        MESSAGE="FAIL\tRaid3008 speed or width does not match, Speed: ${speed_value}, Width: ${width_value}"
        return 1
    fi

    # Get raid3008 connection disk list.
    get_all_disk_list
    # Generate the fio tool configuration file.
    fio_config

    tmp_path="/home/tmp_fio"
    mkdir -p ${tmp_path}
    scp ${PCIE_TOP_DIR}/../${COMMON_TOOL_PATH}/fio ${tmp_path}
    sed -i "{s/^runtime=.*/runtime=${RAID3008_FIO_TIME}/g;}" ${FIO_CONFG}
    for rw in "${FIO_RW[@]}"
    do
        sed -i "{s/^rw=.*/rw=${rw}/g;}" ${FIO_CONFG}
        scp ${FIO_CONFG} ${tmp_path}
        ${tmp_path}/fio ${tmp_path}/${FIO_CONFG}
        # ssh root@${BACK_IP} "${PCIE_TOP_DIR}/../${COMMON_TOOL_PATH}/fio ${FIO_CONFG}"
        if [ $? -ne 0 ]
        then
            MESSAGE="FAIL\tFIO tool in \"${rw}\" raid3008 disk operation, error."
            return 1
        fi
    done

    MESSAGE="PASS"
    echo ${MESSAGE}
}


setTrustRelation

function main()
{
    # call the implementation of the automation use cases
    test_case_function_run
}

main
