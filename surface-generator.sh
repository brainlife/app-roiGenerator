#!/bin/bash

# output lines to log files and fail if error
set -x
set -e

# parse inputs
prfSurfacesDir=`jq -r '.prfDir' config.json`
freesurfer=`jq -r '.freesurfer' config.json`
inputparc=`jq -r '.inputparc' config.json`
hemispheres="lh rh"

input_nii_gz="${inputparc}+aseg.nii.gz"

# glasser ROIS
visROIs="1 2 3 4 5 6 7 8 9 10 11 12"
visROINames="v1 v2 v3 hv4 vO1 vO2 lO1 lO2 tO1 tO2 v3b v3a"
visROIs=($visROIs)
visROINames=($visROINames)

# make degrees loopable
minDegree=($minDegree)
maxDegree=($maxDegree)

# set SUBJECTS_DIR
export SUBJECTS_DIR=${freesurfer}

# move freesurfer whole-brain ribbon into diffusion space
[ ! -f ribbon.nii.gz ] && mri_convert ${freesurfer}/mri/ribbon.mgz ./ribbon.nii.gz

# loop through hemispheres and create eccentricity surfaces
for hemi in ${hemispheres}
do
	echo "converting files for ${hemi}"

	# move freesurfer hemisphere ribbon into diffusion space
	[ ! -f ${hemi}.ribbon.nii.gz ] && mri_convert $freesurfer/mri/${hemi}.ribbon.mgz ./${hemi}.ribbon.nii.gz

	# convert varea surface to gifti
	[ ! -f ${hemi}.varea.func.gii ] && mris_convert -c ${prfSurfacesDir}/${hemi}.varea ${freesurfer}/surf/${hemi}.pial ${hemi}.varea.func.gii

	# create visual area rois
	for i in ${!visROIs[@]}
	do
		echo "${visROINames[$i]}"
		[ ! -f ${hemi}.${visROINames[$i]}.func.gii ] && mri_binarize --i ./${hemi}.varea.func.gii --match ${visROIs[$i]} --o ./${hemi}.${visROINames[$i]}.func.gii
		[ ! -f ./rois/rois/ROI${hemi}.${visROINames[$i]}.nii.gz ] && mri_surf2vol --o ./rois/rois/ROI${hemi}.${visROINames[$i]}.nii.gz --subject ./ --so ${freesurfer}/surf/${hemi}.pial ./${hemi}.${visROINames[$i]}.func.gii && mri_vol2vol --mov ./rois/rois/ROI${hemi}.${visROINames[$i]}.nii.gz --targ ${input_nii_gz} --regheader --o ./rois/rois/ROI${hemi}.${visROINames[$i]}.nii.gz --nearest
		done
	done
done
