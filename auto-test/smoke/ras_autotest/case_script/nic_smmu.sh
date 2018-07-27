#!/bin/bash

# Nic Smmu AXI Error Injection
# IN :N/A
# OUT:N/A
function nic_smmu_axi_error()
{
	local set mNicSmmuReg=0x100000EA0
	local set mGpioInter=`cat /proc/interrupts | grep "GICv3  122"|awk -F'[ \t]+' '{print $3}'`
	output=`dmesg -c`
	sleep 10s
	busybox devmem ${mNicSmmuReg} 32 0x10010
	sleep 20s
	local set newGpioInter=`cat /proc/interrupts | grep "GICv3  122"|awk -F'[ \t]+' '{print $3}'`
	if [ "${mGpioInter}" = "${newGpioInter}" -a `cat /etc/issue |wc -l` -eq 0 ];then
		MESSAGE="FAIL\t No NIC SMMU AXI error GPIO interrupts produce!"
	else
		dmesg
		dmesg > ${BaseDir}/log/nic_smmu_axi.txt
		flag=`grep -e 'event severity: corrected' -e 'type: corrected' ${BaseDir}/log/nic_smmu_axi.txt |wc -l`
		if [ ${flag} -lt 2 ];then
			MESSAGE="FAIL\t NIC SMMU AXI error APEI list message error!"
		else
			MESSAGE="PASS"
		fi
	fi
	busybox devmem ${mNicSmmuReg} 32 0x0
	echo ${MESSAGE}
}

# Nic Smmu TBU Error Injection,Once injection continuous injection,need to clear quickly
# IN :N/A
# OUT:N/A
function nic_smmu_tbu_error()
{
	local set mNicSmmuReg=0x100000EA0
	local set mGpioInter=`cat /proc/interrupts | grep "GICv3  122"|awk -F'[ \t]+' '{print $3}'`
	output=`dmesg -c`
	sleep 10s
	busybox devmem ${mNicSmmuReg} 32 0x20011
	ifconfig -a
	sleep 1s
	busybox devmem ${mNicSmmuReg} 32 0x0
	sleep 20s
	local set newGpioInter=`cat /proc/interrupts | grep "GICv3  122"|awk -F'[ \t]+' '{print $3}'`
	if [ "${mGpioInter}" = "${newGpioInter}" -a `cat /etc/issue |wc -l` -eq 0 ];then
		MESSAGE="FAIL\t No NIC SMMU TBU error GPIO interrupts produce!"
	else
		dmesg
		dmesg > ${BaseDir}/log/nic_smmu_tbu.txt
		flag=`grep -e 'event severity: corrected' -e 'type: corrected' ${BaseDir}/log/nic_smmu_tbu.txt |wc -l`
		if [ ${flag} -lt 2 ];then
			MESSAGE="FAIL\t NIC SMMU TBU error APEI list message error!"
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
