#!/bin/bash

# output lines to log files and fail if error
# set -x
# set -e

# parse inputs
prfSurfacesDir=`jq -r '.prfSurfacesDir' config.json`
prfVerticesDir=`jq -r '.prfVerticesDir' config.json`
minDegree=`jq -r '.min_degree' config.json` # min degree for binning of eccentricity
maxDegree=`jq -r '.max_degree' config.json` # max degree for binning of eccentricity
freesurfer=`jq -r '.freesurfer' config.json`
inputparc=`jq -r '.inputparc' config.json`
# input_nii_gz=`jq -r '.input_nii_gz' config.json`
hemispheres="lh rh"
dwi=`jq -r '.dwi' config.json`
fmri=`jq -r '.func' config.json`
freesurfer=`jq -r '.freesurfer' config.json`
inputparc=`jq -r '.inputparc' config.json`

# make directories
[ ! -d parc ] && mkdir parc
[ ! -d raw ] && mkdir raw

# make degrees loopable
minDegree=($minDegree)
maxDegree=($maxDegree)

# set up some stuff to move inputaparc to space
if [ -f ${dwi} ]; then
	input_nii_gz=$dwi
elif [ -f ${fmri} ]; then
	input_nii_gz=$fmri
else
	input_nii_gz="./ribbon.nii.gz"
fi

# source $FREESURFER_HOME/SetUpFreeSurfer.sh

# set SUBJECTS_DIR
export SUBJECTS_DIR=${freesurfer}

# inputaparc to diffusion space
[ ! -f ${inputparc}+aseg.nii.gz ] && mri_label2vol --seg $freesurfer/mri/${inputparc}+aseg.mgz --temp $input_nii_gz --regheader $freesurfer/mri/${inputparc}+aseg.mgz --o ${inputparc}+aseg.nii.gz

# use this as internal target for volume moves
input_nii_gz="${inputparc}+aseg.nii.gz"

# move freesurfer whole-brain ribbon into diffusion space
[ ! -f ribbon.nii.gz ] && mri_convert ${freesurfer}/mri/ribbon.mgz ./ribbon.nii.gz

# loop through hemispheres and create eccentricity surfaces
for hemi in ${hemispheres}
do
	echo "converting files for ${hemi}"

	# move freesurfer hemisphere ribbon into diffusion space
	[ ! -f ${hemi}.ribbon.nii.gz ] && mri_convert $freesurfer/mri/${hemi}.ribbon.mgz ./${hemi}.ribbon.nii.gz

	# convert pial to gifti
	[ ! -f ${hemi}.pial ] && mris_convert ${freesurfer}/surf/${hemi}.pial ./${hemi}.pial

	# convert eccentricity surface to gifti
	[ ! -f ${hemi}.eccentricity.func.gii ] && mris_convert -c ${prfSurfacesDir}/${hemi}.eccentricity ./${hemi}.pial ${hemi}.eccentricity.func.gii

	# create mask of visual occipital lobe
	[ ! -f ${hemi}.mask.func.gii ] && wb_command -metric-math 'x / x' -var x ${hemi}.eccentricity.func.gii ${hemi}.mask.func.gii

	# loop through degrees and create individual nifti files for each bin and hemisphere
	for DEG in ${!minDegree[@]}; do
		# genereate eccentricity bin surfaces and mask eccentricities
		[ ! -f ./${hemi}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.func.gii ] && mri_binarize --i ./${hemi}.eccentricity.func.gii --min ${minDegree[$DEG]} --max ${maxDegree[$DEG]} --o ./${hemi}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.func.gii && wb_command -metric-mask ./${hemi}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.func.gii ./${hemi}.mask.func.gii ./${hemi}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.func.gii

		# create volume-based binned file
		[ ! -f ./${hemi}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz ] && mri_surf2vol --o ./${hemi}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz --subject ./ --so ./${hemi}.pial ./${hemi}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.func.gii && mri_vol2vol --mov ./${hemi}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz --targ ${input_nii_gz} --regheader --o ./${hemi}.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz --nearest
	done
done