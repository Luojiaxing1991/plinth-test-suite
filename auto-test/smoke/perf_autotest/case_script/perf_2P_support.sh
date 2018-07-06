#!/bin/bash

# BaseDir=../data
#IN :N/A
#OUT:N/A
function event_counts_judge()
{
    :> ${BaseDir}/log/event_judge.txt
    cat ${BaseDir}/log/counts.txt | while read mycount
    do
        if [ -n "$(echo $mycount | sed -n "/^[0-9]\+$/p")" ];then 
            if [ $mycount -ge 0 -a $mycount -le 524287 ];then
                echo 1 > ${BaseDir}/log/event_judge.txt
            else
                echo "$mycount : the count is abmormal"
                echo 0 > ${BaseDir}/log/event_judge.txt
                break
            fi
        else 
            echo "$mycount : the count is not number!"
            echo 0 > ${BaseDir}/log/event_judge.txt
            break
        fi
    done
    if [ `cat ${BaseDir}/log/event_judge.txt | grep 0 | wc -l` -eq 0 ];then
        return 1
    else
        return 0
    fi
}

#IN :N/A
#OUT:N/A
function perf_2P_support_function_test()
{
    echo ${Test_Case_Title}
    :> ${BaseDir}/log/2P_flag.txt
    perf list | grep $1| awk -F'[ \t]+' '{print $2}' > ${BaseDir}/log/pmu_event.txt
    msum=$(cat ${BaseDir}/log/pmu_event.txt | grep $1 | wc -l)
    if [ $msum -le 0 ];then
        MESSAGE="Fail\t No $1 Perf Support Event!"
    else
        for i in $2;do
	    echo the i is $i
            case=`cat ${BaseDir}/log/pmu_event.txt | grep $i | sed -n 1p`
	    echo $case
            perf stat -a -C $MASTER_CPU -A -e ${case} -I 200 sleep ${SLEEP_TIME} >& ${BaseDir}/log/perf_statu.log
            cat ${BaseDir}/log/perf_statu.log | awk -F '[ \t]+'  '{print $4}' | sed 's/counts//g' | grep -v "^$" > ${BaseDir}/log/counts.txt
            cat ${BaseDir}/log/perf_statu.log | awk -F '[ \t]+'  '{print $3}' | sed 's/CPU//g' | grep -v "^$" > ${BaseDir}/log/cpu.txt
            event_counts_judge
            if [ $? -eq 1 ];then
                echo 1 > ${BaseDir}/log/2P_flag.txt
            else
                echo 0 > ${BaseDir}/log/2P_flag.txt
                break
            fi
            perf stat -a -C $SLAVE_CPU -A -e ${case} -I 200 sleep ${SLEEP_TIME} >& ${BaseDir}/log/perf_statu.log
            cat ${BaseDir}/log/perf_statu.log | awk -F '[ \t]+'  '{print $4}' | sed 's/counts//g' | grep -v "^$" > ${BaseDir}/log/counts.txt
            cat ${BaseDir}/log/perf_statu.log | awk -F '[ \t]+'  '{print $3}' | sed 's/CPU//g' | grep -v "^$" > ${BaseDir}/log/cpu.txt
            event_counts_judge
            if [ $? -eq 1 ];then
                echo 1 > ${BaseDir}/log/2P_flag.txt
            else
                echo 0 > ${BaseDir}/log/2P_flag.txt
                break
            fi
        done
        if [ `cat ${BaseDir}/log/2P_flag.txt | grep "0" | wc -l` -le 0 ];then
            MESSAGE="PASS"
        else
            MESSAGE="Fail\t No $1 Perf 2P Support Event!"
        fi
    fi
}

function l3c_perf_2P_support()
{
    Test_Case_Title="L3C perf 2P support function test"
  
    perf_2P_support_function_test l3c ${L3C_PERF_EVENT}
}

function ddrc_perf_2P_support()
{
    Test_Case_Title="DDRC perf 2P support function test"
  
    perf_2P_support_function_test ddrc ${DDRC_PERF_EVENT}
}

function hha_perf_2P_support()
{
    Test_Case_Title="HHA perf 2P support function test"
  
    perf_2P_support_function_test hha ${HHA_PERF_EVENT}
}

function main()
{
    test_case_function_run
# l3c_perf_2P_support
# ddrc_perf_2P_support
# hha_perf_2P_support
}

main
