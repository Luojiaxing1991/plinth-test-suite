#!/bin/bash


#open and close phy,hard reset,link reset,bit 0xa2000200 0x1 ecc when fio all disk.
#IN :N/A
#OUT:N/A

function fio_phy_reset_bit()
{
   Test_Case_Title="fio_phy_reset_bit"
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
   change_sas_phy_file 1 "hard_reset"
   sleep 2
   change_sas_phy_file 1 "link_reset"
   sleep 2
   change_sas_phy_file 0 "enable"
   sleep 2
   change_sas_phy_file 1 "enable"
   sleep 2
   bit_type=$(echo ${TEST_CASE_TITLE} | awk -F "_" '{print $6}')
   if [ ${bit_type} == "single" ];then
       bit="0x1"
   elif [ ${bit_type} == "double" ];then
       bit="0x11"
   fi
   ${DEVMEM} ${CONTROLLER_ECC_RESET_ADDR} w 0x1
   ${DEVMEM} ${CONTROLLER_ECC_ERROR} w ${bit}
   sleep 5
   MESSAGE="PASS"
   echo ${MESSAGE}

}
##open and close phy,hard reset,link reset when fio all disk.
#IN :N/A
#OUT:N/A

function fio_phy_reset()
{
   Test_Case_Title="fio_phy_reset"
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
   change_sas_phy_file 1 "hard_reset"
   sleep 2
   change_sas_phy_file 1 "link_reset"
   sleep 2
   change_sas_phy_file 0 "enable"
   sleep 2
   change_sas_phy_file 1 "enable"
   sleep 5
   MESSAGE="PASS"
   echo ${MESSAGE}

}


##hard reset,link reset,host_reset ecc when fio all disk.
#IN :N/A
#OUT:N/A

function fio_hard_link_host_ecc()
{
   Test_Case_Title="fio_hard_link_host_ecc"
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
   change_sas_phy_file 1 "hard_reset"
   sleep 2
   change_sas_phy_file 1 "link_reset"
   sleep 2
   for i in `seq ${PHY_ERROR_COUNT}`
   do
       bit_type=$(echo ${TEST_CASE_TITLE} | awk -F "_" '{print $5}')
       [ ${bit_type} -ne "RX" ] && ${DEVMEM} 0xa2002340 32 0x17ff000f && sleep 5
       [ ${bit_type} -ne "TX" ] && ${DEVMEM} 0xa2002344 32 0x170f0001 && sleep 5
       if [ ${bit_type} -ne "host" ];then
           ${DEVMEM} 0xa2002344 32 0x170f0001
           sleep 2
           echo "begin to adapter host_reset."
           hostx=`ls ${HOST_RESET_PATH} | grep "host"`
           echo "adapter" > ${HOST_RESET_PATH}/${hostx}/scsi_host/${hostx}/host_reset
           sleep 5
       fi

   done
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
