#!/bin/bash

# The HNS Error Register Enable
# IN :N/A
# OUT:N/A
function hns_reg_enable()
{
	local set mControl
	local set mVal=0x43f12001
	local set mReg=0xd7c00024

	mControl=`busybox devmem ${mReg}`
	flag=$[${mControl}-${mVal}]
	if [ ${flag} -ne 0 ];then
		busybox devmem ${mReg} w ${mVal}
	fi
}

# The hns cmdq nic error
# IN :the error val
# OUT:N/A
function hns_cmdq_nic_error_injection()
{
	local set mSavaReg=0x13000410c
	local set mEnableReg=0x130002090
	local set mEnableVal=0xffff
	local set mErrReg=0x130004110
	local set mClearVal=0x0
	local set mErrorVal=`echo ${TEST_CASE_TITLE} | awk -F '_' '{print $NF}'`
	echo error val ${mErrorVal}

	hns_reg_enable

	output=`dmesg -c`
	sleep 10s

	busybox devmem ${mSavaReg} 32 ${mEnableVal}
	busybox devmem ${mEnableReg} 32 ${mEnableVal}
	busybox devmem ${mErrReg} 32 ${mErrorVal}
	busybox devmem ${mErrReg} 32 ${mClearVal}
	sleep 30s
	dmesg > ${BaseDir}/log/hns_error.txt
	if [ `echo ${mErrorVal} | grep [1,4] | wc -l` -eq 1 ];then
		ce_error_judge
		if [ $? -eq 1 ];then
			MESSAGE="PASS"
		else
			MESSAGE="FAIL\t HNS cmdq nic CE APEI list is error!"
		fi
	else
		ue_error_judge
		if [ $? -eq 1 ];then
			MESSAGE="PASS"
		else
			MESSAGE="FAIL\t HNS cmdq nic UE APEI list is error!"
		fi		
	fi
	echo ${MESSAGE}
}

# The hns cmdq roce error
# IN :the error val
# OUT:N/A
function hns_cmdq_roce_error_injection()
{
	local set mSavaReg=0x13000410c
	local set mEnableReg=0x1300020B0
	local set mEnableVal=0xffff
	local set mSavaVal=0xffff0000
	local set mErrReg=0x130004110
	local set mClearVal=0x0
	local set mErrorVal=`echo ${TEST_CASE_TITLE} | awk -F '_' '{print $NF}'`
	echo error val ${mErrorVal}

	hns_reg_enable

	output=`dmesg -c`
	sleep 10s

	busybox devmem ${mSavaReg} 32 ${mSavaVal}
	busybox devmem ${mEnableReg} 32 ${mEnableVal}
	busybox devmem ${mErrReg} 32 ${mErrorVal}
	busybox devmem ${mErrReg} 32 ${mClearVal}
	sleep 30s
	dmesg > ${BaseDir}/log/hns_error.txt
	if [ `echo ${mErrorVal} | grep [1,4] | wc -l` -eq 1 ];then
		ce_error_judge
		if [ $? -eq 1 ];then
			MESSAGE="PASS"
		else
			MESSAGE="FAIL\t HNS cmdq roce CE APEI list is error!"
		fi
	else
		ue_error_judge
		if [ $? -eq 1 ];then
			MESSAGE="PASS"
		else
			MESSAGE="FAIL\t HNS cmdq roce UE APEI list is error!"
		fi		
	fi
	echo ${MESSAGE}
}

# The hns imp tcm error
# IN :the error val
# OUT:N/A
function hns_imp_tcm_error_injection()
{
	local set mSavaReg=0x130004100
	local set mEnableReg=0x130000090
	local set mEnableVal=0xffff
	local set mSavaVal=0xffff
	local set mErrReg=0x130004104
	local set mClearVal=0x0
	local set mErrorVal=`echo ${TEST_CASE_TITLE} | awk -F '_' '{print $NF}'`
	echo error val ${mErrorVal}

	hns_reg_enable

	output=`dmesg -c`
	sleep 10s

	busybox devmem ${mSavaReg} 32 ${mSavaVal}
	busybox devmem ${mEnableReg} 32 ${mEnableVal}
	busybox devmem ${mErrReg} 32 ${mErrorVal}
	busybox devmem ${mErrReg} 32 ${mClearVal}
	sleep 30s
	dmesg > ${BaseDir}/log/hns_error.txt
	if [ `echo ${mErrorVal} | grep [1,4] | wc -l` -eq 1 ];then
		ce_error_judge
		if [ $? -eq 1 ];then
			MESSAGE="PASS"
		else
			MESSAGE="FAIL\t HNS imp tcm CE APEI list is error!"
		fi
	else
		ue_error_judge
		if [ $? -eq 1 ];then
			MESSAGE="PASS"
		else
			MESSAGE="FAIL\t HNS imp tcm UE APEI list is error!"
		fi		
	fi
	echo ${MESSAGE}
}

# The hns tqp error
# IN :the error val
# OUT:N/A
function hns_tqp_error_injection()
{
	local set mSavaReg=0x130004200
	local set mEnableReg=0x13000420c
	local set mEnableVal=0xffff
	local set mSavaVal=0xffff
	local set mErrReg=0x130004204
	local set mClearVal=0x0
	local set mErrorVal=`echo ${TEST_CASE_TITLE} | awk -F '_' '{print $NF}'`
	local set mCeUe=0x40
	local set mStatReg=0x130004208

	hns_reg_enable

	output=`dmesg -c`
	sleep 10s

	busybox devmem ${mSavaReg} 32 ${mSavaVal}
	busybox devmem ${mEnableReg} 32 ${mEnableVal}
	busybox devmem ${mErrReg} 32 ${mErrorVal}
	busybox devmem ${mErrReg} 32 ${mClearVal}
	sleep 30s
	dmesg > ${BaseDir}/log/hns_error.txt
	flag=$[${mErrorVal}-${mCeUe}]
	if [ ${flag} -lt 0 ];then
		ce_error_judge ${mStatReg}
		if [ $? -eq 1 ];then
			MESSAGE="PASS"
		else
			MESSAGE="FAIL\t HNS imp tcm CE APEI list is error!"
		fi
	else
		ue_error_judge ${mStatReg} ${mErrorVal}
		if [ $? -eq 1 ];then
			MESSAGE="PASS"
		else
			MESSAGE="FAIL\t HNS imp tcm UE APEI list is error!"
		fi		
	fi
	echo ${MESSAGE}
}

# The ce error judge
# IN :N/A
# OUT:0 or 1
function ce_error_judge()
{
	local set mSeverity=`grep "event severity: corrected" ${BaseDir}/log/hns_error.txt | wc -l`
	local set mType=`grep "section_type: PCIe error" ${BaseDir}/log/hns_error.txt | wc -l`
	local set mSum=$[${mSeverity}+${mType}]
	if [ ${mSum} -eq 2 ];then
		return 1
	else
		return 0
	fi
}

# The ue error judge
# IN :N/A
# OUT:0 or 1
function ue_error_judge()
{
	local set mSeverity=`grep "event severity: recoverable" ${BaseDir}/log/hns_error.txt | wc -l`
	local set mType=`grep "section_type: PCIe error" ${BaseDir}/log/hns_error.txt | wc -l`
	local set mSum=$[${mSeverity}+${mType}]
	if [ ${mSum} -eq 2 ];then
		return 1
	else
		return 0
	fi
}
function main()
{
	test_case_function_run
}

main 
