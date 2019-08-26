#!/bin/bash

sub=$1
export OMP_NUM_THREADS=2
echo ${sub} 'Metric Resample'
echo ${sub}
#mkdir /home/hcpuser/data/${sub}
#subdir=/home/hcpuser/data/${sub}
subdir=/data3/cdb/jcho/hcp180/${sub}
subsurf=/data3/cdb/DATASET_DOWNLOAD/HCP_unrel_457/data/${sub}/MNINonLinear/fsaverage_LR32k
#rm -R ${subdir}/metric_out
#mkdir ${subdir}/metric_out
metric_out=${subdir}/metric_out                 
#subs3=/s3/hcp/${sub}
#stddir=/home/hcpuser/data/surfs
stddir=/data3/cdb/jcho/hcp180/surfs
#chmod -R 777 /home/hcpuser/data/${sub} 
for task in 'REST'; do
for ses in '1' '2'; do
for encode in 'LR' 'RL'; do
#subcifti=${subs3}/MNINonLinear/Results/rfMRI_${task}${ses}_${encode}/rfMRI_${task}${ses}_${encode}_Atlas_MSMAll_hp2000_clean.dtseries.nii
subciftiout=${metric_out}/rfMRI_${task}${ses}_${encode}_Atlas_MSMAll_hp2000_clean
subnifti=${metric_out}/rfMRI_${task}${ses}_${encode}_Atlas_MSMAll_hp2000_clean.FAKENIFTI

echo "Processing ${sub} ${task}${ses}_${encode}"

hp=0.01
lp=0.1
TR=0.720
SM=6
sigma=2.55
# lsurf=${subs3}/MNINonLinear/fsaverage_LR32k/${sub}.L.midthickness_MSMAll.32k_fs_LR.surf.gii
# rsurf=${subs3}/MNINonLinear/fsaverage_LR32k/${sub}.R.midthickness_MSMAll.32k_fs_LR.surf.gii
# lsurf=${subsurf}/10k_resample/${sub}.L.midthickness_MSMAll.32k_fs_LR.surf.gii
# rsurf=${subsurf}/10k_resample/${sub}.R.midthickness_MSMAll.32k_fs_LR.surf.gii

subgifti_left=${metric_out}/L.rfMRI_${task}${ses}_${encode}_MSMAll_32k_fsLR_filt_sm6
subgifti_right=${metric_out}/R.rfMRI_${task}${ses}_${encode}_MSMAll_32k_fsLR_filt_sm6

for hemi in 'L' 'R'; do

#Surfs:
submid=${subsurf}/${sub}.${hemi}.midthickness.32k_fs_LR.surf.gii
subsph=${subsurf}/${sub}.${hemi}.sphere.32k_fs_LR.surf.gii
newsph=${stddir}/S1200.${hemi}.sphere.10k_fs_LR.surf.gii
outmid=${subdir}/10k_resample/${sub}.${hemi}.midthickness_MSMAll.10k.surf.gii

#Funcs:
subgifti=${metric_out}/${hemi}.rfMRI_${task}${ses}_${encode}_MSMAll_32k_fsLR_filt_sm6
newsubgifti=${metric_out}/${hemi}.rfMRI_${task}${ses}_${encode}_MSMAll_10k_filt_sm6
wb_command -surface-resample ${submid} ${subsph} ${newsph} BARYCENTRIC ${outmid}
#Resample func to 10k
#if [ -f ${newsubgifti}.func.gii ]; then
#:
#else
wb_command -metric-resample ${subgifti}.func.gii ${subsph} ${newsph} ADAP_BARY_AREA ${newsubgifti}.func.gii -area-surfs ${submid} ${outmid}
#fi


#Create std, std_bin for mask
wb_command -metric-reduce ${newsubgifti}.func.gii STDEV ${newsubgifti}_STDEV.func.gii
wb_command -metric-math '(a!=0)' ${newsubgifti}_STDEV_bin.func.gii -var a ${newsubgifti}_STDEV.func.gii

#chmod -R 777 /home/hcpuser/data/${sub}
mv ${newsubgifti}_STDEV_bin.func.gii /data3/cdb/jcho/hcp180/std/${hemi}.${task}${ses}_${encode}_${sub}_bin.func.gii
#rm ${newsubgifti}_STDEV.func.gii
#rm ${metric_out}/${hemi}.rfMRI_${task}${ses}_${encode}_MSMAll_32k_fsLR.dtseries.nii
#rm -R /tmp/hcp-openaccess/${sub}

done
done
done
done
