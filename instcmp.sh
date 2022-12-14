#!/bin/bash

if [ ! -f "$1" ] || [ ! -f "$2" ]; then
    echo "Please specify two valid input files containing instrumentation stats" 1>&2
    exit
fi

filterOutDotFns=${3:-1}
filterOutStdFns=${4:-1}

mismatches=0
missingInA=0
missingInB=0
missingFunctions=0
skippedFunctions=0

while read -r line; do
    tokens=($line)
    #echo "${tokens[0]}, ${tokens[1]}"
    fn="${tokens[0]}"
    fnDemangled=$(c++filt "$fn")

    if [[ ("$filterOutDotFns" && $fn == *"."*) || ("$filterOutStdFns" && $fnDemangled == *"std::"*) ]]; then
        echo "Ignoring function $fnDemangled ($fn)"
        ((skippedFunctions+=1))
        continue
    fi


    count1="${tokens[1]}"
    count2=$(grep -m 1 "^$fn " "$2" | cut -d " " -f 2)
    #echo "Count1 : $count1"
    #echo "Count2 : $count2"

    if [ -z "$count2" ]; then
        echo "Function $fnDemangled does not exist in second binary"
        ((missingFunctions+=1))
    elif [ "$count1" -ne "$count2" ]; then
        echo "Mismatch in $fnDemangled: $count1, $count2"
        ((mismatches+=1))
        if [ $count1 -eq 0 ]; then
            ((missingInA+=1))
        elif [ $count2 -eq 0 ]; then
            ((missingInB+=1))
        fi
    fi
done < "$1"

echo "************************************************************"
echo "Number of skipped functions: $skippedFunctions"
echo "Number of functions missing entirely in B: $missingFunctions"
echo "Number of probe count mismatches: $mismatches"
echo "Number of functions that are instrumented in A, but not in B: $missingInB"
echo "Number of functions that are instrumented in B, but not in A: $missingInA"

