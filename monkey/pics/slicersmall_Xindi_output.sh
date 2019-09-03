#!/bin/bash
# monkey
# example call: 
# cd /Users/jaewook.cho/Downloads/xindi_sent/Others
# MaskDir=O_site-other_PreMasks_T_site-all_ME_30
# T1Dir=site-other/TestT1w
# for i in `ls ${T1Dir}/*`
# do
# FileName=$(basename $i)
# FilePrefix=${FileName%*.nii.gz}
# anatimg=${i}
# maskimg=${MaskDir}/${FilePrefix}_pre_mask.nii.gz
# picdir=/Users/jaewook.cho/Downloads/xindi_sent/pics/${MaskDir}
# bash /Users/jaewook.cho/slicersmall_Xindioutput.sh ${i} ${MaskDir}/${FilePrefix}_pre_mask.nii.gz /Users/jaewook.cho/Downloads/xindi_sent/pics/${MaskDir}
# done

anatimg=$1
maskimg=$2
picdir=$3
mkdir -p ${picdir}/rendered

subject=`echo ${anatimg} | cut -d '_' -f1`
subject=`echo ${subject} | cut -d '/' -f3`

overlay 1 1 ${anatimg} -a ${maskimg} 1 1 ${picdir}/rendered/${subject}_rendered

slicer ${picdir}/rendered/${subject}_rendered -a ${picdir}/${subject}_slicersmall.png
