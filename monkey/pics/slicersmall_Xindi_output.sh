#!/bin/bash
# monkey
# ex. input:

anatimg=$1
maskimg=$2
picdir=$3
mkdir -p ${picdir}/rendered

sub=`echo ${anatimg} | cut -d '_' -f1`

overlay 1 1 ${anatimg} -a ${maskimg} 1 1 ${picdir}/rendered/${subject}_rendered

slicer ${picdir}/rendered/${subject}_rendered -a ${picdir}/${subject}_slicersmall.png
