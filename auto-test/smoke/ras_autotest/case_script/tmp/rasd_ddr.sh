#!/bin/bash

# DDR Error Injection
# IN :N/A
# OUT:N/A

function mmount_rasd()
{
    mount > mount.txt
    mtmp=$(cat mount.txt | grep "debugfs" | wc -l)
    echo $mtmp
    if [ $mtmp -ne 1 ];then
        mount -t debugfs none /sys/kernel/debug/
        echo mount
    fi
    cd /home/mytest
    ./rasdaemon -f &
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

function ddr_error_injection()
{
    Test_Case_Title="ddr error injection"
    Test_Case_ID="ST.RAS.F001.A"
    :> mount.txt

    mmount_rasd
    fun_error_inject 0x08
    # echo $1
    # fun 0x08
    ddr_error_report
}

function main()
{
    JIRA_ID="PV-278"
    Test_Item="The driver must support injection DDR memory error"
    Designed_Requirement_ID="R.RAS.F001.A"
    ddr_error_injection
}

main 
