#!/bin/bash

# L1D Error Injection
# IN :N/A
# OUT:N/A

function mmount()
{
    local mpath=/sys/kernel/debug
    mount > mount.txt
    mtmp=$(cat mount.txt | grep "debugfs" | wc -l)
    echo $mtmp
    if [ $mtmp -ne 0 ];then
        mount -t debugfs none ${mpath}
        echo mount debugfs
    fi
}

function fun_l1d_error_inject()
{
    echo 1 > /sys/kernel/debug/tracing/events/ras/mc_event/enable
    cd /sys/kernel/debug/apei/einj
    echo 0x12345000 > param1
    echo $((-1 << 12)) > param2
    echo $1 > error_type
    cat error_type
    echo 1 > error_inject   
}

function l1d_error_report()
{
    mtype=$(dmesg | tail -15 | grep "event severity: coverable" | wc -l)
    msection=$(dmesg | tail -15 | grep "section_type: ARM processor error" | wc -l)
    # maddress=$(dmesg | tail -15 | grep "0x0000000012345000" | wc -l)
    echo $mtype,$msection,$maddress
    if [ $mtype -eq 1 -a $msection -eq 1 ];then  # -a $maddress -eq 1
        echo writePass
    else
        echo writeFail
    fi
}

function l1d_error_injection()
{
    Test_Case_Title="L1D error injection"
    Test_Case_ID=""
    :> mount.txt

    mmount
    fun_l1d_error_inject 0x01
    # fun 0x10
    l1d_error_report
}

function main()
{
    JIRA_ID=""
    Test_Item="The driver must support injection L1D error"
    Designed_Requirement_ID=""
    l1d_error_injection
}

main 