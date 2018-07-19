#!/bin/bash

#MSI Enable+ compare the intterupts data before IO with after IO.
#IN :N/A
#OUT:N/A

function MSI_enable()
{
    msi=`${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/lspci -s 74:02.0 -vvv | grep "MSI: Enable+"`
    if [ x"${msi}" == x"" ]
    then
        MESSAGE="FAIL\tMSI is disable." && echo ${MESSAGE} && return 1
    fi

    cat /proc/interrupts | grep "hisi_sas_v3_hw" > ${BaseDir}/log/init_interrupts.txt
    sleep 1
    ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio fio.conf
    sleep 1
    cat /proc/interrupts | grep "hisi_sas_v3_hw" > ${BaseDir}/log/end_interrupts.txt
    different=`diff ${BaseDir}/log/init_interrupts.txt ${BaseDir}/log/end_interrupts.txt`
    if [ x"${different}" == x"" ]
    then
        MESSAGE="FAIL\tthe init and end intterupts data is same." && echo ${MESSAGE} && return 1
    fi
    MESSAGE="PASS"
    echo ${MESSAGE}
}

#Linux PCI device
#IN :N/A
#OUT:N/A

function reset_device()
{
    init_disk_num=`fdisk -l | grep /dev/sd | wc -l`
    #reset device
    echo 1 > ${DEVICE_PATH}/reset
    if [ $? -ne 0 ]
    then
        MESSAGE="FAIL\treset device fail." && echo ${MESSAGE} && return 1
    fi
    #remove device
    echo 1 > ${DEVICE_PATH}/remove
    if [ $? -ne 0 ]
    then
        MESSAGE="FAIL\tremove device fail." && echo ${MESSAGE} && return 1
    fi
    #rescan
    echo 1 > ${DEVICE_PATH}/rescan
    if [ $? -ne 0 ]
    then
        MESSAGE="FAIL\trescan fail." && echo ${MESSAGE} && return 1
    fi
    end_disk_num=`fdisk -l | grep /dev/sd | wc -l`
    if [ ${init_disk_num} -ne ${end_disk_num} ]
    then
         MESSAGE="FAIL\tthe disk is missing when reset device." && echo ${MESSAGE} && return 1
    fi
    MESSAGE="PASS"
    echo ${MESSAGE}
}


#support Byte read/write
#IN :N/A
#OUT:N/A

function set_sas_register()
{
    #read sas register
     ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/lspci -s 74:02.0 -vvv
     if [ $? -ne 0 ]
     then
         MESSAGE="FAIL\tread sas register fail." && echo ${MESSAGE} && return 1
     fi

     #set sas register
      ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/setpci -s 74:02.0 CAP_EXP+10.W=0x0058
      if [ $? -ne 0 ]
      then
          MESSAGE="FAIL\tset sas register fail." && echo ${MESSAGE} && return 1
      fi

      end_disk_num=`fdisk -l | grep /dev/sd | wc -l`
      if [ ${INIT_DISK_NUM} -ne ${end_disk_num} ]
      then
           MESSAGE="FAIL\tthe disk is missing when set sas register." && echo ${MESSAGE} && return 1
      fi
      MESSAGE="PASS"
      echo ${MESSAGE}
}


function main()
{
    # call the implementation of the automation use cases
    test_case_function_run
}

main




