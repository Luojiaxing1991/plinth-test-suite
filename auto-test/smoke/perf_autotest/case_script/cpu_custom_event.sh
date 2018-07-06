#!/bin/bash

#IN :N/A
#OUT:N/A
function event_counts_judge()
{
    :> ${BaseDir}/log/event_judge.txt
    cat ${BaseDir}/log/counts.txt | while read mycount
    do
        if [ -n "$(echo $mycount | sed -n "/^[0-9]\+$/p")" ];then 
            if [ $mycount -ge 0 -a $mycount -$1 32768 ];then
                echo "$mycount is normal"
                echo 1 > ${BaseDir}/log/event_judge.txt
            else
                echo "$mycount : the count is abmormal"
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

function cpu_custom_event_less()
{
    Test_Case_Title="event_number < 1024"

    :> ${BaseDir}/log/cpu_custom_judge.txt
    for j in ${CPU_CUSTOM_EVENT[*]}; do
        perf stat -a -A -e $j -I 200 sleep ${SLEEP_TIME} >& ${BaseDir}/log/perf_statu.log
        cat ${BaseDir}/log/perf_statu.log | awk -F '[ \t]+'  '{print $4}' | sed 's/counts//g' | grep -v "^$" > ${BaseDir}/log/counts.txt
        sleep 1
        event_counts_judge lt
        if [ $? -eq 0 ];then
            echo 0 >> ${BaseDir}/log/cpu_custom_judge.txt
        else
            echo 1 >> ${BaseDir}/log/cpu_custom_judge.txt
        fi
    done    
    if [ `cat ${BaseDir}/log/cpu_custom_judge.txt | grep '1' | wc -l` -eq 0 ];then
        MESSAGE="Fail\t cpu custom event abnormal!"
    else
        MESSAGE="PASS"
        echo ${MESSAGE}
    fi
}

function cpu_custom_event_more()
{
    Test_Case_Title="event_number > 1024"

    :> ${BaseDir}/log/cpu_custom_judge.txt
    for j in ${CPU_CUSTOM_EVENT[*]}; do
        perf stat -a -A -e $j -I 200 sleep ${SLEEP_TIME} >& ${BaseDir}/log/perf_statu.log
        cat ${BaseDir}/log/perf_statu.log | awk -F '[ \t]+'  '{print $4}' | sed 's/counts//g' | grep -v "^$" > ${BaseDir}/log/counts.txt
        sleep 1
        event_counts_judge gt
        if [ $? -eq 0 ];then
            echo 0 >> ${BaseDir}/log/cpu_custom_judge.txt
        else
            echo 1 >> ${BaseDir}/log/cpu_custom_judge.txt
        fi
    done    
    if [ `cat ${BaseDir}/log/cpu_custom_judge.txt | grep '1' | wc -l` -eq 0 ];then
        MESSAGE="Fail\t cpu custom event abnormal!"
    else
        MESSAGE="PASS"
        echo ${MESSAGE}
    fi
}

function main()
{
    test_case_function_run
}

main
