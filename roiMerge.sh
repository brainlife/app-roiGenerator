#!/bin/bash

set -x

## This script uses AFNI's (Taylor PA, Saad ZS (2013).  FATCAT: (An Efficient) Functional And Tractographic Connectivity Analysis Toolbox. Brain 
## Connectivity 3(5):523-535. https://afni.nimh.nih.gov/) functions to merge rois together to aid in further functional or diffusion tractography analyses.

# inputs
rois=`jq -r '.rois' config.json`
mergeROIsL=`jq -r '.mergeROIsL' config.json`
mergeROIsR=`jq -r '.mergeROIsR' config.json`
mergeL=($mergeROIsL)
mergeR=($mergeROIsR)
mergename=`jq -r '.mergename' config.json`
mergenames=($mergename)

# make parc dir
# [ ! -d ./parc ] && mkdir -p parc && parc='./parc'

# copy rois
[ ! -d ./rois ] && mkdir -p rois rois/rois && cp -R ${rois}/* ./rois/rois/ && rois='./rois/rois'

# identify roi names
rois_avail=(`ls ${rois}`)

# create parcellation of all rois
3dcalc -a ${rois}/${rois_avail[0]} -prefix zeroDataset.nii.gz -expr '0'

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

# move rois to output dir
mv *ROI*.nii.gz ./rois/rois/;

# create parcellation
# 3dTcat -prefix all_pre.nii.gz zeroDataset.nii.gz ${rois}/*ROI*.nii.gz
# 3dTstat -argmax -prefix allroiss.nii.gz all_pre.nii.gz
# 3dcalc -byte -a allroiss.nii.gz -expr 'a' -prefix allrois_byte.nii.gz

# # create key.txt for parcellation
# FILES=(`echo "${rois}*/ROI*.nii.gz"`)
# for i in "${!FILES[@]}"
# do
# 	oldval=`echo "${FILES[$i]}" | sed 's/.*ROI\(.*\).nii.gz/\1/'`
# 	newval=$((i + 1))
# 	echo -e "1\t->\t${newval}\t== ${oldval}" >> key.txt

# 	# make tmp.json containing data for labels.json
# 	jsonstring=`jq --arg key0 'name' --arg value0 "${oldval}" --arg key1 "desc" --arg value1 "value of ${newval} indicates voxel belonging to ROI${oldval}" --arg key2 "voxel_value" --arg value2 ${newval} '. | .[$key0]=$value0 | .[$key1]=$value1 | .[$key2]=$value2' <<<'{}'`
# 	if [ ${#FILES[*]} -eq 1 ]; then
# 		echo -e "[\n${jsonstring}\n]" >> tmp.json
# 	else
# 		if [ ${newval} -eq 1 ]; then
# 			echo -e "[\n${jsonstring}," >> tmp.json
# 		elif [ ${newval} -eq ${#FILES[*]} ]; then
# 			echo -e "${jsonstring}\n]" >> tmp.json
# 		else
# 			echo -e "${jsonstring}," >> tmp.json
# 		fi
# 	fi
# done

# # pretty format label.json
# jq '.' tmp.json > label.json

# clean up
# if [ -f ./label.json ]; then
# 	cp label.json ./rois/
# 	cp label.json ${parc}/
# 	mv allrois_byte.nii.gz ${parc}/parc.nii.gz
# 	mv key.txt ${parc}/
# 	rm -rf *.nii.gz* *.niml.* tmp.json label.json
# else
# 	echo "something went wrong. check logs"
# 	exit 1
# fi
