#!/bin/bash

set -x

## This script uses AFNI's (Taylor PA, Saad ZS (2013).  FATCAT: (An Efficient) Functional And Tractographic Connectivity Analysis Toolbox. Brain 
## Connectivity 3(5):523-535. https://afni.nimh.nih.gov/) 3dROIMaker function to a) remove the white matter mask from the cortical segmentation 
## inputted (i.e. freesurfer or parcellation; BE CAREFUL: REMOVES SUBCORTICAL ROIS) and b) inflates the ROIs by n voxels into the white matter 
## based on user input (option for no inflation is also built in). The output of this will then passed into a matlab function (roiGeneration.m) to 
## create nifti's for each ROI requested by the user, which can then be fed into a ROI to ROI tracking app (brainlife.io; www.github.com/brain-life/
## app-roi2roitracking).

visROINames="v1 mst v6 v2 v3 v4 v8 fef pef v3a v7 ips1 ffc v3b lo1 lo2 pit mt mip pres pros pha1 pha3 te1p tf te2p pht ph tpoj2 tpoj3 dvt pgp ip0 v6a vmv1 vmv3 pha2 v4t fst v3cd lo3 vmv2 vvc lgn optic-chiasm"
visROINames=($visROINames)
visrois=""

for i in ${!visROINames[@]}
do
	visrois+=" `ls *${visROINames[$i]}.nii.gz`"
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
	if [[ ! "${FILES[$i]}" == *"ROI"* ]]; then
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
	jsonstring=`jq --arg key0 'name' --arg value0 "${oldval}" --arg key1 "desc" --arg value1 "value of ${newval} indicates voxel belonging to ROI${oldval}" --arg key2 "voxel_value" --arg value2 ${newval} '. | .[$key0]=$value0 | .[$key1]=$value1 | .[$key2]=$value2' <<<'{}'`
	if [ ${i} -eq 0 ]; then
	        echo -e "[\n${jsonstring}," >> tmp.json
	elif [ ${newval} -eq ${#FILES[*]} ]; then
	        echo -e "${jsonstring}\n]" >> tmp.json
	else
	        echo -e "${jsonstring}," >> tmp.json
	fi
done

# clean up
if [ -f allrois_byte.nii.gz ]; then
	mkdir -p parc_varea
	mv allrois_byte.nii.gz ./parc/parc.nii.gz;
	mv key.txt ./parc/key.txt;
	mv label.json ./parc/label.json
	rm -rf tmp.json
	mv *ROI*.nii.gz ./rois/rois/;
fi