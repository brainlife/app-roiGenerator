#!/bin/bash

set -x

## This script uses AFNI's (Taylor PA, Saad ZS (2013).  FATCAT: (An Efficient) Functional And Tractographic Connectivity Analysis Toolbox. Brain
## Connectivity 3(5):523-535. https://afni.nimh.nih.gov/) 3dROIMaker function to a) remove the white matter mask from the cortical segmentation
## inputted (i.e. freesurfer or parcellation; BE CAREFUL: REMOVES SUBCORTICAL ROIS) and b) inflates the ROIs by n voxels into the white matter
## based on user input (option for no inflation is also built in). The output of this will then passed into a matlab function (roiGeneration.m) to
## create nifti's for each ROI requested by the user, which can then be fed into a ROI to ROI tracking app (brainlife.io; www.github.com/brain-life/
## app-roi2roitracking).

inputparc=`jq -r '.inputparc' config.json`
visROINames="v1 v2 v3 hv4 vO1 vO2 lO1 lO2 tO1 tO2 v3b v3a lgn optic-chiasm"
visROINames=($visROINames)
visrois=""
hemispheres="lh rh"

for i in ${!visROINames[@]}
do
	if [[ ${visROINames[$i]} == 'optic-chiasm' ]]; then
		visrois=$visrois" ./rois/rois/ROI${visROINames[$i]}.nii.gz"
	else
		for h in ${hemispheres}
		do
			visrois=$visrois" ./rois/rois/ROI${h}.${visROINames[$i]}.nii.gz"
		done
	fi
done

# create parcellation of all rois
3dcalc -a ${inputparc}+aseg.nii.gz -prefix zeroDataset.nii.gz -expr '0'
3dTcat -prefix all_pre.nii.gz zeroDataset.nii.gz ${visrois}
outimg="all_pre.nii.gz"

# create parcellation
3dTstat -argmax -prefix allroiss.nii.gz ${outimg}
3dcalc -byte -a allroiss.nii.gz -expr 'a' -prefix allrois_byte.nii.gz

# create roi of eccentricity rois for tracking
3dcalc -a allrois_byte.nii.gz -expr 'step(a)' -prefix ROIvarea.nii.gz

# create key.txt for parcellation
FILES=(${visrois})
for i in "${!FILES[@]}"
do
	if [[ ! "${FILES[$i]#./rois/rois/}" == *"ROI"* ]]; then
		name=`echo ${FILES[$i]} | sed -e "s/.nii.gz//" | cut -d'.' -f3`
		if [[ "${FILES[$i]}" == *"lh"* ]]; then
			oldval="lh.${name}"
		else
			oldval="rh.${name}"
		fi
	else
		oldval=`echo ${FILES[$i]} | sed -e 's/.*ROI\(.*\).nii.gz/\1/'`
	fi
	newval=$((i + 1))
	echo -e "1\t->\t${newval}\t== ${oldval}" >> key.txt

	# make tmp.json containing data for labels.json
	jsonstring=`jq --arg key0 'name' --arg value0 "${oldval}" --arg key1 "desc" --arg value1 "value of ${newval} indicates voxel belonging to ROI${oldval}" --arg key2 "voxel_value" --arg value2 ${newval} --arg key3 "label" --arg value3 ${newval} '. | .[$key0]=$value0 | .[$key1]=$value1 | .[$key2]=$value2 | .[$key3]=$value3' <<<'{}'`
	if [ ${i} -eq 0 ] && [ ${newval} -eq ${#FILES[*]} ]; then
		echo -e "[\n${jsonstring}\n]" >> tmp.json
	elif [ ${i} -eq 0 ]; then
		echo -e "[\n${jsonstring}," >> tmp.json
	elif [ ${newval} -eq ${#FILES[*]} ]; then
		echo -e "${jsonstring}\n]" >> tmp.json
	else
		echo -e "${jsonstring}," >> tmp.json
	fi
done

# clean up
if [ -f allrois_byte.nii.gz ]; then
	[ ! -d parc ] && mkdir -p parc
	mv allrois_byte.nii.gz ./parc/parc.nii.gz;
	mv key.txt ./parc/key.txt;
	mv tmp.json ./parc/label.json
	mv *ROI*.nii.gz ./rois/rois/;
fi
