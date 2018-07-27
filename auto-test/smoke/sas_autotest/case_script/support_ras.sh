#!/bin/bash



# ecc error injection during the execution, is there an error message is reported.
# IN : $1 - ecc error register value.
#      $2 - ecc error register address.
#      $3 - bit injected value, '0x1' means 1bit, '0x11' means 2bit.
#OUT : return 0 means success.
#      return 1 means error injection did not report information.
#      return 2 close error injection failed.
function ecc_injection_process()
{
    ECC_BIT_REG_INJECT_VALUE=$1
    INJECT_REG_ADDR_VALUE=$2
    INJECT_BIT_VALUE=$3

    time dmesg -c > /dev/null
    # Generate FIO configuration file
    fio_config

    sed -i "{s/^runtime=.*/runtime=${BIT_ECC_TIME}/g;}" ${FIO_CONFIG_PATH}/fio.conf
    #配置寄存器SAS_ECC_ERR_MASK0
    busybox devmem ${MASK_REG_ADDR_VALUE} w ${INJECT_BIT_VALUE}
    if [ x"${BOARD_TYPE}" == x"D06" ]
    then
        #查看CFG_SAS_RAS_ECC1B_TRSHDCE中断阈值,查看SAS_RAS_ECC_CNT,统计ECC次数
        trshdce_value=`busybox devmem ${TRSHDC_REG_ADDR_VALUE} w`
        begin_cnt_value=`busybox devmem ${CNT_REG_ADDR_VALUE} w`
    fi

    # clear the contents of the ring buffer.
    #cat whether exist UE or CE error.
    [ x"${BOARD_TYPE}" == x"D05" ] && begin_bit_count=`dmesg | grep ${ECC_INFO_KEY_QUERIES} | wc -l`
    [ x"${BOARD_TYPE}" == x"D06" ] && begin_bit_count=`dmesg | grep -e ${ECC_INFO_KEY1_QUERIES} -e ${ECC_INFO_KEY2_QUERIES} | wc -l`
    #set register
    busybox devmem ${INJECT_REG_ADDR_VALUE} w ${ECC_BIT_REG_INJECT_VALUE}
    ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio ${FIO_CONFIG_PATH}/fio.conf &
    sleep 10
    busybox devmem ${MASK_REG_ADDR_VALUE} w 0x0
    sleep 2
    [ x"${BOARD_TYPE}" == x"D05" ] && mid_bit_count=`dmesg | grep ${ECC_INFO_KEY_QUERIES} | wc -l`
    [ x"${BOARD_TYPE}" == x"D06" ] && mid_bit_count=`dmesg | grep -e ${ECC_INFO_KEY1_QUERIES} -e ${ECC_INFO_KEY2_QUERIES} | wc -l`
    if [ x"${BOARD_TYPE}" == x"D06" ]
    then
        mid_cnt_value=`busybox devmem ${CNT_REG_ADDR_VALUE} w`
        [ ${mid_bit_count} -eq ${begin_bit_count} ] && wait && return 1
        [ x"${mid_cnt_value}" \< x"${trshdce_value}" ] && wait && return 1
    else
        [ ${mid_bit_count} -eq ${begin_bit_count} ] && wait && return 1
    fi
    #如果上面的判断满足，就不需要执行下面的命令，则return 1
    wait
    [ x"${BOARD_TYPE}" == x"D05" ] && end_bit_count=`dmesg | grep ${ECC_INFO_KEY_QUERIES} | wc -l`
    [ x"${BOARD_TYPE}" == x"D06" ] && end_bit_count=`dmesg | grep -e ${ECC_INFO_KEY1_QUERIES} -e ${ECC_INFO_KEY2_QUERIES} | wc -l`
    if [ x"${BOARD_TYPE}" == x"D06" ]
    then
        end_cnt_value=`busybox devmem ${CNT_REG_ADDR_VALUE} w`
        [ ${mid_bit_count} -ne ${end_bit_count} ] && wait && return 2
        [ x"${begin_cnt_value}" != x"${end_cnt_value}" ] && wait && return 2
    else
        [ ${mid_bit_count} -ne ${end_bit_count} ] && wait && return 2
    fi
    return 0
}

