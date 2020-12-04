#!/bin/bash

# output lines to log files and fail if error
set -x
set -e

# parse inputs
varea=`jq -r '.prfDir' config.json`
prfSurfacesDir=`jq -r '.prfSurfacesDir' config.json`
minDegree=`jq -r '.min_degree' config.json` # min degree for binning of eccentricity
maxDegree=`jq -r '.max_degree' config.json` # max degree for binning of eccentricity
freesurfer=`jq -r '.freesurfer' config.json`
input_nii_gz=`jq -r '.input_nifti' config.json`
hemispheres="lh rh"

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
[ ! -f ribbon.nii.gz ] && mri_vol2vol --mov ${freesurfer}/mri/ribbon.mgz --targ ${input_nii_gz} --regheader --o ribbon.nii.gz

# loop through hemispheres and create eccentricity surfaces
for hemi in ${hemispheres}
do
	echo "converting files for ${hemi}"
	parc=$(eval "echo \$${hemi}_annot")

	# move freesurfer hemisphere ribbon into diffusion space
	[ ! -f ${hemi}.ribbon.nii.gz ] && mri_vol2vol --mov $freesurfer/mri/${hemi}.ribbon.mgz --targ ${input_nii_gz} --regheader --o ${hemi}.ribbon.nii.gz

	# convert eccentricity surface to gifti
	[ ! -f ${hemi}.eccentricity.func.gii ] && mris_convert -c ${prfSurfacesDir}/${hemi}.eccentricity ${freesurfer}/surf/${hemi}.pial ${hemi}.eccentricity.func.gii

	for DEG in ${!minDegree[@]}; do
		# genereate eccentricity bin surfaces and multiply eccentricities by roi
		[ ! -f ./${hemi}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.func.gii ] && mri_binarize --i ./${hemi}.eccentricity.func.gii --min ${minDegree[$DEG]} --max ${maxDegree[$DEG]} --o ./${hemi}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.func.gii
	done
	
	# convert varea surface to gifti 
	[ ! -f ${hemi}.varea.func.gii ] && mris_convert -c ${prfSurfacesDir}/${hemi}.varea ${freesurfer}/surf/${hemi}.pial ${hemi}.varea.func.gii

	# create visual area rois
	for i in ${!visROIs[@]}
	do
		echo "${visROINames[$i]}"
		[ ! -f ${hemi}.${visROINames[$i]}.func.gii ] && mri_binarize --i ./${hemi}.varea.func.gii --match ${visROIs[$i]} --o ./${hemi}.${visROINames[$i]}.func.gii
		[ ! -f ROI${hemi}.${visROINames[$i]}.nii.gz ] && mri_surf2vol --o ROI${hemi}.${visROINames[$i]}.nii.gz --subject ./ --so ${freesurfer}/surf/${hemi}.pial ./${hemi}.${visROINames[$i]}.func.gii && mri_vol2vol --mov ROI${hemi}.${visROINames[$i]}.nii.gz --targ ${input_nii_gz} --regheader --o ROI${hemi}.${visROINames[$i]}.nii.gz --nearest

		# extract eccentricity bins for each glasser visual roi
		for DEG in ${!minDegree[@]}; do
			# genereate eccentricity bin surfaces and multiply eccentricities by roi
			[ ! -f ${hemi}.${visROINames[$i]}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.func.gii ] && wb_command -metric-math 'x*y' ${hemi}.${visROINames[$i]}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.func.gii -var x ${hemi}.${visROINames[$i]}.func.gii -var y ${hemi}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.func.gii

			# map surface to volume
			SUBJECTS_DIR=${freesurfer}
			[ ! -f ROI${hemi}.${visROINames[$i]}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz ] && mri_surf2vol --o ROI${hemi}.${visROINames[$i]}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz --subject ./ --so ${freesurfer}/surf/${hemi}.pial ./${hemi}.${visROINames[$i]}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.func.gii && mri_vol2vol --mov ROI${hemi}.${visROINames[$i]}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz --targ ${input_nii_gz} --regheader --o ROI${hemi}.${visROINames[$i]}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz --nearest
		done
	done
done
