#!/bin/bash

# ddr error reading and reporting
# IN :N/A
# OUT:N/A

function mmount()
{
    mount > mount.txt
    mtmp=$(cat mount.txt | grep "debugfs" | wc -l)
    echo $mtmp
    if [ $mtmp -ne 1 ];then
        mount -t debugfs none /sys/kernel/debug/
        if [ $? -eq 1 ];then
	    echo mount succ!
	    return 1
	else
	    echo mount fail!
	    return 0
	fi
    fi
}

function fun_error_inject()
{
    echo 1 > /sys/kernel/debug/tracing/events/ras/mc_event/enable
    cd /sys/kernel/debug/apei/einj
    echo 0x12345000 > param1
    echo $((-1 << 12)) > param2
    echo $1 > error_type
    cat error_type
    echo 1 > error_inject   
}

function ddr_error_report()
{
    mtype=$(dmesg | tail -15 | grep "event severity: recoverable" | wc -l)
    msection=$(dmesg | tail -15 | grep "section_type: memory error" | wc -l)
    maddress=$(dmesg | tail -15 | grep "0x0000000012345000" | wc -l)
    echo $mtype,$msection,$maddress
    if [ $mtype -eq 1 -a $msection -eq 1 -a $maddress -eq 1 ];then
        echo writePass
    else
        echo writeFail
    fi
}

function ddr_error_read_and_report()
{
    Test_Case_Title="ddr error reading and reporting"
    Test_Case_ID="ST.RAS.F002.A"
    :> mount.txt

    mmount
    if [ $? -eq 1];then
    	fun_error_inject $1
    	echo $1
    	# fun 0x08
    	ddr_error_report
    else
	echo ddr test fail!
    fi
}

function main()
{
    JIRA_ID="PV-132"
    Test_Item="The driver must support read and report DDR memory error:Hi1620"
    Designed_Requirement_ID="R.RAS.F002.A"
    ddr_error_read_and_report
}

main 
