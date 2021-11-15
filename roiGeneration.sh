#!/bin/bash

set -x

## This script uses AFNI's (Taylor PA, Saad ZS (2013).  FATCAT: (An Efficient) Functional And Tractographic Connectivity Analysis Toolbox. Brain 
## Connectivity 3(5):523-535. https://afni.nimh.nih.gov/) 3dROIMaker function to a) remove the white matter mask from the cortical segmentation 
## inputted (i.e. freesurfer or parcellation; BE CAREFUL: REMOVES SUBCORTICAL ROIS) and b) inflates the ROIs by n voxels into the white matter 
## based on user input (option for no inflation is also built in). The output of this will then passed into a matlab function (roiGeneration.m) to 
## create nifti's for each ROI requested by the user, which can then be fed into a ROI to ROI tracking app (brainlife.io; www.github.com/brain-life/
## app-roi2roitracking).

parcInflate=`jq -r '.parcInflate' config.json`
thalamusInflate=`jq -r '.thalamusInflate' config.json`
hippocampusInflate=`jq -r '.hippocampusInflate' config.json`
amygdalaInflate=`jq -r '.amygdalaInflate' config.json`
brainmask=mask.nii.gz;
inputparc=`jq -r '.inputparc' config.json`
whitematter=`jq -r '.whitematter' config.json`
thalamicROIs=`jq -r '.thalamicROIs' config.json`
parcellationROIs=`jq -r '.parcellationROIs' config.json`
prfROIs=`jq -r '.prfROIs' config.json`
visInflate=`jq -r '.visInflate' config.json`
fsurfInflate=`jq -r '.freesurferInflate' config.json`
freesurferROIs=`jq -r '.freesurferROIs' config.json`
subcorticalROIs=`jq -r '.subcorticalROIs' config.json`
hippocampalROIs=`jq -r '.hippocampalROIs' config.json`
skel_stop=`jq -r '.skel_stop' config.json`
neigh_def=`jq -r '.neigh_def' config.json`
amygdalaROIs=`jq -r '.amygdalaROIs' config.json`
mergeROIsL=`jq -r '.mergeROIsL' config.json`
mergeROIsR=`jq -r '.mergeROIsR' config.json`
mergeL=($mergeROIsL)
mergeR=($mergeROIsR)
mergename=`jq -r '.mergename' config.json`
mergenames=($mergename)

mkdir parc

if [[ ${parcInflate} == 'null' ]]; then
	echo "no inflation";
	l2="-prefix parc_inflate";
else
	echo "${parcInflate} voxel inflation applied to every cortical label in parcellation";
	l2="-inflate ${parcInflate} -prefix parc_inflate";
fi

if [[ ${thalamusInflate} == 'null' ]]; then
	echo "no thalamic inflation";
	l3="-prefix thalamus_inflate";
else
	echo "${thalamusInflate} voxel inflation applied to every thalamic label";
	l3="-inflate ${thalamusInflate} -prefix thalamus_inflate";
fi

if [[ ${visInflate} == 'null' ]]; then
        echo "no visual area inflation";
        l4="-prefix visarea_inflate";
else
        echo "${visInflate} voxel inflation applied to every visual area label";
        l4="-inflate ${visInflate} -prefix visarea_inflate";
fi

if [[ ${fsurfInflate} == 'null' ]]; then
        echo "no freesurfer inflation";
        l5="-prefix ${inputparc}+aseg_inflate";
else
        echo "${fsurfInflate} voxel inflation applied to every freesurfer label";
        l5="-inflate ${fsurfInflate} -prefix ${inputparc}+aseg_inflate";
fi

if [[ ${hippocampusInflate} == 'null' ]]; then
	echo "no hippocampal inflation";
	l3="-prefix hippocampus_inflate";
else
	echo "${hippocampusInflate} voxel inflation applied to every hipocampal label";
	l3="-inflate ${hippocampusInflate} -prefix hippocampus_inflate";
fi

if [[ ${amygdalaInflate} == 'null' ]]; then
	echo "no amygdala inflation";
	l3="-prefix amygdala_inflate";
else
	echo "${amgydalaInflate} voxel inflation applied to every amygdala label";
	l3="-inflate ${amygdalaInflate} -prefix amygdala_inflate";
fi

if [ ${whitematter} == "true" ]; then
	echo "white matter segmentation included";
	l1="";
else
	echo "removing white matter segmentation";
	l1="-trim_off_wm";
