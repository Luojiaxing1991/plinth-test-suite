#!/bin/bash

BACK_IP="192.168.50.153"

function KeepNicMsg() {
    declare -A lnic_list
    declare -A rnic_list
    flag=0
    sip=$1
    if [ -e "a.txt" ] | [ -e "b.txt" ]
    then
        rm a.txt b.txt
    fi
    lcount=`ifconfig -a | grep "encap" | awk '{print $1}' | wc -l`
    lcount=`expr $lcount - 3`
    for i in `seq 0 $lcount`
    do
        tmp=`dmesg | grep -i "renamed from ""eth""${i}" -w`
        if [ x"${tmp}" == x"" ]
        then
            echo "The name of "eth""${i}" is not renamed,Stay as ""eth""${i}"
        else
            echo ${tmp} >> a.txt
            tmp=`echo ${tmp%:*}`
            tmp=`echo ${tmp##* }`
            lnic_list["eth"${i}]=${tmp}
            echo "The name of "eth""${i}" is renamed as "${tmp}
            # echo ""eth""${i}":${tmp}" >> a.txt
        fi
    done
    echo ${lnic_list[*]}

    echo "--------------------------"
    rcount=`ssh -o StrictHostKeyChecking=no root@${sip} "ifconfig -a | grep "encap" | awk '{print $1}' | wc -l"`
    rcount=`expr $rcount - 3`
    for i in `seq 0 $rcount`
    do
        tmp=`ssh -o StrictHostKeyChecking=no root@${sip} 'dmesg | grep -i "renamed from 'eth''${i}'" -w'`
        if [ x"${tmp}" == x"" ]
        then
            echo "The name of "eth""${i}" is not renamed,Stay as ""eth""${i}"
        else
            echo ${tmp} >> b.txt
            tmp=`echo ${tmp%:*}`
            tmp=`echo ${tmp##* }`
            rnic_list["eth"${i}]=${tmp}
            echo "The name of "eth""${i}" is renamed as "${tmp}
            tmp_num=`expr ${i} + 11`
            ifconfig ${lnic_list["eth"${i}]} 192.168.${tmp_num}.11 up
            ssh -o StrictHostKeyChecking=no root@${sip} "ifconfig ${rnic_list["eth"${i}]} 192.168.${tmp_num}.22 up"
            ping 192.168.${tmp_num}.22 -c 3
            if test $? -eq 0
            then
                let flag++
            fi
        fi


    done

    if [ ${flag} -ge 2 ]
    then
        mkdir -p /home/plinth-test-workspace/xge/cfg
        cp a.txt /home/plinth-test-workspace/xge/cfg/lnic_d06
        cp b.txt /home/plinth-test-workspace/xge/cfg/rnic_d06
    fi
    rm a.txt b.txt
}

KeepNicMsg ${BACK_IP}
