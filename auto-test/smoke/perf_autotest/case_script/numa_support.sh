#!/bin/bash

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
#out:N/A
function mode_numa_support()
{
    :> ${BaseDir}/log/pmu_event.txt
    :> ${BaseDir}/log/counts.txt
    perf list | grep $1 | awk -F'[ \t]+' '{print $2}' > ${BaseDir}/log/pmu_event.txt
    msum=`cat ${BaseDir}/log/pmu_event.txt | grep "$1" | wc -l`
    if [ $msum -le 0 ];then
        MESSAGE="Fail\t No $1 Event Support!"
	echo 0 >> ${BaseDir}/log/numa_support.txt
    else
        rand=$(awk 'NR==2 {print $1}' ${BaseDir}/log/pmu_event.txt)
        rand2=$(awk 'NR==16 {print $1}' ${BaseDir}/log/pmu_event.txt)
        perf stat -C $NUMA_CPU -A -e $rand -e $rand2 -I 200 sleep ${SLEEP_TIME} >& ${BaseDir}/log/perf_statu.log
        cat ${BaseDir}/log/perf_statu.log | awk -F '[ \t]+'  '{print $4}' | sed 's/counts//g' | grep -v "^$" > ${BaseDir}/log/counts.txt
        event_counts_judge
        if [ $? -eq 1 ];then
            echo 1 >> ${BaseDir}/log/numa_support.txt
        else
            echo 0 >> ${BaseDir}/log/numa_support.txt
        fi
    fi 
}
#IN :N/A
#OUT:N/A
function numa_support_test()
{
    Test_Case_Title="NUMA support"
    :> ${BaseDir}/log/numa_support.txt
    mode_numa_support l3c
    mode_numa_support ddrc
    mode_numa_support hha
    if [ `cat ${BaseDir}/log/numa_support.txt | grep 0 | wc -l` -eq 0 ];then
        MESSAGE="PASS"
    else
        MESSAGE="Fail\t numa support have some mode err!"
    fi
}

function main()
{
    test_case_function_run
}

main