# ecc error register output.
# IN : $1 - register injection return value.
#      $2 - register address
#      $3 - register injection value.
# OUT: N/A
function output_ecc_info()
{
    REG_RETURN_VALUE=$1
    REG_ADDR_VALUE=$2
    REG_ECC_VALUE=$3

    case "${REG_RETURN_VALUE}" in
        0)
            MESSAGE="PASS"
            echo ${MESSAGE}
            ;;
        1)
            MESSAGE="FAIL\t${REG_ADDR_VALUE} ${REG_ECC_VALUE} register address setting , no error message is reported."
            echo ${MESSAGE}
            ;;
        2)
            MESSAGE="FAIL\t${REG_ADDR_VALUE} ${REG_ECC_VALUE} register address setting , shutdown error repoted log failed."
            echo ${MESSAGE}
            ;;
    esac
}

# 1bit ecc error register 0 injection.
# IN  : $1 - register injection value.
# OUT : N/A
function 1bit_ecc_inject0()
{
    Test_Case_Title="1bit_ecc_inject0"
    reg_value=$1

    ecc_injection_process "${reg_value}" "${INJECT0_REG_ADDR_VALUE}" "0x1"
    return_num=$?
    output_ecc_info ${return_num} ${INJECT0_REG_ADDR_VALUE} ${reg_value}

    busybox devmem ${MASK_REG_ADDR_VALUE} w 0x0

    if [ x"${BOARD_TYPE}" == x"D06" ]
    then
        # restore register initial value.
        busybox devmem ${INJECT0_REG_ADDR_VALUE} w 0x0
        busybox devmem ${INJECT1_REG_ADDR_VALUE} w 0x0
    fi
}

# 1bit ecc error register 1 injection.
# IN  : N/A
# OUT : N/A
function 1bit_ecc_inject1()
{
    Test_Case_Title="1bit_ecc_inject1"
    reg_value=$1

    ecc_injection_process "${reg_value}" ${INJECT1_REG_ADDR_VALUE} "0x1"
    return_num=$?
    output_ecc_info ${return_num} ${INJECT1_REG_ADDR_VALUE} ${reg_value}

    busybox devmem ${MASK_REG_ADDR_VALUE} w 0x0

    if [ x"${BOARD_TYPE}" == x"D06"  ]
    then
        # restore register initial value.
        busybox devmem ${INJECT0_REG_ADDR_VALUE} w 0x0
        busybox devmem ${INJECT1_REG_ADDR_VALUE} w 0x0
    fi
}

# 2bit ecc error register injection.
# IN  : N/A
# OUT : N/A
function 2bit_ecc_injection()
{
    Test_Case_Title="2bit_ecc_injection"
    reg_value=$1

    ecc_injection_process "${reg_value}" "${INJECT1_REG_ADDR_VALUE}" "0x11"
    return_num=$?
    output_ecc_info ${return_num} ${INJECT1_REG_ADDR_VALUE} ${reg_value}

    busybox devmem ${MASK_REG_ADDR_VALUE} w 0x0

    if [ x"${BOARD_TYPE}" == x"D06"  ]
    then
        # restore register initial value.
        busybox devmem ${INJECT0_REG_ADDR_VALUE} w 0x0
        busybox devmem ${INJECT1_REG_ADDR_VALUE} w 0x0
    fi
}

