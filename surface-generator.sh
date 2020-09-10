#!/bin/bash

# output lines to log files and fail if error
set -x
set -e

# parse inputs
prfSurfacesDir=`jq -r '.prfSurfacesDir' config.json`
lh_annot=`jq -r '.lh_annot' config.json`
rh_annot=`jq -r '.rh_annot' config.json`
minDegree=`jq -r '.min_degree' config.json` # min degree for binning of eccentricity
maxDegree=`jq -r '.max_degree' config.json` # max degree for binning of eccentricity
freesurfer=`jq -r '.freesurfer' config.json`
input_nii_gz=`jq -r '.input_nifti' config.json`
hemispheres="lh rh"

# glasser ROIS
visROIs="2 3 4 5 6 7 8 11 12 14 17 18 19 20 21 22 23 24 50 120 122 127 128 134 136 137 138 139 141 142 143 144 147 153 154 155 156 157 158 159 160 161 164"
visROINames="v1 mst v6 v2 v3 v4 v8 fef pef v3a v7 ips1 ffc v3b lo1 lo2 pit mt mip pres pros pha1 pha3 te1p tf te2p pht ph tpoj2 tpoj3 dvt pgp ip0 v6a vmv1 vmv3 pha2 v4t fst v3cd lo3 vmv2 vvc "
visROIs=($visROIs)
visROINames=($visROINames)

# make degrees loopable
minDegree=($minDegree)
maxDegree=($maxDegree)

# set dwi as input

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
	
	# create glasser rois
	parc=$(eval "echo \$${hemi}_annot")
	for i in ${!visROIs[@]}
	do
		echo "${visROINames[$i]}"
		[ ! -f ${hemi}.${visROINames[$i]}.func.gii ] && wb_command -gifti-label-to-roi ${parc} ${hemi}.${visROINames[$i]}.func.gii -key ${visROIs[$i]}
		[ ! -f ./rois/rois/ROI${hemi}.${visROINames[$i]}.nii.gz ] && mri_surf2vol --o ./rois/rois/ROI${hemi}.${visROINames[$i]}.nii.gz --subject ./ --so ${freesurfer}/surf/${hemi}.pial ./${hemi}.${visROINames[$i]}.func.gii && mri_vol2vol --mov ./rois/rois/ROI${hemi}.${visROINames[$i]}.nii.gz --targ ${input_nii_gz} --regheader --o ./rois/rois/ROI${hemi}.${visROINames[$i]}.nii.gz --nearest

		# extract eccentricity bins for each glasser visual roi
		for DEG in ${!minDegree[@]}; do
			# genereate eccentricity bin surfaces and multiply eccentricities by roi
			[ ! -f ${hemi}.${visROINames[$i]}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.func.gii ] && wb_command -metric-math 'x*y' ${hemi}.${visROINames[$i]}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.func.gii -var x ${hemi}.${visROINames[$i]}.func.gii -var y ${hemi}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.func.gii

			# map surface to volume
			SUBJECTS_DIR=${freesurfer}
			[ ! -f ./rois/ROIrois/${hemi}.${visROINames[$i]}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz ] && mri_surf2vol --o ./rois/rois/ROI${hemi}.${visROINames[$i]}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz --subject ./ --so ${freesurfer}/surf/${hemi}.pial ./${hemi}.${visROINames[$i]}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.func.gii && mri_vol2vol --mov ./rois/rois/ROI${hemi}.${visROINames[$i]}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz --targ ${input_nii_gz} --regheader --o ./rois/rois/ROI${hemi}.${visROINames[$i]}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz --nearest
		done
	done
done
