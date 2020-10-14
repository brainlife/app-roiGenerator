#!/bin/bash

## Create white matter mask and move rois to diffusion space for tracking

fsurfer=`jq -r '.freesurfer' config.json`
inputparc=`jq -r '.inputparc' config.json`

source $FREESURFER_HOME/SetUpFreeSurfer.sh

# create white matter mask
mri_convert $fsurfer/mri/ribbon.mgz ./ribbon.nii.gz && input_nii_gz="./ribbon.nii.gz"
mri_label2vol --seg $fsurfer/mri/${inputparc}+aseg.mgz --temp $input_nii_gz --regheader $fsurfer/mri/${inputparc}+aseg.mgz --o ${inputparc}+aseg.nii.gz
mri_binarize --i ${inputparc}+aseg.nii.gz --min 1 --o mask_anat.nii.gz
mri_binarize --i ${inputparc}+aseg.nii.gz --o wm_anat.nii.gz --match 2 41 16 17 28 60 51 53 12 52 13 18 54 50 11 251 252 253 254 255 10 49 46 7
input_nii_gz="${inputparc}+aseg.nii.gz"
mri_convert $fsurfer/mri/brainmask.mgz ./mask.nii.gz

# convert thalamic nuclei mgz to nifti
mri_label2vol --seg $fsurfer/mri/ThalamicNuclei.*.T1.FSvoxelSpace.mgz --temp $input_nii_gz --regheader $fsurfer/mri/ThalamicNuclei.*.T1.FSvoxelSpace.mgz --o thalamicNuclei.nii.gz
