#!/bin/bash
# list in /lists
# scripts in /scripts

# Make 10k surfaces per sub:
cd /data3/cdb/jcho/hcp180
cat lists/anna_pp_subs.list | parallel -j 30 "/data3/cdb/jcho/hcp180/scripts/HCP_pp_surface_resample.sh" 2> HCP_pp_surface_resample_log.txt

# Resample ciftis:
cat lists/anna_pp_subs.list | parallel -j 30 "/data3/cdb/jcho/hcp180/scripts/pp01_resample_cifti.sh" 2> pp01_resample_cifti_log.txt

# Align rfMRI_REST1_LR+LR concat to Feilong 80 template & apply projection to all other tasks:
cat lists/anna_pp_subs.list | parallel -j 30 "python /data3/cdb/jcho/hcp180/scripts/HCP_pp_hyperalign.py" 2> HCP_pp_hyperalign_log.txt

# Parcellate using HCP MMP parcellation (360):
cd /data3/cdb/jcho/hcp180 # input is scans: 'sub/task/dtseries.nii'
ls */*/*R1LRRL* | parallel -j 25 "/data3/cdb/jcho/hcp180/scripts/001_iccprep_create_pconn.sh {} '_R1LRRL'" # hyperaligned
ls */*/*sm6.dtseries.nii* | parallel -j 25 "/data3/cdb/jcho/hcp180/scripts/001_iccprep_create_pconn.sh {} ''" # anatomy

# ICC and Discriminability analysis:
