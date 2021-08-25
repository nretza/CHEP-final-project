#!/bin/bash

[[ ! -d $1 ]] && echo "Not a valid directory!" && return 1

while read File; do
	cd $(dirname $File)
	cp $(basename $File) backup.dat
	awk '{if ($3 == 0) print $0}' < backup.dat 1> $(basename $File)
	rm backup.dat
	cd ~-
done < <(find ${1} -type f -name "event_*.dat")
