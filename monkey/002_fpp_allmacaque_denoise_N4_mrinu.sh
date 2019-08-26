#!/bin/bash

scan=$1
bidsdir=/data/Projects/indi_projects/PRIME/data_BIDS
jdir=/data3/cdb/jcho/monkey

site=`echo ${scan} | cut -d '/' -f1`
sub=`echo ${scan} | cut -d '/' -f2`
ses=`echo ${scan} | cut -d '/' -f3`
file=`echo ${scan} | cut -d '/' -f5`
filestring=`echo ${file} | cut -d '.' -f1`

input=${scan}
outdir=${jdir}/data/${site}/${sub}/${ses}/anat
outdir2=${jdir}/data_d_N4_nu/${site}/${sub}/${ses}/anat
mkdir -p ${outdir}
mkdir -p ${outdir2}

if [[ ! -f ${outdir}/${filestring}_denoise.nii.gz ]]; then
# Run denoise:
echo "Denoising ${scan}"
DenoiseImage -d 3 -i ${input} -v -o ${outdir}/${filestring}_denoise.nii.gz
else
echo "${scan} denoise already done"
fi
# Run N4
if [[ ! -f ${outdir}/${filestring}_denoise_N4.nii.gz ]]; then
echo "Running N4 on ${scan}"
N4BiasFieldCorrection -v -d 3 -s 2 -i ${outdir}/${filestring}_denoise.nii.gz -o ${outdir}/${filestring}_denoise_N4.nii.gz
else
echo "${scan} N4 already done"
fi
# Run mri_nu_correct
if [[ ! -f ${outdir2}/${filestring}_denoise_N4_nu.nii.gz ]]; then
echo "Running mri_nu_correct on ${scan}"
mri_nu_correct.mni --i ${outdir}/${filestring}_denoise_N4.nii.gz --o ${outdir2}/${filestring}_denoise_N4_nu.nii.gz --n 6 --proto-iters 150 --stop .0001
else
echo "${scan} mri_nu_correct already done"
fi