fi

# in thise case, skel_thr = 0.5
skel_thr = 0.5

if [[ ${skel_stop} == 'no_stop' ]]; then
	skel_stop=""
else
	skel_stop="-${skel_stop}"
fi

## Inflate parcellation ROIs
if [[ -z ${parcellationROIs} ]]; then
	echo "no parcellation inflation"
else
	#inflate
	3dROIMaker \
		-inset parc_diffusion.nii.gz \
		-refset parc_diffusion.nii.gz \
		-mask ${brainmask} \
		-wm_skel wm_anat.nii.gz \
		-skel_thr ${skel_thr} \
		${l1} \
		${l2} \
		-${neigh_def} \
		${skel_stop} \
		-nifti \
		-overwrite;

	#generate rois
	PARCROIS=`echo ${parcellationROIs} | cut -d',' --output-delimiter=$'\n' -f1-`
	for PARC in ${PARCROIS}
	do
		3dcalc -a parc_inflate_GMI.nii.gz -expr 'equals(a,'${PARC}')' -prefix ROIparc-${PARC}.nii.gz
	done
fi

## Inflate freesurfer ROIs
if [[ -z ${freesurferROIs} ]]; then
	echo "no freesurfer inflation"
else
	3dROIMaker \
                -inset ${inputparc}+aseg.nii.gz \
                -refset ${inputparc}+aseg.nii.gz \
                -mask ${brainmask} \
                -wm_skel wm_anat.nii.gz \
                -skel_thr ${skel_thr} \
                ${l1} \
                ${l5} \
                -${neigh_def} \
                ${skel_stop} \
                -nifti \
                -overwrite;
	
	#generate rois
        FREEROIS=`echo ${freesurferROIs} | cut -d',' --output-delimiter=$'\n' -f1-`
        for FREE in ${FREEROIS}
        do
                3dcalc -a ${inputparc}+aseg_inflate_GMI.nii.gz -expr 'equals(a,'${FREE}')' -prefix ROIfreesurfer-${FREE}.nii.gz
        done

fi

# inflate thalamus
if [[ -z ${thalamicROIs} ]]; then
	echo "no thalamic nuclei segmentation"
else
	3dROIMaker \
		-inset thalamicNuclei.nii.gz \
		-refset thalamicNuclei.nii.gz \
		-mask ${brainmask} \
		-wm_skel wm_anat.nii.gz \
		-skel_thr ${skel_thr} \
		${l1} \
		${l3} \
		-${neigh_def} \
                ${skel_stop} \
		-nifti \
		-overwrite;

	#generate rois
        THALROIS=`echo ${thalamicROIs} | cut -d',' --output-delimiter=$'\n' -f1-`
        for THAL in ${THALROIS}
        do
                3dcalc -a thalamus_inflate_GMI.nii.gz -expr 'equals(a,'${THAL}')' -prefix ROIthalamus-${THAL}.nii.gz
        done
fi

# inflate visual areas
if [[ -z ${prfROIs} ]]; then
        echo "no visual area inflation"
else
        3dROIMaker \
                -inset varea_dwi.nii.gz \
                -refset varea_dwi.nii.gz \
                -mask ${brainmask} \
                -wm_skel wm_anat.nii.gz \
                -skel_thr ${skel_thr} \
                ${l1} \
                ${l4} \
                -${neigh_def} \
                ${skel_stop} \
                -nifti \
                -overwrite;

	#generate rois
	PRFROIS=`echo ${prfROIs} | cut -d',' --output-delimiter=$'\n' -f1-`
        for VIS in ${PRFROIS}
        do
                3dcalc -a visarea_inflate_GMI.nii.gz -expr 'equals(a,'${VIS}')' -prefix ROIvarea${VIS}.nii.gz
        done
fi

if [[ -z ${subcorticalROIs} ]]; then
        echo "no subcortical rois"
else
        #generate rois
        SUBROIS=`echo ${subcorticalROIs} | cut -d',' --output-delimiter=$'\n' -f1-`
        for SUB in ${SUBROIS}
        do
                3dcalc -a ${inputparc}+aseg.nii.gz -expr 'equals(a,'${SUB}')' -prefix ROIsubcortical-${SUB}.nii.gz
        done
fi

# inflate thalamus
if [[ -z ${hippocampalROIs} ]]; then
	echo "no hippocampal subfield segmentation"
