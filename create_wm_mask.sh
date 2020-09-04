#!/bin/bash

## Create white matter mask and move rois to diffusion space for tracking

parc=`jq -r '.parc' config.json`
dwi=`jq -r '.dwi' config.json`
dtiinit=`jq -r '.dtiinit' config.json`
thalamicROIs=`jq -r '.thalamicROIs' config.json`
fsurfer=`jq -r '.freesurfer' config.json`
inputparc=`jq -r '.inputparc' config.json`

# parse whether input is dtiinit or dwi
if [[ ${dtiinit} = "null" ]]; then
	export input_nii_gz=$dwi;
else
	export input_nii_gz=$dtiinit/`jq -r '.files.alignedDwRaw' $dtiinit/dt6.json`
fi

source $FREESURFER_HOME/SetUpFreeSurfer.sh

# create white matter mask
mri_label2vol --seg $fsurfer/mri/${inputparc}+aseg.mgz --temp $input_nii_gz --regheader $fsurfer/mri/${inputparc}+aseg.mgz --o ${inputparc}+aseg.nii.gz
mri_binarize --i ${inputparc}+aseg.nii.gz --min 1 --o mask_anat.nii.gz
mri_binarize --i ${inputparc}+aseg.nii.gz --o wm_anat.nii.gz --match 2 41 16 17 28 60 51 53 12 52 13 18 54 50 11 251 252 253 254 255 10 49 46 7

# convert thalamic nuclei mgz to nifti
mri_label2vol --seg $fsurfer/mri/ThalamicNuclei.*.T1.FSvoxelSpace.mgz --temp $input_nii_gz --regheader $fsurfer/mri/ThalamicNuclei.*.T1.FSvoxelSpace.mgz --o thalamicNuclei.nii.gz

# reslice glasser parc to dwi
mri_label2vol --seg ${parc} --temp $input_nii_gz --regheader ${parc} --o parc_dwi.nii.gz
