#!/bin/bash

# DDR Error Injection
# IN :N/A
# OUT:N/A

function mmount()
{
    mount > mount.txt
    mtmp=$(grep "debugfs" "mount.txt" | wc -l)
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
    echo 1 > /sys/kernel/debug/tracing/events/ras/mc_event/enable |& tee enable.txt
    if [ -s ./enable.txt ]; then
        echo 'enable fail'
    else
        exec &>a.txt
        cd /sys/kernel/debug/apei/einj
        echo 0x12345000 > param1
        echo $((-1 << 12)) > param2
        echo $1 > error_type  
        cat error_type
        echo 1 > error_inject 
        exec 1>&6
    fi
}

function ddr_error_report()
{
    
    echo start a
    cat /root/a.txt
    mtype=$(dmesg | tail -15 | grep "event severity: recoverable" | wc -l)
    msection=$(dmesg | tail -15 | grep "section_type: memory error" | wc -l)
    maddress=$(dmesg | tail -15 | grep "0x0000000012345000" | wc -l)
    msum=$[$mtype+$msection+$maddress]
    echo msum$msum
    if [ $msum -eq 3 ];then
        echo writePass
    else
        echo writeFail
    fi
}

function ddr_error_injection()
{
    Test_Case_Title="ddr error injection"
    Test_Case_ID="ST.RAS.F001.A"
    :> mount.txt

    mmount
    if [ $? -eq 1 ];then
	fun_error_inject 0x08
    	ddr_error_report
    else
	echo ddr test fail!
    fi
}

function main()
{
    JIRA_ID="PV-278"
    Test_Item="The driver must support injection DDR memory error"
    Designed_Requirement_ID="R.RAS.F001.A"
    ddr_error_injection
}

main 
