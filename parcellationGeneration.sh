#!/bin/bash

set -x

## This script uses AFNI's (Taylor PA, Saad ZS (2013).  FATCAT: (An Efficient) Functional And Tractographic Connectivity Analysis Toolbox. Brain 
## Connectivity 3(5):523-535. https://afni.nimh.nih.gov/) 3dROIMaker function to a) remove the white matter mask from the cortical segmentation 
## inputted (i.e. freesurfer or parcellation; BE CAREFUL: REMOVES SUBCORTICAL ROIS) and b) inflates the ROIs by n voxels into the white matter 
## based on user input (option for no inflation is also built in). The output of this will then passed into a matlab function (roiGeneration.m) to 
## create nifti's for each ROI requested by the user, which can then be fed into a ROI to ROI tracking app (brainlife.io; www.github.com/brain-life/
## app-roi2roitracking).

# bl config inputs
rois=`jq -r '.rois' config.json`

# # make output directories and copy ROIs
mkdir -p rois rois/rois parc
cp -v ${rois}/*.nii.gz ./rois/rois/

# grab all ROI names. may need to change to include ability to select ROIs to include in parellation
FILES=(`echo "./rois/rois/*.nii.gz"`)

# # # create parcellation of all rois
3dcalc -a ${FILES[0]} -prefix zeroDataset.nii.gz -expr '0'
3dTcat -prefix all_pre.nii.gz zeroDataset.nii.gz ./rois/rois/*.nii.gz
outimg="all_pre.nii.gz"

# # make parcellation
3dTstat -argmax -prefix allroiss.nii.gz ${outimg}
3dcalc -byte -a allroiss.nii.gz -expr 'a' -prefix allrois_byte.nii.gz

# # create roi of eccentricity rois for tracking
3dcalc -a allrois_byte.nii.gz -expr 'step(a)' -prefix parc.nii.gz

# create key.txt for parcellation
for i in "${!FILES[@]}"
do
	# make key.txt
	if [[ ! "${FILES[$i]}" == *"ROI"* ]]; then
		name=`echo ${FILES[$i]}`
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
	jsonstring=`jq --arg key0 'name' --arg value0 "${oldval}" --arg key1 "desc" --arg value1 "value of ${newval} indicates voxel belonging to ROI${oldval}" --arg key2 "voxel_value" --arg value2 ${newval} '. | .[$key0]=$value0 | .[$key1]=$value1 | .[$key2]=$value2' <<<'{}'`
	if [ ${i} -eq 0 ]; then
		echo -e "[\n${jsonstring}," >> tmp.json
	elif [ ${newval} -eq ${#FILES[*]} ]; then
		echo -e "${jsonstring}\n]" >> tmp.json
	else
		echo -e "${jsonstring}," >> tmp.json
	fi
done

# pretty format label.json
jq '.' tmp.json > label.json

# # clean up
if [ -f parc.nii.gz ]; then
	# # clean up
	mv parc.nii.gz ./parc/parc.nii.gz;
	mv key.txt ./parc/key.txt;
	mv label.json ./parc/label.json
	rm -rf ./rois/ tmp.json
	echo "completed"
else
	echo "parcellation failed to be generated. Please check .err and .log files to examine issues"
	exit 1
fi
