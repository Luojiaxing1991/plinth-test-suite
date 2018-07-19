#!/bin/bash

# pcie local
# IN :N/A
# OUT:N/A

StatusRegAddr=("a" "b" "c") 
MaskRegAddr=("d" "e" "f")
ErrorRegAddr=("g" "h" "i")
ErrorRegVal=("j" "k" "l")

function init_reg()
{
    for var in $(seq 0 ${#StatusRegAddr[@]}) 
    do
        echo "StatusRegAddr："${StatusRegAddr[$var]} 
    done
    for var in $(seq 0 ${#MaskRegAddr[@]}) 
    do
        echo "MaskRegAddr："${MaskRegAddr[$var]}
    done
}
function pcie_local_error_inject()
{
    for var in $(seq 0 ${#ErrorRegAddr[@]}) 
    do
        echo "ErrorRegAddr："${ErrorRegAddr[$var]}
    done
}

function main()
{
    init_reg
    pcie_local_error_inject
}

main 