#!/bin/bash

script_dir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ ! -f "$1" ] || [ ! -f "$2" ]; then
    echo "Please specify two valid binaries" 1>&2
    exit
fi

probeName=${3:-'__cyg_profile_func_enter'}

filterOutDotFns=${4:-1}
filterOutStdFns=${5:-1}

fileA=$(basename "$1")
filenameA="${fileA%.*}"

fileB=$(basename "$2")
filenameB="${fileB%.*}"

outA="${filenameA}_stats_A.txt"
outB="${filenameB}_stats_B.txt"


"$script_dir"/inststats.sh "$1" "$probeName" > "$outA"
"$script_dir"/inststats.sh "$2" "$probeName" > "$outB"

outCmpAB="${filenameA}_cmp_A_B.txt"
outCmpBA="${filenameB}_cmp_B_A.txt"

"$script_dir"/instcmp.sh "$outA" "$outB" "$filterOutDotFns" "$filterOutStdFns" > "$outCmpAB"
"$script_dir"/instcmp.sh "$outB" "$outA" "$filterOutDotFns" "$filterOutStdFns" > "$outCmpBA"

echo "Comparing instrumentation of $1 and $2"
echo "------------------------------"
echo "A <-> B"
echo "------------------------------"
cat "$outCmpAB" | tail -n 5
echo "------------------------------"
echo "B <-> A"
echo "------------------------------"
cat "$outCmpBA" | tail -n 5
echo "------------------------------"