else
	3dROIMaker \
		-inset hippocampus.nii.gz \
		-refset hippocampus.nii.gz \
		-mask ${brainmask} \
		-wm_skel wm_anat.nii.gz \
		-skel_thr ${skel_thr} \
		${l1} \
		${l3} \
		-${neigh_def} \
		${skel_stop} \
		-nifti \
		-overwrite;

	#generate rois
        HIPPROIS=`echo ${hippocampalROIs} | cut -d',' --output-delimiter=$'\n' -f1-`
        for HIPP in ${HIPPROIS}
        do
                3dcalc -a hippocampus_inflate_GMI.nii.gz -expr 'equals(a,'${HIPP}')' -prefix ROIhippocampus-${HIPP}.nii.gz
        done
fi

# inflate thalamus
if [[ -z ${amygdalaROIs} ]]; then
	echo "no amgydala subfield segmentation"
else
	3dROIMaker \
		-inset amygdala.nii.gz \
		-refset amygdala.nii.gz \
		-mask ${brainmask} \
		-wm_skel wm_anat.nii.gz \
		-skel_thr ${skel_thr} \
		${l1} \
		${l3} \
		-${neigh_def} \
		${skel_stop} \
		-nifti \
		-overwrite;

	#generate rois
        AMYGROIS=`echo ${amygdalaROIs} | cut -d',' --output-delimiter=$'\n' -f1-`
        for AMYG in ${AMYGROIS}
        do
                3dcalc -a amygdala_inflate_GMI.nii.gz -expr 'equals(a,'${AMYG}')' -prefix ROIamygdala-${HIPP}.nii.gz
        done
fi

# create parcellation of all rois
3dcalc -a ${inputparc}+aseg.nii.gz -prefix zeroDataset.nii.gz -expr '0'
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
					mergeArrayL=$mergeArrayL" `echo ROI$j.nii.gz`"
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
				mergeArrayL="$mergeArrayL `echo ROI"$i".nii.gz`"
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
					mergeArrayR=$mergeArrayR" `echo ROI$j.nii.gz`"
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
				mergeArrayR="$mergeArrayR `echo ROI*"$i".nii.gz`"
			done
			
			3dTcat -prefix merge_preR.nii.gz zeroDataset.nii.gz `ls ${mergeArrayR}`
	        	3dTstat -argmax -prefix ${mergename}R_nonbyte.nii.gz merge_preR.nii.gz
	        	3dcalc -byte -a ${mergename}R_nonbyte.nii.gz -expr 'a' -prefix ${mergename}R_allbytes.nii.gz
	        	3dcalc -a ${mergename}R_allbytes.nii.gz -expr 'step(a)' -prefix ROI${mergename}_R.nii.gz
	        fi
	fi
fi



# create key.txt for parcellation
FILES=(`echo "*ROI*.nii.gz"`)
for i in "${!FILES[@]}"
do
	oldval=`echo "${FILES[$i]}" | sed 's/.*ROI\(.*\).nii.gz/\1/'`
	newval=$((i + 1))
	echo -e "1\t->\t${newval}\t== ${oldval}" >> key.txt

	# make tmp.json containing data for labels.json
	jsonstring=`jq --arg key0 'name' --arg value0 "${oldval}" --arg key1 "desc" --arg value1 "value of ${newval} indicates voxel belonging to ROI${oldval}" --arg key2 "voxel_value" --arg value2 ${newval} '. | .[$key0]=$value0 | .[$key1]=$value1 | .[$key2]=$value2' <<<'{}'`
	if [ ${#FILES[*]} -eq 1 ]; then
		echo -e "[\n${jsonstring}\n]" >> tmp.json
	else
		if [ ${newval} -eq 1 ]; then
			echo -e "[\n${jsonstring}," >> tmp.json
		elif [ ${newval} -eq ${#FILES[*]} ]; then
			echo -e "${jsonstring}\n]" >> tmp.json
		else
			echo -e "${jsonstring}," >> tmp.json
		fi
	fi
done

# pretty format label.json
jq '.' tmp.json > label.json

# clean up
if [ -f ./allrois_byte.nii.gz ]; then
	mkdir rois;
	mkdir rois/rois;
	mv allrois_byte.nii.gz ./parc/parc.nii.gz;
	mv key.txt ./parc/key.txt;
	mv label.json ./parc/label.json
	mv *ROI*.nii.gz ./rois/rois/;
	rm -rf *.nii.gz* *.niml.* tmp.json
fi
