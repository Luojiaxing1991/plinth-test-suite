#!/bin/bash

# rasd hha error reading and reporting
# IN :N/A
# OUT:N/A


function hha_error_reading_and_reporting()
{   
    set addr=0x90120500
    set val=0x1080208
    devmem addr 32 val |& tee file2
    cat file2
    flag=`cat file2 |grep -e 'event severity: recoverable' -e 'section_type: memory error.' -e '0x000000001234500' | wc -l`
    echo $flag
    if [ $flag -ne 3 ]; then
        echo fail
    else
        echo pass
    fi 
}

function main()
{
    JIRA_ID=""
    Test_Item="The driver must support reading and reporting"
    Designed_Requirement_ID="R.RAS."
    hha_error_reading_and_reporting
}

main 
