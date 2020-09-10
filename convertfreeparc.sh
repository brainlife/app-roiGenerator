#!/bin/bash

## Create white matter mask and move rois to diffusion space for tracking

input_nii_gz=`jq -r '.input_nifti' config.json`
fsurfer=`jq -r '.freesurfer' config.json`
inputparc=`jq -r '.inputparc' config.json`

source $FREESURFER_HOME/SetUpFreeSurfer.sh

# create aparc in dwi nifti space for later parcellation and roi generation
mri_label2vol --seg $fsurfer/mri/${inputparc}+aseg.mgz --temp $input_nii_gz --regheader $fsurfer/mri/${inputparc}+aseg.mgz --o ${inputparc}+aseg.nii.gz
