#!/bin/bash

# L3t Error Injection
# IN : the injection value
# OUT:N/A

function l3t_error_injection()
{
	local set mL3TReg=0x90180408
	local set mGpioInter=`cat /proc/interrupts | grep "GICv3  122"|awk -F'[ \t]+' '{print $3}'`
	output=`dmesg -c`
	sleep 1s
	busybox devmem ${mL3TReg} 32 $1
	sleep 2s
	local set newGpioInter=`cat /proc/interrupts | grep "GICv3  122"|awk -F'[ \t]+' '{print $3}'`
	if [ "${mGpioInter}" = "${newGpioInter}" -a `cat /etc/issue |wc -l` -eq 0 ];then
		MESSAGE="FAIL\t No L3T ERROR GPIO interrupts produce!"
	else
		dmesg
		dmesg > ${BaseDir}/log/l3t_error.txt
		flag=`grep -e 'event severity: corrected' -e 'section_type: ARM processor error' ${BaseDir}/log/l3t_error.txt |wc -l`
		if [ ${flag} -lt 2 ];then
			MESSAGE="FAIL\t L3T error APEI list message error!"
		else
			MESSAGE="PASS"
		fi
	fi
	busybox devmem ${mL3TReg} 32 0x0
	echo ${MESSAGE}
}

# L3d Error Injection
# IN : the injection regist and value
# OUT:N/A
function l3d_error_injection()
{
	for i in {1..50}
	do
		mL3tVal=`busybox devmem 0x90142010`
		mL3dVal=`busybox devmem 0x90182010`
		busybox devmem 0x90142010 32 ${mL3tVal}
		busybox devmem 0x90182010 32 ${mL3dVal}
		sleep 1s
	done
	sleep 10s
	local set mGpioInter=`cat /proc/interrupts | grep "GICv3  122"|awk -F'[ \t]+' '{print $3}'`
	output=`dmesg -c`
	sleep 1s
	busybox devmem $1 32 $2
	sleep 20s
	local set newGpioInter=`cat /proc/interrupts | grep "GICv3  122"|awk -F'[ \t]+' '{print $3}'`
	if [ "${mGpioInter}" = "${newGpioInter}" -a `cat /etc/issue |wc -l` -eq 0 ];then
		MESSAGE="FAIL\t No L3D ERROR GPIO interrupts produce!"
	else
		dmesg
		dmesg > ${BaseDir}/log/l3d_error.txt
		flag=`grep -e 'event severity: corrected' -e 'section_type: ARM processor error' ${BaseDir}/log/l3d_error.txt |wc -l`
		if [ ${flag} -lt 2 ];then
			MESSAGE="FAIL\t L3D error APEI list message error!"
		else
			MESSAGE="PASS"
		fi
	fi
	busybox devmem $1 32 0x0
	echo ${MESSAGE}
}

# L3t dir Error
# IN :N/A
# OUT:N/A
function l3t_dir_memory_ecc()
{
	l3t_error_injection 0x2000000
}

# L3t std Error
# IN :N/A
# OUT:N/A
function l3t_std_memory_ecc()
{
	l3t_error_injection 0x8000000
}

# L3cache Report
# IN :N/A
# OUT:N/A
function l3cache_reprot()
{
	l3t_error_injection 0x8000000
}

# L3d right bit1 error
# IN :N/A
# OUT:N/A
function l3d_rigth_bit1()
{
	l3d_error_injection 0x901405f4 0x101
}

# L3d right bit2 error
# IN :N/A
# OUT:N/A
function l3d_rigth_bit2()
{
	l3d_error_injection 0x901405f4 0x1010000
}

# L3d left bit1 error
# IN :N/A
# OUT:N/A
function l3d_left_bit1()
{
	l3d_error_injection 0x901405f0 0x101
}

# L3d left bit2 error
# IN :N/A
# OUT:N/A
function l3d_left_bit2()
{
	l3d_error_injection 0x901405f0 0x1010000
}
function main()
{
	test_case_function_run
}

main