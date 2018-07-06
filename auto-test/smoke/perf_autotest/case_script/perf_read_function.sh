#!/bin/bash

#N :N/A
#OUT:N/A
# PERF_TOP_DIR="/root/shell"
function fun_perf_read()
{
    echo pwd ${PERF_TOP_DIR}
    :> ${BaseDir}/log/pmu_event.txt
    :> ${BaseDir}/log/counter_sum.txt
    perf list | grep $1| awk -F'[ \t]+' '{print $2}' > ${BaseDir}/log/pmu_event.txt
    msum=$(cat ${BaseDir}/log/pmu_event.txt | grep $1 | wc -l) 
    if [ $msum -le 0 ];then
        MESSAGE="Fail\t No $1 Perf Support Event!"
    else 
        myline=`sed -n '1p' ${BaseDir}/log/pmu_event.txt`
        output=`dmesg -c`
        perf stat -a -e $myline -I 200 sleep ${SLEEP_TIME} >& ${BaseDir}/log/perf_statu.log
        readnum=`dmesg | awk 'END {print $NF}'`
        echo $readnum
        cat ${BaseDir}/log/perf_statu.log | awk -F '[ \t]+'  '{print $3}' | sed 's/counts//g' | sed "s/,//g" |sed '/^[ \t]*$/d' > ${BaseDir}/log/counts.txt
        cat ${BaseDir}/log/counts.txt | while read myline
        do
            let sum+=myline
            echo $sum > ${BaseDir}/log/counter_sum.txt
        done
        readnum2=`devmem2 $2 | awk 'END {print $NF}' | sed 's/0x//g'`
        echo $readnum2
        if [ x'$readnum' == x'$readnum2' ];then
            MESSAGE="PASS"
        else
            MESSAGE="Fail\t $1 read test fail"
        fi
        if [ `sed -n '1p' ${BaseDir}/log/counter_sum.txt` -eq $readnum ];then
            MESSAGE="PASS"
        else
            MESSAGE="Fail\t $1 read test fail"
        fi
    fi
}

function l3c_perf_read_function()
{
    Test_Case_Title="L3C perf read function test"

    fun_perf_read l3c 0x90180170
}

function ddrc_perf_read_function()
{
    Test_Case_Title="DDRC perf read function test"

    fun_perf_read ddrc 0x94020384
}

function hha_perf_read_function()
{
    Test_Case_Title="HHA perf read function test"

    fun_perf_read hha 0x0
}

function main()
{
    test_case_function_run
}

main
