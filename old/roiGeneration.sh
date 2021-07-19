#!/bin/bash

set -x

## This script uses AFNI's (Taylor PA, Saad ZS (2013).  FATCAT: (An Efficient) Functional And Tractographic Connectivity Analysis Toolbox. Brain 
## Connectivity 3(5):523-535. https://afni.nimh.nih.gov/) 3dROIMaker function to a) remove the white matter mask from the cortical segmentation 
## inputted (i.e. freesurfer or parcellation; BE CAREFUL: REMOVES SUBCORTICAL ROIS) and b) inflates the ROIs by n voxels into the white matter 
## based on user input (option for no inflation is also built in). The output of this will then passed into a matlab function (roiGeneration.m) to 
## create nifti's for each ROI requested by the user, which can then be fed into a ROI to ROI tracking app (brainlife.io; www.github.com/brain-life/
## app-roi2roitracking).

# inputs
rois=`jq -r '.rois' config.json`
mergeROIsL=`jq -r '.mergeROIsL' config.json`
mergeROIsR=`jq -r '.mergeROIsR' config.json`
mergeL=($mergeROIsL)
mergeR=($mergeROIsR)
mergename=`jq -r '.mergename' config.json`
mergenames=($mergename)

# copy rois
if [ ! -d ./rois ] mkdir -r rois rois/rois && cp -R ${rois}/* ./rois/rois/ && rois='./rois/rois'

# identify roi names
rois_avail=(`ls ${rois}`)

# create parcellation of all rois
3dcalc -a ${rois_avail[0]} -prefix zeroDataset.nii.gz -expr '0'
3dTcat -prefix all_pre.nii.gz zeroDataset.nii.gz *ROI*.nii.gz
3dTstat -argmax -prefix allroiss.nii.gz all_pre.nii.gz
3dcalc -byte -a allroiss.nii.gz -expr 'a' -prefix allrois_byte.nii.gz

if [[ -z ${mergeROIsL} ]] || [[ -z ${mergeROIsR} ]]; then
        echo "no merging of rois"
else
        #merge rois
	if [[ ! -z ${mergeROIsL} ]]; then
		
		# check if multiple merged rois are being asked for; else just append
		if [ `echo "${mergeROIsL}" | wc -l` -gt 1 ]; then
			mergeArray=()
			while read -r line; do
				mergeArray+=("$line")
			done <<< "$mergeROIsL"
			for (( i=0; i<${#mergeArray[@]}; i++ ))
			do
				mergeArrayL=""
				mergeName=${mergenames[$i]}

				for j in ${mergeArray[$i]}
				do 
					mergeArrayL=$mergeArrayL" `echo ${rois}/ROI$j.nii.gz`"
				done
				echo ${mergeArrayL} ${mergeName}
				3dTcat -prefix merge_preL.nii.gz zeroDataset.nii.gz `ls ${mergeArrayL}`
		        	3dTstat -argmax -prefix ${mergeName}L_nonbyte.nii.gz merge_preL.nii.gz
		        	3dcalc -byte -a ${mergeName}L_nonbyte.nii.gz -expr 'a' -prefix ${mergeName}L_allbytes.nii.gz
		        	3dcalc -a ${mergeName}L_allbytes.nii.gz -expr 'step(a)' -prefix ROI${mergeName}_L.nii.gz
		        	rm -rf merge_preL.nii.gz ${mergeName}L_nonbyte.nii.gz ${mergeName}L_allbytes.nii.gz
	        	done
        	else
			mergeArrayL=""
			for i in "${mergeL[@]}"
			do
				mergeArrayL="$mergeArrayL `echo ${rois}/ROI"$i".nii.gz`"
			done
			
			3dTcat -prefix merge_preL.nii.gz zeroDataset.nii.gz `ls ${mergeArrayL}`
	        	3dTstat -argmax -prefix ${mergename}L_nonbyte.nii.gz merge_preL.nii.gz
	        	3dcalc -byte -a ${mergename}L_nonbyte.nii.gz -expr 'a' -prefix ${mergename}L_allbytes.nii.gz
	        	3dcalc -a ${mergename}L_allbytes.nii.gz -expr 'step(a)' -prefix ROI${mergename}_L.nii.gz
	        fi
	fi
	if [[ ! -z ${mergeROIsR} ]]; then

		# check if multiple merged rois are being asked for; else just append
		if [ `echo "${mergeROIsR}" | wc -l` -gt 1 ]; then
			mergeArray=()
			while read -r line; do
				mergeArray+=("$line")
			done <<< "$mergeROIsR"
			for (( i=0; i<${#mergeArray[@]}; i++ ))
			do 
				mergeArrayR=""
				mergeName=${mergenames[$i]}

				for j in ${mergeArray[$i]}
				do 
					mergeArrayR=$mergeArrayR" `echo ${rois}/ROI$j.nii.gz`"
				done

				3dTcat -prefix merge_preR.nii.gz zeroDataset.nii.gz `ls ${mergeArrayR}`
		        	3dTstat -argmax -prefix ${mergeName}R_nonbyte.nii.gz merge_preR.nii.gz
		        	3dcalc -byte -a ${mergeName}R_nonbyte.nii.gz -expr 'a' -prefix ${mergeName}R_allbytes.nii.gz
		        	3dcalc -a ${mergeName}R_allbytes.nii.gz -expr 'step(a)' -prefix ROI${mergeName}_R.nii.gz
		        	rm -rf merge_preR.nii.gz ${mergeName}R_nonbyte.nii.gz ${mergeName}R_allbytes.nii.gz
			done
        	else
			mergeArrayR=""
			for i in "${mergeR[@]}"
			do
				mergeArrayR="$mergeArrayR `echo ${rois}/ROI*"$i".nii.gz`"
			done
			
			3dTcat -prefix merge_preR.nii.gz zeroDataset.nii.gz `ls ${mergeArrayR}`
	        	3dTstat -argmax -prefix ${mergename}R_nonbyte.nii.gz merge_preR.nii.gz
	        	3dcalc -byte -a ${mergename}R_nonbyte.nii.gz -expr 'a' -prefix ${mergename}R_allbytes.nii.gz
	        	3dcalc -a ${mergename}R_allbytes.nii.gz -expr 'step(a)' -prefix ROI${mergename}_R.nii.gz
	        fi
	fi
fi

# clean up
if [ -f ./allrois_byte.nii.gz ]; then
	mv *ROI*.nii.gz ./rois/rois/;
	rm -rf *.nii.gz* *.niml.* tmp.json
fi
