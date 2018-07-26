#!/bin/bash

# HAC Smmu AXI Error Injection
# IN :N/A
# OUT:N/A
function hac_smmu_axi_error()
{
	local set mNicSmmuReg=0x140000EA0
	local set mGpioInter=`cat /proc/interrupts | grep "GICv3  122"|awk -F'[ \t]+' '{print $3}'`
	output=`dmesg -c`
	sleep 10s
	busybox devmem ${mNicSmmuReg} 32 0x10010
	fdisk -l 
	sleep 20s
	local set newGpioInter=`cat /proc/interrupts | grep "GICv3  122"|awk -F'[ \t]+' '{print $3}'`
	if [ "${mGpioInter}" = "${newGpioInter}" -a `cat /etc/issue |wc -l` -eq 0 ];then
		MESSAGE="FAIL\t No HAC SMMU AXI ERROR GPIO interrupts produce!"
	else
		dmesg
		dmesg > ${BaseDir}/log/hac_smmu_axi.txt
		flag=`grep -e 'event severity: corrected' -e 'type: corrected' ${BaseDir}/log/hac_smmu_axi.txt |wc -l`
		if [ ${flag} -lt 2 ];then
			MESSAGE="FAIL\t HAC SMMU AXI error APEI list message error!"
		else
			MESSAGE="PASS"
		fi
	fi
	busybox devmem ${mNicSmmuReg} 32 0x0
	echo ${MESSAGE}
}

# HAC Smmu TBU Error Injection
# IN :N/A
# OUT:N/A
function hac_smmu_tbu_error()
{
	local set mNicSmmuReg=0x140000EA0
	local set mGpioInter=`cat /proc/interrupts | grep "GICv3  122"|awk -F'[ \t]+' '{print $3}'`
	output=`dmesg -c`
	sleep 10s
	busybox devmem ${mNicSmmuReg} 32 0x20011
	fdisk -l 
	busybox devmem ${mNicSmmuReg} 32 0x0
	sleep 20s
	local set newGpioInter=`cat /proc/interrupts | grep "GICv3  122"|awk -F'[ \t]+' '{print $3}'`
	if [ "${mGpioInter}" = "${newGpioInter}" -a `cat /etc/issue |wc -l` -eq 0 ];then
		MESSAGE="FAIL\t No HAC SMMU TBU ERROR GPIO interrupts produce!"
	else
		dmesg
		dmesg > ${BaseDir}/log/hac_smmu_tbu.txt
		flag=`grep -e 'event severity: corrected' -e 'type: corrected' ${BaseDir}/log/hac_smmu_tbu.txt |wc -l`
		if [ ${flag} -lt 2 ];then
			MESSAGE="FAIL\t HAC SMMU TBU error APEI list message error!"
		else
			MESSAGE="PASS"
		fi
	fi
	echo ${MESSAGE}
}

function main()
{
	test_case_function_run
}

main 
