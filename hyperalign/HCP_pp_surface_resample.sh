#!/bin/bash

sub=$1
export OMP_NUM_THREADS=2
subdir=/data3/cdb/jcho/hcp180/${sub}
subsurf=/data3/cdb/DATASET_DOWNLOAD/HCP_unrel_457/data/${sub}/MNINonLinear/fsaverage_LR32k   
stddir=/data3/cdb/jcho/hcp180/surfs
for task in 'tfMRI_WM' 'tfMRI_GAMBLING' 'tfMRI_LANGUAGE' 'tfMRI_MOTOR' 'tfMRI_RELATIONAL' 'tfMRI_SOCIAL' 'rfMRI_REST1' 'rfMRI_REST2'; do
for encode in 'LR' 'RL'; do
surfdir=${subdir}/10k_resample
echo "Processing ${sub} ${task}${ses}_${encode}"

subgifti_left=${metric_out}/L.rfMRI_${task}${ses}_${encode}_MSMAll_32k_fsLR_filt_sm6
subgifti_right=${metric_out}/R.rfMRI_${task}${ses}_${encode}_MSMAll_32k_fsLR_filt_sm6

for hemi in 'L' 'R'; do

#Surfs:
submid=${subsurf}/${sub}.${hemi}.midthickness.32k_fs_LR.surf.gii
subsph=${subsurf}/${sub}.${hemi}.sphere.32k_fs_LR.surf.gii
newsph=${stddir}/S1200.${hemi}.sphere.10k_fs_LR.surf.gii
outmid=${subdir}/10k_resample/${sub}.${hemi}.midthickness_MSMAll.10k.surf.gii

#Funcs:
wb_command -surface-resample ${submid} ${subsph} ${newsph} BARYCENTRIC ${outmid}

done
done
done
done
