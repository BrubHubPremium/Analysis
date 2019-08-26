#!/bin/bash

# Cifti separate to giftis:

sub=$1
export OMP_NUM_THREADS=2
export PATH=$PATH:/home/jcho/workbench/bin_rh_linux64
echo ${sub} 'Metric Resample'
echo ${sub}

mkdir -p /data3/cdb/jcho/hcp180/${sub}
cd /data3/cdb/jcho/hcp180/${sub}
mkdir metric_out
mkdir 10k_resample
mkdir projdist
chmod -R 777 /data3/cdb/jcho/hcp180/${sub}

subdir=/data3/cdb/jcho/hcp180/${sub}
subdatadir=/data3/cdb/DATASET_DOWNLOAD/HCP_unrel_457/data/${sub}/MNINonLinear/Results
subsurf=/data3/cdb/DATASET_DOWNLOAD/HCP_unrel_457/data/${sub}/MNINonLinear/fsaverage_LR32k
metric_out=${subdir}/metric_out
for task in 'REST'; do
for ses in '1' '2'; do
for encode in 'LR' 'RL'; do

cp ${subdatadir}/rfMRI_${task}${ses}_${encode}/rfMRI_${task}${ses}_${encode}_Atlas_MSMAll.dtseries.nii.gz ${metric_out}/rfMRI_${task}${ses}_${encode}_Atlas_MSMAll.dtseries.nii.gz
cd ${metric_out}
rm ${metric_out}/rfMRI_${task}${ses}_${encode}_Atlas_MSMAll.dtseries.nii
7z x ${metric_out}/rfMRI_${task}${ses}_${encode}_Atlas_MSMAll.dtseries.nii.gz

subcifti=${metric_out}/rfMRI_${task}${ses}_${encode}_Atlas_MSMAll.dtseries.nii
subciftiout=${metric_out}/rfMRI_${task}${ses}_${encode}_Atlas_MSMAll_hp2000_clean
subnifti=${metric_out}/rfMRI_${task}${ses}_${encode}_Atlas_MSMAll_hp2000_clean.FAKENIFTI

echo "Processing ${sub} ${task}${ses}_${encode}"

hp=0.01
lp=0.1
TR=0.720
SM=6
sigma=2.55
cp ${subsurf}/${sub}.L.midthickness_MSMAll.32k_fs_LR.surf.gii ${subdir}/10k_resample/
cp ${subsurf}/${sub}.R.midthickness_MSMAll.32k_fs_LR.surf.gii ${subdir}/10k_resample/

lsurf=${subdir}/10k_resample/${sub}.L.midthickness_MSMAll.32k_fs_LR.surf.gii
rsurf=${subdir}/10k_resample/${sub}.R.midthickness_MSMAll.32k_fs_LR.surf.gii

subgifti_left=${metric_out}/L.rfMRI_${task}${ses}_${encode}_MSMAll_32k_fsLR_filt_sm6
subgifti_right=${metric_out}/R.rfMRI_${task}${ses}_${encode}_MSMAll_32k_fsLR_filt_sm6

#if [ -f ${subnifti}.nii.gz ]; then
#:
#else
rm ${subnifti}.nii.gz
wb_command -cifti-convert -to-nifti ${subcifti} ${subnifti}.nii.gz
#fi

#if [ -f ${subnifti}_filt.nii.gz ]; then
 #:
#else
rm ${subnifti}_filt.nii.gz
OMP_NUM_THREADS=2 3dBandpass -dt ${TR} -input ${subnifti}.nii.gz -band ${hp} ${lp} -prefix ${subnifti}_filt.nii.gz
#3dBandpass -dt ${TR} -input ${subnifti}.nii.gz -band ${hp} ${lp} -prefix ${subnifti}_filt.nii.gz
#fi

#if [ -f ${subciftiout}_filt.dtseries.nii ]; then
#:
#else
wb_command -cifti-convert -from-nifti ${subnifti}_filt.nii.gz ${subcifti} ${subciftiout}_filt.dtseries.nii
#fi


#rm ${subnifti}.nii.gz
#rm ${subnifti}_filt.nii.gz

#if [ -f ${subciftiout}_filt_sm6.dtseries.nii ]; then
#:
#else
#start=$SECONDS
OMP_NUM_THREADS=2 wb_command -cifti-smoothing ${subciftiout}_filt.dtseries.nii $sigma $sigma COLUMN ${subciftiout}_filt_sm6.dtseries.nii -left-surface ${lsurf} -right-surface ${rsurf}
#duration=$(( SECONDS - start ))
#echo $duration
#fi

#if [ -f ${subgifti_left}.func.gii ]; then
#:
#else
wb_command -cifti-separate ${subciftiout}_filt_sm6.dtseries.nii COLUMN -metric CORTEX_LEFT ${subgifti_left}.func.gii -metric CORTEX_RIGHT ${subgifti_right}.func.gii
#fi
#rm r*
#chmod -R 777 /home/hcpuser/data/${sub} 
done
done
done

