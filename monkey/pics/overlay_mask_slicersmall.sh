#!/bin/bash
# monkey
# ex. input: site-uwo/sub-0032178
monk=$1

jdir=/data3/cdb/jcho/monkey
picdir=${jdir}/maskpics
rendered=${jdir}/maskpics/rendered

site=`echo $monk | cut -d "/" -f1`
subject=`echo $monk | cut -d "/" -f2`

anatimg=${jdir}/data/${site}/${subject}/anat_avg/ants/${subject}_T1w_denoise_N4_anat_avg.nii.gz
maskimg=${jdir}/data/${site}/${subject}/anat_avg/ants/${subject}_T1w_denoise_N4_anat_avg_mask.nii.gz

overlay 1 1 ${anatimg} -a ${maskimg} 1 1 ${rendered}/ants/${site}_${subject}_rendered

slicer ${rendered}/ants/${site}_${subject}_rendered -a ${picdir}/ants/${site}_${subject}_slicersmall.png
