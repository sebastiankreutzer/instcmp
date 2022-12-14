#!/bin/bash

if [ ! -f "$1" ]; then
    echo "Please specify a valid input binary" 1>&2
    exit
fi

probeName=${2:-'__cyg_profile_func_enter'}

objdump -j .text -d "$1" | csplit - /'<.*>:'/ {*} -f'disass_fn' -s && rm disass_fn00
#grep -c '__cyg_profile_func_enter' disass_fn* | awk -F: '{f=$1 ; count=$2 ; grepcmd="grep -oP '(?<=<).*(?=>:)'" f; sytem(grep_cmd) }'
#counts=$(grep -c '__cyg_profile_func_enter' disass_fn* | awk -F: '{f=$1 ; count=$2 ; print f " " count "\n" }')
#grep -c '__cyg_profile_func_enter' disass_fn* | awk -F: '{f=$1 ; count=$2 ; print f " " count }'
counts=$(grep -c "$probeName" disass_fn*)

for line in $counts; do
    #echo "Processing line $line"
    f=$(echo "$line" | cut -d':' -f 1)
    count=$(echo "$line" | cut -d':' -f 2)
    fn=$(grep -oP '(?<=<).*(?=>:)' $f)
    echo "$fn $count"
done
rm disass_fn*
