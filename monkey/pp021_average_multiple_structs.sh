#!/bin/bash
# site-lyon/sub-032275
input=$1
# sitesub=`echo ${input} | cut -d '/' -f7-8`
sitesub=${input}
bidsdir=/data/Projects/indi_projects/PRIME/data_BIDS
jdir=/data3/cdb/jcho/monkey

t1list=`grep ${sitesub} ${jdir}/lists/alldata_d_N4_nu.list`

imgs=""
for i in ${t1list}; do
site=`echo ${i} | cut -d '/' -f1`
sub=`echo ${i} | cut -d '/' -f2`
ses=`echo ${i} | cut -d '/' -f3`
file=`echo ${i} | cut -d '/' -f5`
filestring=`echo ${file} | cut -d '.' -f1`
outdir=${jdir}/data_d_N4_nu/${site}/${sub}
rm -R ${outdir}
mkdir -p ${outdir}

imgs="${imgs} -i ${bidsdir}/${site}/${sub}/${ses}/anat/${filestring}.nii.gz"
done

if [[ !-f ${outdir}/${filestring}_anat_avg.nii.gz ]]; then
mri_motion_correct.fsl -o ${outdir}/${filestring}_anat_avg.nii.gz ${imgs}
else
echo "${sitesub} already done"
fi