function main()
{
    info=`echo ${TEST_CASE_FUNCTION_NAME} | awk -F '_' '{print $NF}'`
    TEST_CASE_FUNCTION_NAME=`echo ${TEST_CASE_FUNCTION_NAME%_*}`
    echo "The using function name is "${TEST_CASE_FUNCTION_NAME}
    TEST_CASE_FUNCTION_NAME="${TEST_CASE_FUNCTION_NAME} 0x${info}"

    inject=`echo ${TEST_CASE_FUNCTION_NAME} | awk -F '_' '{print $NF}' | awk -F ' ' '{print $1}'`
    bit=`echo ${TEST_CASE_FUNCTION_NAME} | awk -F '_' '{print $1}'`

    if [ x"${BOARD_TYPE}" == x"D05" ];then
        if [ x"$bit" = x"1bit" ];then
	        if [ x"$inject" = x"inject0" ];then
                echo "check if dmesg grep info is correct or not"
                case $info in
                "1" | "2" | "4" | "8")
                    ECC_INFO_KEY_QUERIES="hgc_dqe_acc1b_intr"
                    ;;
	            "10")
		            ECC_INFO_KEY_QUERIES="hgc_cqe_acc1b_intr"
		            ;;
	            "20" | "40" | "80"| "100")
		            ECC_INFO_KEY_QUERIES="hgc_iost_acc1b_intr"
		            ;;
	            "200" | "400" | "800" | "1000")
	            	ECC_INFO_KEY_QUERIES="hgc_itct_acc1b_intr"
            		;;
            	"2000")
            		ECC_INFO_KEY_QUERIES="rxm_mem0_acc1b_intr"
            		;;
            	"4000")
	            	ECC_INFO_KEY_QUERIES="rxm_mem1_acc1b_intr"
	            	;;
            	"8000")
            		ECC_INFO_KEY_QUERIES="rxm_mem2_acc1b_intr"
            		;;
                	"10000")
            		ECC_INFO_KEY_QUERIES="rxm_mem3_acc1b_intr"
            		;;
               	"20000" | "40000" | "80000" | "100000")
            		ECC_INFO_KEY_QUERIES="hgc_itctl_acc1b_intr"
		            ;;
	            "200000" | "400000" | "800000" | "1000000")
            		ECC_INFO_KEY_QUERIES="hgc_iostl_acc1b_intr"
            		;;
                 esac
	        else
		        echo "1bit inject1 ecc"
		        case $info in
		        "1" | "4" | "10" | "40" | "100" | "400" | "1000" | "4000" | "10000")
			        ECC_INFO_KEY_QUERIES="dmac_tx_ecc_bad_err"
			        ;;
		        #"2" | "8" | "20" | "80")
	        		#ECC_INFO_KEY_QUERIES="dmac_rx_ecc_bad_err"
		        	#;;
        		esac
        	fi

        else
	        echo "2bit ecc"
	        case $info in
            "2" | "8" | "20" | "80" | "200" | "800" | "2000" | "8000")
			    ECC_INFO_KEY_QUERIES="dmac_rx_ecc_bad_err"
			    ;;
	        esac

        fi
    elif [ x"${BOARD_TYPE}" == x"D06" ];then
        if [ x"$bit" = x"1bit" ];then
	        if [ x"$inject" = x"inject0" ];then
                echo "check if dmesg grep info is correct or not"
                case $info in
                "1" | "2" | "4" | "8" | "10" | "20" | "40" | "80" | "100" | "200" | "400" | "800" | "1000" | "2000" | "4000" | "8000" | "10000" | "20000" | "40000" | "80000" | "100000" | "200000" | "400000" | "800000" | "1000000")
            		ECC_INFO_KEY1_QUERIES="corrected"
            		ECC_INFO_KEY2_QUERIES="recoverable"
            		;;
                 esac
	        else
		        echo "1bit inject1 ecc"
		        case $info in
                "1" | "4" | "10" | "40" | "100" | "400" | "1000" | "4000")
            		ECC_INFO_KEY1_QUERIES="corrected"
            		ECC_INFO_KEY2_QUERIES="recoverable"
		        	;;
        		esac
        	fi

        else
	        echo "2bit ecc"
	        case $info in
            "2" | "8" | "20" | "80" | "200" | "800" | "2000" | "8000")
            		ECC_INFO_KEY1_QUERIES="corrected"
            		ECC_INFO_KEY2_QUERIES="recoverable"
			    ;;
	        esac

        fi

    fi


    echo "dmesg info is "${ECC_INFO_KEY_QUERIES}
    # call the implementation of the automation :use cases
    test_case_function_run
}

main
