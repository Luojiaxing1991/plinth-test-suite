#!/bin/bash

#N :N/A
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

#N :N/A
#OUT:N/A
function fun_perf_list()
{
    :> ${BaseDir}/log/pmu_event.txt
    mflag=0
    perf list | grep $1| awk -F'[ \t]+' '{print $2}' > ${BaseDir}/log/pmu_event.txt
    msum=`cat ${BaseDir}/log/pmu_event.txt | grep "$1" | wc -l`
    cat $msum $mflag
    if [ `cat /proc/cmdline | grep "acpi=force" | wc -l` -ne 1 ];then
        mflag=0
        MESSAGE="Fail\t No ACPI Support!"
    else
        if [ $msum -le 0 ];then
            mflag=0
            MESSAGE="Fail\t No $1 Perf Event Support!"
        else 
            mflag=1
        fi
    fi

    if [ $mflag -eq 1 ];then
        rand=$(awk 'NR==2 {print $1}' ${BaseDir}/log/pmu_event.txt)
        rand2=$(awk 'NR==16 {print $1}' ${BaseDir}/log/pmu_event.txt)
        perf stat -a -A -e $rand -e $rand2 -I 200 sleep ${SLEEP_TIME} >& ${BaseDir}/log/perf_statu.log
        cat ${BaseDir}/log/perf_statu.log | awk -F '[ \t]+'  '{print $4}' | sed 's/counts//g' | grep -v "^$" > ${BaseDir}/log/counts.txt
        event_counts_judge
        if [ $? -eq 1 ];then
            MESSAGE="PASS"
        else
            MESSAGE="Fail\t Run $1 Event Err!"
        fi
    fi 
}

function hha_pmu_support_test()
{
    Test_Case_Title="Support HHA PMU events"

    fun_perf_list hha
}

function main()
{
    test_case_function_run
}

main
