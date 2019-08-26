#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Jan 16 18:23:42 2019

@author: jaewook.cho
"""

# Get dice coeff. from silver standard mask vs AFNI,FSL,FS,HMENet, MEnet
import numpy as np
import nibabel as nib
from scipy.spatial.distance import dice
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import pandas as pd
import seaborn as sns
dir_ = '/data3/cdb/jcho/monkey'
wd = '%s/4xindi8' % dir_

datadir = '%s/data' % dir_

pipelines = ['ants','afni','fsl','fs']
sites = ['site-ecnu-chen','site-ion','site-newcastle','site-oxford','site-sbri','site-ucdavis']
mainds = {}
std = {}

std['afni'] = {}
std['fsl'] = {}
std['fs'] = {}
std['ants'] = {}

mainds['afni'] = {}
mainds['fsl'] = {}
mainds['fs'] = {}
mainds['ants'] = {}

for site in sites:
    mainds['afni'][site] = []
    mainds['fsl'][site] = []
    mainds['fs'][site] = []
    mainds['ants'][site] = []

    std['afni'][site] = []
    std['fsl'][site] = []
    std['fs'][site] = []
    std['ants'][site] = []

sublist = np.loadtxt('%s/lists/4xindi6site8subs_T1_anatavg.list' % dir_,dtype='str')

for t1 in sublist:
    print(t1)
    site,sub,t1img = t1.split('/')
    t1name = t1img.split('.')[0]

    # ANTS
    fants = nib.load('%s/%s/%s/anat_avg/ants/%s_T1w_denoise_N4_anat_avg_mask.nii.gz' % (datadir,site,sub,sub))
    antsimg = fants.get_fdata().flatten()
    mainds['ants'][site].append(antsimg)

    antsstd = nib.load(glob.glob('%s/%s/%s/*_mask_corrected.nii.gz' % (wd,site,sub))[0])
    stdants = antsstd.get_fdata().flatten()
    std['ants'][site].append(stdants)

    # AFNI
    fafni = nib.load('%s/%s/%s/anat_avg/%s_T1w_denoise_N4_anat_avg_brainmask_afni_mask.nii.gz' % (datadir,site,sub,sub))
    afniimg = fafni.get_fdata().flatten()
    mainds['afni'][site].append(afniimg)

    afnistd = nib.load(glob.glob('%s/%s/%s/*_mask_corrected.nii.gz' % (wd,site,sub))[0])
    stdafni = afnistd.get_fdata().flatten()
    std['afni'][site].append(stdafni)

    # FSL
    ffsl = nib.load('%s/%s/%s/%s_fsl_mask.nii.gz' % (wd,site,sub,t1name))
    fslimg = ffsl.get_fdata().flatten()
    mainds['fsl'][site].append(fslimg)

    fslstd = nib.load(glob.glob('%s/%s/%s/*_mask_corrected.nii.gz' % (wd,site,sub))[0])
    stdfsl = fslstd.get_fdata().flatten()
    std['fsl'][site].append(stdfsl)

    # FS
    ffs= nib.load('%s/%s/%s/%s_fs_mask.nii.gz' % (wd,site,sub,t1name))
    fsimg = ffs.get_fdata().flatten()
    mainds['fs'][site].append(fsimg)

    fsstd = nib.load(glob.glob('%s/%s/%s/*_mask_corrected.nii.gz' % (wd,site,sub))[0])
    stdfs = fsstd.get_fdata().flatten()
    std['fs'][site].append(stdfs)

files = {'imgs': mainds, 'std': std}
np.save('/data3/cdb/jcho/monkey/4xindi8/4xindi6-8_pipelinemask_stdmask.npy',files)


ddist = {}
for site in sites:
    ddist[site] = {}
    for p in pipelines:
        print(site)
        ddist[site][p] = []
        ds = mainds[p][site]
        stds = std[p][site]
        nsubs = len(ds)
        for i in range(nsubs):
            tmp = 1 - dice(ds[i],stds[i].flatten())
            ddist[site][p].append(tmp)
            

mat = {}
names = {}
for site in sites:
    names[site] = []
    mat[site] = []
    for p in pipelines:
        if p == 'fsl':
            pp = 'FSL'
        elif p == 'afni':
            pp = 'AFNI'
        elif p == 'ants':
            pp = 'ANTs'
        elif p == 'fs':
            pp = 'FreeSurfer'
        else:
            pp = p
        nsubs = len(ddist[site][p])
        for i in range(nsubs):
            mat[site].append(ddist[site][p][i])
            names[site].append(pp)

savemat = {'Pipeline': names, 'Dice Similarity': mat}
np.save('/data3/cdb/jcho/monkey/4xindi8/4xindi6-8_pipelinemask_stdmask_dice.npy',savemat)

prettymat = {'Site':[],'Dice Similarity':[],'Pipeline':[]}
for site in bigmat['Dice Similarity'].keys():
    prettymat['Site'].append([site] * len(bigmat['Dice Similarity'][site]))
    prettymat['Dice Similarity'].append(bigmat['Dice Similarity'][site])
    prettymat['Pipeline'].append(bigmat['Pipeline'][site])

prettymat['Site'] = np.hstack(prettymat['Site'])
prettymat['Dice Similarity'] = np.hstack(prettymat['Dice Similarity'])
prettymat['Pipeline'] = np.hstack(prettymat['Pipeline'])
pdf = pd.DataFrame(prettymat)
np.save('/data3/cdb/jcho/monkey/4xindi8/4xindi6-8_pipelinemask_stdmask_pdf.npy',pdf)


a1 = sns.color_palette('Greys')
a1 = a.as_hex()

a = sns.color_palette('pastel')
a = a.as_hex()


pdf = np.load('/data3/cdb/jcho/monkey/4xindi8/4xindi6-8_pipelinemask_stdmask_pdf.npy')
unet = [0.9678,0.9597,0.9616,0.9779,0.9733,0.9720]
unet1 = [2,2,2,2,2,2]
x1 = np.mean(unet)
yerr = np.mean(
[0.0125,0.0052,0.0098,0.0036 ,0.0021,0.0051])
unetlabel = ['Unet'] * 6
unetsites = ['site-sbri','site-ecnu-chen','site-newcastle','site-ion','site-ucdavis','site-oxford']
unetsites1 = ['site-ecnu-chen','site-ion','site-newcastle','site-oxford','site-sbri','site-ucdavis']
newdice = np.hstack((pdf[:,0],unet))
newlabel = np.hstack((pdf[:,1],unetlabel))
newsites = np.hstack((pdf[:,2],unetsites))
nounet = pd.DataFrame({'Dice Similarity':pdf[:,0],'Pipeline':pdf[:,1],'Site':pdf[:,2]})
nounet['Dice Similarity'] = nounet['Dice Similarity'].astype(float)
nounet = nounet[nounet.Pipeline != 'ANTs']



pdf = pd.DataFrame({'Dice Similarity':newdice,'Pipeline':newlabel,'Site':newsites})
pdf['Dice Similarity'] = pdf['Dice Similarity'].astype(float)
pdf = pdf[pdf.Pipeline != 'ANTs']

# Box plot with red error for UNet
ax = plt.figure(figsize=(10,10))
plt.ylim([0,1])
ax = sns.boxplot(x=pdf['Pipeline'],y=pdf["Dice Similarity"],palette=['red','dimgray','gray','darkgrey'],dodge=True,width=.4,order=['Unet','AFNI','FreeSurfer','FSL'],boxprops=dict(alpha=0.6))
ax = sns.swarmplot(x="Pipeline",y="Dice Similarity",data = pdf,color='dimgray',order=['Unet','AFNI','FreeSurfer','FSL'])
plt.errorbar(x=0,y=x1,yerr=yerr,color='r',marker='o',capsize=15,ms=5)
plt.ylabel('Dice Similarity',fontsize=20)
plt.xlabel('Pipeline',fontsize=15)
plt.xticks(np.arange(4),('UNet','AFNI','FreeSurfer','FSL'))
plt.title('Dice Similarity for Monkey Skull Stripping',fontweight='bold',fontsize=15,ha='center',pad=10)
plt.savefig('/data3/cdb/jcho/monkey/4xindi8/blackboxplots.png',dpi=300)

# Line plot with red line for UNet
ax = plt.figure(figsize=(10,10))
plt.ylim([0,1])
# ax = sns.lineplot(x=nounet['Site'],y=nounet["Dice Similarity"],hue=nounet["Pipeline"],alpha=0.5,palette=['slategrey','olivedrab','darkgoldenrod'])
ax = sns.pointplot(x=pdf['Site'],y=pdf["Dice Similarity"],hue=pdf["Pipeline"],palette=['slategrey','olivedrab','darkgoldenrod','red'],capsize=.1,scale=2)
plt.errorbar(x=unetsites1,y=unet,yerr=yerr,color='r',marker='o',capsize=6,ms=5,capthick=2)
afni_patch = mpatches.Patch(color='slategrey',label='AFNI')
fsl_patch = mpatches.Patch(color='olivedrab',label='FSL')
freesurfer_patch = mpatches.Patch(color='darkgoldenrod',label='FreeSurfer')
red_patch = mpatches.Patch(color='red',label="$\\bf{UNet}$")
plt.legend(handles=[red_patch,afni_patch,fsl_patch,freesurfer_patch],prop={'size':17})
plt.ylabel('Dice Similarity',fontsize=25,labelpad=18,fontweight='bold')
plt.xlabel('Sites',fontsize=25,labelpad=20,fontweight='bold')
plt.xticks(np.arange(6),['SBRI','ECNU-Chen','Newcastle','ION','UCDavis','Oxford'],fontweight='bold',fontsize=16)
plt.yticks(fontsize=25)
plt.title('Monkey Skull-Stripping Pipelines',fontweight='bold',fontsize=30,ha='center',pad=40)
plt.savefig('/data3/cdb/jcho/monkey/4xindi8/lineplot.png',dpi=300)





ax = plt.figure(figsize=(30,10),dpi=200)
ax = sns.boxplot(x="Site",y="Dice Similarity",hue="Pipeline",data=pdf,palette='pastel',dodge=True,width=.4)
plt.errorbar(x=0.1,y=0.9678,yerr=0.0125,color='r',marker='o',capsize=10,ms=5)
plt.errorbar(x=1.1,y=0.9597,yerr=0.0052,color='r',marker='o',capsize=10,ms=5)
plt.errorbar(x=2.1,y=0.9616,yerr=0.0098,color='r',marker='o',capsize=10,ms=5)
plt.errorbar(x=3.1,y=0.9779,yerr=0.0036 ,color='r',marker='o',capsize=10,ms=5)
plt.errorbar(x=4.1,y=0.9733,yerr=0.0021,color='r',marker='o',capsize=10,ms=5)
plt.errorbar(x=5.1,y=0.9720,yerr=0.0051,color='r',marker='o',capsize=10,ms=5)
ants_patch = mpatches.Patch(color=a[0],label='ANTs')
afni_patch = mpatches.Patch(color=a[1],label='AFNI')
fsl_patch = mpatches.Patch(color=a[2],label='FSL')
freesurfer_patch = mpatches.Patch(color=a[3],label='FreeSurfer')
red_patch = mpatches.Patch(color='red',label='UNet')
plt.legend(handles=[ants_patch,afni_patch,fsl_patch,freesurfer_patch,red_patch])
plt.savefig('/data3/cdb/jcho/monkey/4xindi8/redUNet_6site8subs.png')
#%%
