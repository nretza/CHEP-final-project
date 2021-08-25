#!/bin/bash

[[ ! -d $1 ]] && echo "Not a valid directory!" && return 2

for subDir in {0..9}; do

        [[ ! -d ${1}/${subDir} ]] && echo "ERROR: ${1}/${subDir} does not exist" && return 1

	cd ${1}/${subDir}

	brdr=($( grep -n BEGINNINGOFEVENT HIJING_LBF_test_small.out | awk 'BEGIN {FS=":"} {print $1}' ))
        low=()
	high=()

        for i in {0..9}; do
		low[i]=$((${brdr[i]}+2))
                high[i]=$((${brdr[((i+1))]}-1))
        done

        #unset high[0]
        high[$((${#high[*]}-1))]='$'

        #echo "low: ${low[*]}"
        #echo "high: ${high[*]}"

	for evNr in {0..9}; do

		#echo "low ${low[evNr]}"
		#echo "high ${high[evNr]}"

		sed -n "${low[evNr]},${high[evNr]}p" "HIJING_LBF_test_small.out" > "event_${evNr}.dat"

	done

	cd ~-

done
