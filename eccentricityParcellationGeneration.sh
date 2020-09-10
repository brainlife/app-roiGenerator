#!/bin/bash

set -x

## This script uses AFNI's (Taylor PA, Saad ZS (2013).  FATCAT: (An Efficient) Functional And Tractographic Connectivity Analysis Toolbox. Brain 
## Connectivity 3(5):523-535. https://afni.nimh.nih.gov/) 3dROIMaker function to a) remove the white matter mask from the cortical segmentation 
## inputted (i.e. freesurfer or parcellation; BE CAREFUL: REMOVES SUBCORTICAL ROIS) and b) inflates the ROIs by n voxels into the white matter 
## based on user input (option for no inflation is also built in). The output of this will then passed into a matlab function (roiGeneration.m) to 
## create nifti's for each ROI requested by the user, which can then be fed into a ROI to ROI tracking app (brainlife.io; www.github.com/brain-life/
## app-roi2roitracking).

# bl config inputs
Min_Degree=`jq -r '.min_degree' config.json`
Max_Degree=`jq -r '.max_degree' config.json`
rois=`jq -r '.rois' config.json`
inputparc=`jq -r '.inputparc' config.json`

# make output directories and copy ROIs
mkdir -p rois rois/rois parc
cp -v ${rois}/*.nii.gz ./rois/rois/

# create parcellation of all rois
3dcalc -a ${inputparc}+aseg.nii.gz -prefix zeroDataset.nii.gz -expr '0'
3dTcat -prefix all_pre.nii.gz zeroDataset.nii.gz ./rois/rois/*.Ecc${Min_Degree}to${Max_Degree}.nii.gz
3dTstat -argmax -prefix allroiss.nii.gz all_pre.nii.gz
3dcalc -byte -a allroiss.nii.gz -expr 'a' -prefix allrois_byte.nii.gz

# create roi of eccentricity rois for tracking
3dcalc -a allrois_byte.nii.gz -expr 'step(a)' -prefix ROIEcc${Min_Degree}to${Max_Degree}.nii.gz

# create key.txt for parcellation
FILES=(`echo "./rois/rois/*.Ecc${Min_Degree}to${Max_Degree}*.nii.gz"`)
for i in "${!FILES[@]}"
do
	if [[ ! "${FILES[0]}" == *"ROI"* ]]; then
		name=`echo ${FILES[0]} | sed -e "s/.Ecc${Min_Degree}to${Max_Degree}.nii.gz//" | cut -d'.' -f3`
		if [[ "${name}" == *"lh"* ]]; then
			oldval="lh.${name}"
		else
			oldval="rh.${name}"
		fi
	else
		oldval=`echo ${FILES[$i]} | sed -e 's/.*ROI\(.*\).nii.gz/\1/' | sed -e "s/.Ecc${Min_Degree}to${Max_Degree}//"`
	fi
	newval=$((i + 1))
	echo "${oldval} -> ${newval}" >> key.txt
done

# clean up
mv allrois_byte.nii.gz ./parc/parc.nii.gz;
mv key.txt ./parc/key.txt;
mv *ROI*.nii.gz ./rois/rois/;

