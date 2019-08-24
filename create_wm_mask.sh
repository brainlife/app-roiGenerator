#!/bin/bash

## Create white matter mask and move rois to diffusion space for tracking

parc=`jq -r '.parc' config.json`
dwi=`jq -r '.dwi' config.json`
fsurfer=`jq -r '.freesurfer' config.json`
inputparc=`jq -r '.inputparc' config.json`
export input_nii_gz=$dwi;

source $FREESURFER_HOME/SetUpFreeSurfer.sh

mri_label2vol --seg $fsurfer/mri/${inputparc}+aseg.mgz --temp $input_nii_gz --regheader $fsurfer/mri/${inputparc}+aseg.mgz --o ${inputparc}+aseg.nii.gz
mri_binarize --i ${inputparc}+aseg.nii.gz --min 1 --o mask_anat.nii.gz
mri_binarize --i ${inputparc}+aseg.nii.gz --o wm_anat.nii.gz --match 2 41 16 17 28 60 51 53 12 52 13 18 54 50 11 251 252 253 254 255 10 49 46 7

if [[ ${parc} == "null" ]]; then
    echo "inputparc is freesurfer. appropriate file already generated"
else
    mri_convert $parc parc.mgz
    mri_label2vol --seg parc.mgz --temp $input_nii_gz --regheader parc.mgz --o parc_diffusion.nii.gz
fi

# convert thalamic nuclei mgz to nifti
mri_label2vol --seg $fsurfer/mri/ThalamicNuclei.v10.T1.FSvoxelSpace.mgz --temp $input_nii_gz --regheader $fsurfer/mri/ThalamicNuclei.v10.T1.FSvoxelSpace.mgz --o thalamicNuclei.nii.gz
