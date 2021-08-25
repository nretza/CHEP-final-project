#!/bin/bash

#################################################

cat > Transfer.C <<'DOC'
#include "TFile.h"
#include "TTree.h"

int Transfer(const char *filename)

{
 TFile *file = new TFile("HIJING_LBF_test_small.root","update");
 TTree *tree = new TTree("event","data from ascii file");

 Long64_t nlines = tree->ReadFile(filename,"IDa/I:PID:IDc:IDd:px/F:py:pz:E");
 tree->Write(); // save TTree to 'output.root' file
 file->Close();

 return 0;   
}
DOC

#################################################

dir=$PWD

[[ ! -d $1 ]] && echo "Not a valid directory!" && return 2

for subDir in {0..9}; do

	[[ ! -d ${1}/${subDir} ]] && echo "ERROR: ${1}/${subDir} does not exist" && return 1

        cd ${1}/${subDir}

	for evNr in {0..9}; do

		[[ -s event_${evNr}.dat ]] && root -l -b -q ${dir}/Transfer.C\(\"event_${evNr}.dat\"\) 1> /dev/null && rm event_${evNr}.dat

	done

	cd ~-

done

rm Transfer.C

return 0
