#!/bin/bash

#IN :N/A
#OUT:N/A

function fun_perf_list()
{
    :> ${BaseDir}/log/pmu_event.txt
    :> ${BaseDir}/log/irq_flag.txt
    acc="hisi_"
    end="_pmu_isr"
    irq_str=${acc}$1${end}
    echo $irq_str
    perf list | grep $1| awk -F'[ \t]+' '{print $2}' > ${BaseDir}/log/pmu_event.txt
    msum=$(cat ${BaseDir}/log/pmu_event.txt | grep $1 | wc -l)
    if [ $msum -le 0 ];then
        MESSAGE="Fail\t No $1 Perf Support Event!"
    else
        cat  ${BaseDir}/log/pmu_event.txt | while read myline
        do
            output=`dmesg -c`
            perf stat -a -e $myline -I 200 sleep ${SLEEP_TIME}
            dmesg > ${BaseDir}/log/irq_dmesg.txt
            irq=`cat ${BaseDir}/log/irq_dmesg.txt | grep ${irq_str} | wc -l`
            if [ $irq -ge 1 ];then
                echo 1 > ${BaseDir}/log/irq_flag.txt
                break
            fi
        done
        if [ `cat ${BaseDir}/log/irq_flag.txt | grep "1" | wc -l` -ge 1 ];then
            MESSAGE="PASS"
        else
            MESSAGE="Fail\t All $1 Event IRQ Function Test Fail!"
        fi
    fi
}

function l3c_perf_irq_function()
{
    Test_Case_Title="L3C perf irq function test"

    fun_perf_list l3c
}

function ddrc_perf_irq_function()
{
    Test_Case_Title="DDRC perf irq function test"

    fun_perf_list ddrc
}

function hha_perf_irq_function()
{
    Test_Case_Title="HHA perf irq function test"

    fun_perf_list hha
}

function main()
{
    test_case_function_run
}

main
