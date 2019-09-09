#!/bin/bash

bidsdir=/data/Projects/indi_projects/PRIME/data_BIDS
jdir=/data3/cdb/jcho/monkey
# type='NoT'
type='T'

tmp_head=${jdir}/NMT/tmp_head/NMT
tmp_brain=${jdir}/NMT/tmp_brain/NMT_SS
# Run AFNI 3dSkullStrip on monkey data
i=$1
site=`echo ${i} | cut -d '/' -f1`
sub=`echo ${i} | cut -d '/' -f2`
file=`echo ${i} | cut -d '/' -f3`
filestring=`echo ${file} | cut -d '.' -f1`

mkdir -p ${jdir}/data_d_N4_nu_${type}_masked/${site}/${sub}

fslmaths ${jdir}/data_d_N4_nu/${i} -mul ${jdir}/O_site-other_PreMasks_${type}_site-all_ME_30/${filestring}_pre_mask.nii.gz ${jdir}/data_d_N4_nu_${type}_masked/${filestring}_pre_mask_brain.nii.gz 

flirt -v -dof 12 -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -in ${jdir}/data_d_N4_nu_${type}_masked/${filestring}_pre_mask_brain.nii.gz  -ref ${tmp_brain}.nii.gz -o ${jdir}/data_d_N4_nu_${type}_masked/${site}/${sub}/${filestring}_pre_mask_brain_rot2atl -omat ${jdir}/data_d_N4_nu_${type}_masked/${site}/${sub}/${filestring}_pre_mask_brain_rot2atl.mat

flirt -in ${jdir}/data_d_N4_nu/${i} -ref ${tmp_brain} -o ${jdir}/data_d_N4_nu_${type}_masked/${site}/${sub}/${sub}_rot2atl -applyxfm -init ${jdir}/data_d_N4_nu_${type}_masked/${site}/${sub}/${filestring}_pre_mask_brain_rot2atl.mat -interp sinc

flirt -in ${jdir}/O_site-other_PreMasks_${type}_site-all_ME_30/${filestring}_pre_mask.nii.gz -ref ${tmp_brain} -o ${jdir}/data_d_N4_nu_${type}_masked/${site}/${sub}/${sub}_rot2atl_pre_mask -applyxfm -init ${jdir}/data_d_N4_nu_${type}_masked/${site}/${sub}/${filestring}_pre_mask_brain_rot2atl.mat -interp sinc
