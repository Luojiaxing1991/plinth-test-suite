#!/bin/bash

# sas
# IN :N/A
# OUT:N/A
 
MaskRegAddr=0xa2000200
MaskRegVal=0xffffffff
ErrorRegAddr=("0xa20001F0" "0xa20001F4" "0xa20001F8" "0xa20001FC")
RegVal=("0x1000000" "0x800000" "0x400000" "0x200000" "0x100000" "0x80000" "0x40000" 
    "0x20000" "0x10000" "0x8000" "0x4000" "0x2000" "0x1000" "0x800" "0x400" "0x200" 
    "0x100" "0x80" "0x40" "0x20" "0x10" "0x8" "0x4" "0x2" "0x1")

function init()
{
   	busybox devmem ${MaskRegAddr} 32 ${MaskRegVal}
}

function sas_1bitECC_error_inject()
{
    for ((j = 0; j< ${#RegVal[@]}; j++)) 
    do
        output=`dmesg -c`
	echo "ErrorRegAddr:"${ErrorRegAddr[1]} 
        echo "RegVal:"${RegVal[$j]}
	busybox devmem ${ErrorRegAddr[1]} 32 ${RegVal[$j]} 
    	busybox devmem ${ErrorRegAddr[1]}
	busybox devmem ${MaskRegAddr} 32 ${MaskRegVal}
	busybox devmem ${MaskRegAddr}
	fdisk -l
	dmesg > ./fdisk_sas_error.txt
	# fio -name=read -numjobs=1 -filename=/dev/sda -rw=read -iodepth=4 -direct=1 -sync=0 -norandommap -runtime=10 -time_base -bs=4K >& ./sas_error_fio.txt
        flag=`cat ./fdisk_sas_error.txt |grep -e 'event severity: recoverable' -e 'section type: unknown,' -e 'type: corrected' | wc -l`
        if [ $flag -ne 3 ]; then
            echo "1bit ECC addr:${ErrorRegAddr[1]} val:${RegVal[$j]} fail"
        else
            echo "devmem ${ErrorRegAddr[1]} 32 ${RegVal[$j]}  pass"
        fi 
	    busybox devmem ${MaskRegAddr} 32 0x0
    done
}

function sas_2bitECC_error_inject()
{
    for ((i = 0;i < ${#RegVal[@]}; i++))
    do
        output=`dmesg -c`
        echo "ErrorRegAddr:"${ErrorRegAddr[0]}
        echo "RegVal:"${RegVal[$i]}
	busybox devmem ${ErrorRegAddr[0]} 32 ${RegVal[$i]}
        busybox devmem ${ErrorRegAddr[1]} 32 ${RegVal[$i]}
	busybox devmem ${ErrorRegAddr[0]}
	busybox devmem ${ErrorRegAddr[1]}
	busybox devmem ${MaskRegAddr} 32 ${MaskRegVal}
    	busybox devmem ${MaskRegAddr}
        fdisk -l
        dmesg > ./fdisk_sas_error.txt
	# fio -name=read -numjobs=1 -filename=/dev/sda -rw=read -iodepth=4 -direct=1 -sync=0 -norandommap -runtime=10 -time_base -bs=4K >& ./sas_error_fio.txt
        flag=`cat ./fdisk_sas_error.txt |grep -e 'event severity: recoverable' -e 'section type: unknown,' -e 'type: recoverable' | wc -l`
        if [ $flag -ne 3 ]; then
            echo fail
        else
            echo pass
        fi
        busybox devmem ${MaskRegAddr} 32 0x0
    done
}

function main()
{
    init
    sas_1bitECC_error_inject
    sas_2bitECC_error_inject
}

main


