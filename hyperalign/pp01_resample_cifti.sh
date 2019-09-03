#!/bin/bash

sub=$1
export OMP_NUM_THREADS=2
echo ${sub} 'Metric Resample'
echo ${sub}
adir=/data3/cdb/anna/HCP_unrel_457
subdir=/data3/cdb/jcho/hcp180/${sub}
subsurf=/data3/cdb/DATASET_DOWNLOAD/HCP_unrel_457/data/${sub}/MNINonLinear/fsaverage_LR32k       
stddir=/data3/cdb/jcho/hcp180/surfs
for task in 'tfMRI_WM' 'tfMRI_GAMBLING' 'tfMRI_LANGUAGE' 'tfMRI_MOTOR' 'tfMRI_RELATIONAL' 'tfMRI_SOCIAL' 'rfMRI_REST1' 'rfMRI_REST2'; do
for encode in 'LR' 'RL'; do

outdir=${subdir}/${task}_${encode}
mkdir -p ${outdir}

if [[ ${task} = 'rfMRI_REST1' ]] || [[ ${task} = 'rfMRI_REST2' ]]; then
ciftiin=${adir}/preprocess/${sub}/${task}_${encode}/${task}_${encode}_Atlas_MSMAll_hp2000_clean_24nuisance.reg_lin.trend_filt_sm6.dtseries.nii
else
ciftiin=${adir}/preprocess/${sub}/${task}_${encode}/${task}_${encode}_Atlas_MSMAll_24nuisance.reg_lin.trend_filt_sm6.dtseries.nii
fi 

echo "Processing ${sub} ${task}_${encode}"

subgifti_L=${outdir}/L.${task}_${encode}_32k_Atlas_MSMAll_clean_24nuisance.reg_lin.trend_filt_sm6
subgifti_R=${outdir}/R.${task}_${encode}_32k_Atlas_MSMAll_clean_24nuisance.reg_lin.trend_filt_sm6

wb_command -cifti-separate ${ciftiin} COLUMN -metric CORTEX_LEFT ${subgifti_L}.func.gii -roi ${subgifti_L}_roi.func.gii -metric CORTEX_RIGHT ${subgifti_R}.func.gii -roi ${subgifti_R}_roi.func.gii


for hemi in 'L' 'R'; do
#Surfs
submid=${subsurf}/${sub}.${hemi}.midthickness.32k_fs_LR.surf.gii
subsph=${subsurf}/${sub}.${hemi}.sphere.32k_fs_LR.surf.gii
newsph=${stddir}/S1200.${hemi}.sphere.10k_fs_LR.surf.gii
outmid=${subdir}/10k_resample/${sub}.${hemi}.midthickness_MSMAll.10k.surf.gii
#Funcs:
subgifti=${outdir}/${hemi}.${task}_${encode}_32k_Atlas_MSMAll_clean_24nuisance.reg_lin.trend_filt_sm6.func.gii
newsubgifti=${outdir}/${hemi}.${task}_${encode}_10k_Atlas_MSMAll_clean_24nuisance.reg_lin.trend_filt_sm6.func.gii
#Resample func to 10k
wb_command -metric-resample ${subgifti} ${subsph} ${newsph} ADAP_BARY_AREA ${newsubgifti} -area-surfs ${submid} ${outmid}

done

wb_command -cifti-create-dense-timeseries ${outdir}/${task}_${encode}_10k_Atlas_MSMAll_clean_24nuisance.reg_lin.trend_filt_sm6.dtseries.nii -left-metric ${outdir}/L.${task}_${encode}_10k_Atlas_MSMAll_clean_24nuisance.reg_lin.trend_filt_sm6.func.gii -right-metric ${outdir}/L.${task}_${encode}_10k_Atlas_MSMAll_clean_24nuisance.reg_lin.trend_filt_sm6.func.gii

rm ${outdir}/L.${task}_${encode}_32k_Atlas_MSMAll_clean_24nuisance.reg_lin.trend_filt_sm6.func.gii
rm ${outdir}/R.${task}_${encode}_32k_Atlas_MSMAll_clean_24nuisance.reg_lin.trend_filt_sm6.func.gii
rm ${outdir}/L.${task}_${encode}_10k_Atlas_MSMAll_clean_24nuisance.reg_lin.trend_filt_sm6.func.gii
rm ${outdir}/R.${task}_${encode}_10k_Atlas_MSMAll_clean_24nuisance.reg_lin.trend_filt_sm6.func.gii
done
done
