#!/bin/bash

#N :N/A
#OUT:N/A

function fun_perf_list()
{
    :> ${BaseDir}/log/pmu_event.txt
    perf list | grep $1| awk -F'[ \t]+' '{print $2}' > ${BaseDir}/log/pmu_event.txt
    msum=$(cat ${BaseDir}/log/pmu_event.txt | grep $1 | wc -l)
    mEnable=${mHead}$1${enTail}
    mDisable=${mHead}$1${disTail}
    if [ $msum -le 0 ];then
        MESSAGE="Fail\t No $1 Perf Support Event!"
    else 
        rand=$(awk 'NR==2 {print $1}' ${BaseDir}/log/pmu_event.txt)
        output=`dmesg -c`
        perf stat -a -e $rand -I 200 sleep ${SLEEP_TIME}
        dmesg > ${BaseDir}/log/dmesg.txt
        en_flag=`cat ${BaseDir}/log/dmesg.txt | grep ${mEnable} | wc -l`
        dis_flag=`cat ${BaseDir}/log/dmesg.txt | grep ${mDisable} | wc -l`
        if [ $en_flag -lt 1 -a $dis_flag -lt 1 ];then 
            MESSAGE="Fail\t $1 Event disable/enable Function Test Fail!"
        else
            MESSAGE="PASS"
        fi
    fi
    echo ${MESSAGE}
}

function l3c_perf_enable_function()
{
    Test_Case_Title="L3C perf disable/enable function test"

    fun_perf_list l3c
}

function hha_perf_enable_function()
{
    Test_Case_Title="HHA perf disable/enable function test"

    fun_perf_list hha
} 

function main()
{
    test_case_function_run
}

main
