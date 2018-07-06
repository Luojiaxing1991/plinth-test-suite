#!/bin/bash

#N :N/A
#OUT:N/A
function fun_configure_test()
{
    mevent=`sed -n -e '1p' ${BaseDir}/log/pmu_event.txt`
    mevent2=`sed -n -e '2p' ${BaseDir}/log/pmu_event.txt`
    echo $mevent
    output=`dmesg -c`
    perf stat -a -e $mevent -e $mevent2 -I 200 sleep ${SLEEP_TIME}
    dmesg | grep -i "PERF_WRITE_TEST REG:" > ${BaseDir}/log/configure_dmesg.txt
    cat ${BaseDir}/log/configure_dmesg.txt | awk -F '[ \t]+'  '{print $NF}' > ${BaseDir}/log/configure_data.txt
    # cat ${BaseDir}/log/configure_data.txt | sed "s/,//g" |sed '/^[ \t]*$/d' > ${BaseDir}/log/configure_data.txt
    if [ `cat ${BaseDir}/log/configure_dmesg.txt | grep -i "PERF_WRITE_TEST REG:" | wc -l` -lt 1 ];then 
        MESSAGE="Fail\t $1 Event Configure Function Test Fail!"
    else
        mreg=`sed -n -e '1p' ${BaseDir}/log/configure_data.txt`
        cat ${BaseDir}/log/configure_data.txt | sed "s/${mreg}//g" | grep -v "^$" > ${BaseDir}/log/configure_data2.txt
        mreg2=`sed -n -e '1p' ${BaseDir}/log/configure_data2.txt`
        let mreg-=$1
        let mreg2-=$2
        echo $mreg $mreg2
        if [ $mreg -eq 0 -a $mreg2 -eq 0 ];then
            MESSAGE="PASS"
        else
            MESSAGE="Fail\t PERF Event Configure Function Test Fail!"
        fi
    fi
}
function fun_perf_list()
{
    :> ${BaseDir}/log/pmu_event.txt
    perf list | grep $1| awk -F'[ \t]+' '{print $2}' > ${BaseDir}/log/pmu_event.txt
    msum=$(cat ${BaseDir}/log/pmu_event.txt | grep $1 | wc -l)
    if [ $msum -le 0 ];then
        MESSAGE="Fail\t No $1 Perf Support Event!"
    else
        case $1 in
        "l3c") 
            fun_configure_test 1e00 1e08
        ;;
        "ddrc")
            fun_configure_test 384 388
        ;;
        "hha")
            fun_configure_test 38 42
        ;;
        esac
    fi
}

function l3c_perf_configure_function()
{
    Test_Case_Title="L3C perf configure function test"

    fun_perf_list l3c
}

function ddrc_perf_configure_function()
{
    Test_Case_Title="DDRC perf configure function test"

    fun_perf_list ddrc
}

function hha_perf_configure_function()
{
    Test_Case_Title="HHA perf configure function test"

    fun_perf_list hha
}

function main()
{
    test_case_function_run
}

main
