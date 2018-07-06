#!/bin/bash



# Modify the value of the rate file. 
# IN : $1 Need to modify phy file directory.
#      $2 Rate value.
#      $3 Rate file.
# OUT: N/A
function modify_phy_rate()
{
    local path=$1
    local rate=$2
    local name=$3

    init_num=`fdisk -l | grep /dev/sd | wc -l`
    echo "${rate}" > ${PHY_FILE_PATH}/${path}/${name}
    sleep 5
    linkrate=`cat ${PHY_FILE_PATH}/${path}/negotiated_linkrate | awk -F ' ' '{print $1}'`
    mum=`echo "${rate}" | awk -F ' ' '{print $1}'`
    case ${name} in
        "minimum_linkrate")
        bool=`echo "${linkrate} ${mum}" | awk '{if($1<$2 && $1!=$2){print 1}else{print 0}}'`
        if [ ${bool} -eq 1 ]
        then
            MESSAGE="FAIL\tThe negotiation rate is less than the minimum rate, linkrate: ${linkrate} < ${mum}."
            echo ${MESSAGE}
            return 1
        fi
        ;;
        "maximum_linkrate")
        bool=`echo "${linkrate} ${mum}" | awk '{if($1>$2){print 1}else{print 0}}'`
        if [ ${bool} -eq 1 ]
        then
            MESSAGE="FAIL\tThe negotiation rate is less than the maximum rate, linkrate: ${linkrate} > ${mum}."
            echo ${MESSAGE}
            return 1
        fi
        ;;
    esac
    end_num=`fdisk -l | grep /dev/sd | wc -l`
    if [ "${init_num}" -ne "${end_num}" ]
    then
        MESSAGE="FAIL\tDisk missing when setting ${name} rate."
        echo ${MESSAGE}
        return 1
    fi

    return 0
}

# set rate link value
# IN : N/A
# OUT: N/A
function set_rate_link()
{
    Test_Case_Title="set_rate_link"

    for dir in `ls "${PHY_FILE_PATH}"`
    do
	    echo "Begin to check sas type in "${dir}
        type=`cat ${PHY_FILE_PATH}/${dir}/target_port_protocols`
        num=`echo "${dir}" | awk -F ":" '{print $NF}'`
        if [ x"${type}" == x"none" ] || [ ${num} -gt ${EFFECTIVE_PHY_NUM} ]
        then
            continue
        fi
        case ${type} in
            "sata")
            for rate in "${SATA_PHY_VALUE_LIST[@]}"
            do
                modify_phy_rate ${dir} "${rate}" "minimum_linkrate"
                if [ $? -eq 1 ]
                then
                    return 1
                fi
                modify_phy_rate ${dir} "${rate}" "maximum_linkrate"
                if [ $? -eq 1 ]
                then
                    return 1
                fi
            done
            ;;
            "ssp")
            for rate in "${SAS_PHY_VALUE_LIST[@]}"
            do
                modify_phy_rate ${dir} "${rate}" "minimum_linkrate"
                if [ $? -eq 1 ]
                then
                    return 1
                fi
                modify_phy_rate ${dir} "${rate}" "maximum_linkrate"
                if [ $? -eq 1 ]
                then
                    return 1
                fi
            done
            ;;
        esac
        # Reset initial rate value.
        echo "12.0 Gbit" > ${PHY_FILE_PATH}/${dir}/maximum_linkrate
        echo "1.5 Gbit" > ${PHY_FILE_PATH}/${dir}/minimum_linkrate
        sleep 5
    done
    MESSAGE="PASS"
    echo ${MESSAGE}
}

#set_rate_link
#exit 0

# Rate set up
# IN : N/A
# OUT: N/A
function rate_set_up()
{
    Test_Case_Title="rate_set_up"

    set_rate_link
    [ $? -ne 0 ] && return 1

    MESSAGE="PASS"
    echo ${MESSAGE} 
}

function main()
{
    # call the implementation of the automation use cases
    test_case_function_run
}

main
