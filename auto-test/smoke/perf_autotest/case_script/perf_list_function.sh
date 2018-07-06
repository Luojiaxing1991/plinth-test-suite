#!/bin/bash

function modle_event_judge()
{
    perf list | grep -i $1 | awk -F'[ \t]+' '{print $2}' > ${BaseDir}/log/$1_perf_event.txt
    arr=$2
    mynum=$(cat ${BaseDir}/log/$1_perf_event.txt | grep -i $1 | wc -l)
    let result=$mynum%$3
    if [ $result -ne 0 ];then
        echo have some node event abnormal
        return 0
    fi
    let EventSum=$mynum/$3
    for j in ${arr[*]}; do
        num=`cat ${BaseDir}/log/$1_perf_event.txt | grep -i "$j" | wc -l`
        echo j $j
        if [ $num -ne $EventSum ];then
            echo $j event not have
	        return 0
    	fi
    done
    return 1
}

function l3c_perf_list_function()
{
    Test_Case_Title="L3C perf list function test"
    echo ${Test_Case_Title}
    msum=$(perf list | grep -i l3c| awk -F'[ \t]+' '{print $2}' | wc -l) 
    # cat pmu_event.txt
    if [ $msum -le 0 ];then
        MESSAGE="Fail\t No L3C Perf Event Support!"
    else
        modle_event_judge "l3c" "${L3C_PERF_EVENT[*]}" "$L3C_EVENT_NUM"
        if [ $? -eq 0 ];then
            MESSAGE="Fail\t have some l3c event abnormal!"
        else
            MESSAGE="PASS"
            echo ${MESSAGE}
        fi
    fi
}

function ddrc_perf_list_function()
{
    Test_Case_Title="DDRC perf list function test"
    echo ${Test_Case_Title}
    msum=$(perf list | grep -i ddrc| awk -F'[ \t]+' '{print $2}' | wc -l) 
    if [ $msum -le 0 ];then
        MESSAGE="Fail\t No DDRC Perf Support Event!"
    else 
        modle_event_judge "ddrc" "${DDRC_PERF_EVENT[*]}" "$DDRC_EVENT_NUM"
        if [ $? -eq 0 ];then
            MESSAGE="Fail\t have some ddrc event abnormal!"
        else
            MESSAGE="PASS"
            echo ${MESSAGE}
        fi
    fi
}

function hha_perf_list_function()
{
    Test_Case_Title="HHA perf list function test"
    echo ${Test_Case_Title}
    msum=$(perf list | grep -i hha| awk -F'[ \t]+' '{print $2}' | wc -l)
    # cat pmu_event.txt
    if [ $msum -le 0 ];then
        MESSAGE="Fail\t No HHA Perf Support Event!"
    else
        modle_event_judge "hha" "${HHA_PERF_EVENT[*]}" "$HHA_EVENT_NUM"
        if [ $? -eq 0 ];then
            MESSAGE="Fail\t have some ddrc event abnormal!"
        else
            MESSAGE="PASS"
            echo ${MESSAGE}
        fi
    fi
}

function mn_perf_list_function()
{
    Test_Case_Title="MN perf list function test"
    echo ${Test_Case_Title}
    msum=$(perf list | grep -i mn | awk -F'[ \t]+' '{print $2}' | wc -l) 
    # cat pmu_event.txt
    if [ $msum -le 0 ];then
        MESSAGE="Fail\t No MN Perf Support Event!"
    else 
        MESSAGE="PASS"
    fi
}

function main()
{
    test_case_function_run
}

main


