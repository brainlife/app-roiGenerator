#!/bin/bash

set -x

## This script uses AFNI's (Taylor PA, Saad ZS (2013).  FATCAT: (An Efficient) Functional And Tractographic Connectivity Analysis Toolbox. Brain 
## Connectivity 3(5):523-535. https://afni.nimh.nih.gov/) 3dROIMaker function to a) remove the white matter mask from the cortical segmentation 
## inputted (i.e. freesurfer or parcellation; BE CAREFUL: REMOVES SUBCORTICAL ROIS) and b) inflates the ROIs by n voxels into the white matter 
## based on user input (option for no inflation is also built in). The output of this will then passed into a matlab function (roiGeneration.m) to 
## create nifti's for each ROI requested by the user, which can then be fed into a ROI to ROI tracking app (brainlife.io; www.github.com/brain-life/
## app-roi2roitracking).

INFLATE=`jq -r '.cortInflate' config.json`
thalamusInflate=`jq -r '.thalamusInflate' config.json`
brainmask=mask.nii.gz;
inputparc=`jq -r '.inputparc' config.json`
whitematter=`jq -r '.whitematter' config.json`
thalamic=`jq -r '.thalamic' config.json`
prf=`jq -r '.prf' config.json`
visInflate=`jq -r '.visInflate' config.json`

mkdir parc

if [[ ${INFLATE} == 'null' ]]; then
	echo "no inflation";
	l2='-prefix parc_inflate';
else
	echo "${INFLATE} voxel inflation applied to every cortical label in parcellation";
	l2="-inflate ${INFLATE} -prefix parc_inflate";
fi

if [[ ${thalamusInflate} == 'null' ]]; then
	echo "no thalamic inflation";
	l3='-prefix thalamus_inflate';
else
	echo "${thalamusInflate} voxel inflation applied to every thalamic label";
	l3="-inflate ${thalamusInflate} -prefix thalamus_inflate";
fi

if [[ ${visInflate} == 'null' ]]; then
        echo "no visual area inflation";
        l4='-prefix visarea_inflate';
else
        echo "${visInflate} voxel inflation applied to every visual area label";
        l4="-inflate ${visInflate} -prefix visarea_inflate";
fi

if [[ ${fsurfInflate} == 'null' ]]; then
        echo "no freesurfer inflation";
        l5='-prefix ${inputparc}_inflate';
else
        echo "${fsurfInflate} voxel inflation applied to every freesurfer label";
        l5="-inflate ${fsurfInflate} -prefix ${inputparc}_inflate";
fi


if [ ${whitematter} == "true" ]; then
	echo "white matter segmentation included";
	l1='-skel_stop'
else
	echo "removing white matter segmentation";
	l1='-skel_stop -trim_off_wm';
fi

## Inflate ROI
if [ -f parc_diffusion.nii.gz ]; then
	3dROIMaker \
		-inset parc_diffusion.nii.gz \
		-refset parc_diffusion.nii.gz \
		-mask ${brainmask} \
		-wm_skel wm_anat.nii.gz \
		-skel_thr 0.5 \
		${l1} \
		${l2} \
		-nifti \
		-overwrite;
fi

if [[ ${fsurf} == "false" ]]; then
	echo "no freesurfer inflation"
else
	3dROIMaker \
                -inset ${inputparc}+aseg.nii.gz \
                -refset ${inputparc}+aseg.nii.gz \
                -mask ${brainmask} \
                -wm_skel wm_anat.nii.gz \
                -skel_thr 0.5 \
                ${l1} \
                ${l5} \
                -nifti \
                -overwrite;
fi

# inflate thalamus
if [[ ${thalamic} == "false" ]]; then
	echo "no thalamic nuclei segmentation"
else
	3dROIMaker \
		-inset thalamicNuclei.nii.gz \
		-refset thalamicNuclei.nii.gz \
		-mask ${brainmask} \
		-wm_skel wm_anat.nii.gz \
		-skel_thr 0.5 \
		${l1} \
		${l3} \
		-nifti \
		-overwrite;
fi

# inflate visual areas
if [[ ${prf} == "false" ]]; then
        echo "no visual area inflation"
else
        3dROIMaker \
                -inset varea_dwi.nii.gz \
                -refset varea_dwi.nii.gz \
                -mask ${brainmask} \
                -wm_skel wm_anat.nii.gz \
                -skel_thr 0.5 \
                ${l1} \
                ${l4} \
                -nifti \
                -overwrite;
fi

# inflate hippocampus: to do later!
#if [[ ${hippocampus} == "false" ]]; then
#        echo "no thalamic nuclei segmentation"
#else
#        3dROIMaker \
#                -inset thalamicNuclei.nii.gz \
#                -refset thalamicNuclei.nii.gz \
#                -mask ${brainmask} \
#                -wm_skel wm_anat.nii.gz \
#                -skel_thr 0.5 \
#                ${l1} \
#                ${l3} \
#                -nifti \
#                -overwrite;
#fi
