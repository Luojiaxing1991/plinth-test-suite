#!/bin/bash
#!/bin/athena/bash

#N :N/A
#OUT:N/A

function ras_test()
{
    Test_Case_Title="ras_test"
    dmesg -c > dmesg_c.txt
    busybox devmem 0xa20001f0 32 0x1
    busybox devmem 0xa2000200 32 0xffff
    fdisk -l | wc -l
    dmesg > sas_error.txt
    if [ `cat sas_error.txt | grep 'SErr' | wc -l` -lt 0 ];then
	echo pass
    else 
	echo fail
    fi
}

function main()
{
    test_case_function_run
}

main
