#!/bin/bash

#set -x

## This script uses AFNI's (Taylor PA, Saad ZS (2013).  FATCAT: (An Efficient) Functional And Tractographic Connectivity Analysis Toolbox. Brain 
## Connectivity 3(5):523-535. https://afni.nimh.nih.gov/) 3dROIMaker function to a) remove the white matter mask from the cortical segmentation 
## inputted (i.e. freesurfer or parcellation; BE CAREFUL: REMOVES SUBCORTICAL ROIS) and b) inflates the ROIs by n voxels into the white matter 
## based on user input (option for no inflation is also built in). The output of this will then passed into a matlab function (roiGeneration.m) to 
## create nifti's for each ROI requested by the user, which can then be fed into a ROI to ROI tracking app (brainlife.io; www.github.com/brain-life/
## app-roi2roitracking).

# bl config inputs
inputparc=`jq -r '.inputparc' config.json`
thalamusinflate=`jq -r '.thalamusInflate' config.json`
visInflate=`jq -r '.visInflate' config.json`
freesurferInflate=`jq -r '.freesurferInflate' config.json`
#subcorticalROIs=`jq -r '.subcorticalROIs' config.json`

# hard coded roi numbers for optic radiation tracking
brainmask=mask.nii.gz;
freesurferROIs="41 42 7 8 4 2 3 46 47 43 28 60"
subcorticalROIs="85"
visROIs="2 3 4 5 6 7 8 11 12 14 17 18 19 20 21 22 23 24 50 120 122 127 128 134 136 137 138 139 141 142 143 144 147 153 154 155 156 157 158 159 160 161 164 183 184 185 186 187 188 189 192 193 195 198 199 200 201 202 203 204 205 231 301 303 308 309 315 317 318 319 320 322 323 324 325 328 334 335 336 337 338 339 340 341 342 345"
visROINames="lh.v1 lh.mst lh.v6 lh.v2 lh.v3 lh.v4 lh.v8 lh.fef lh.pef lh.v3a lh.v7 lh.ips1 lh.ffc lh.v3b lh.lo1 lh.lo2 lh.pit lh.mt lh.mip lh.pres lh.pros lh.pha1 lh.pha3 lh.te1p lh.tf lh.te2p lh.pht lh.ph lh.tpoj2 lh.tpoj3 lh.dvt lh.pgp lh.ip0 lh.v6a lh.vmv1 lh.vmv3 lh.pha2 lh.v4t lh.fst lh.v3cd lh.lo3 lh.vmv2 lh.vvc rh.v1 rh.mst rh.v6 rh.v2 rh.v3 rh.v4 rh.v8 rh.fef rh.pef rh.v3a rh.v7 rh.ips1 rh.ffc rh.v3b rh.lo1 rh.lo2 rh.pit rh.mt rh.mip rh.pres rh.pros rh.pha1 rh.pha3 rh.te1p rh.tf rh.te2p rh.pht rh.ph rh.tpoj2 rh.tpoj3 rh.dvt rh.pgp rh.ip0 rh.v6a rh.vmv1 rh.vmv3 rh.pha2 rh.v4t rh.fst rh.v3cd rh.lo3 rh.vmv2 rh.vvc"
thalamicROIs="8109 8209"
mergeROIsL="41 42 7 8 4 28"
mergeROIsR="2 3 46 47 43 60"
mergeL=($mergeROIsL)
mergeR=($mergeROIsR)
mergename="exclusion"

mkdir parc rois rois/rois tmp;

# parse inflation if desired by user
if [[ ${freesurferInflate} == 'null' ]]; then
        echo "no freesurfer inflation";
        l5="-prefix ${inputparc}+aseg_inflate";
else
        echo "${fsurfInflate} voxel inflation applied to every freesurfer label";
        l5="-inflate ${fsurfInflate} -prefix ${inputparc}+aseg_inflate";
fi

if [[ ${thalamusinflate} == 'null' ]]; then
	echo "no thalamic inflation";
	l3="-prefix thalamus_inflate";
else
	echo "${thalamusinflate} voxel inflation applied to every thalamic label";
	l3="-inflate ${thalamusinflate} -prefix thalamus_inflate";
fi

if [[ ${visInflate} == 'null' ]]; then
        echo "no visual area inflation";
        l4="-prefix visarea_inflate";
else
        echo "${visInflate} voxel inflation applied to every visual area label";
        l4="-inflate ${visInflate} -prefix visarea_inflate";
fi

# stop inflation into white matter
l1="-skel_stop";

## Inflate freesurfer ROIs
if [[ -z ${freesurferROIs} ]]; then
	echo "no freesurfer inflation"
else
	3dROIMaker \
                -inset ${inputparc}+aseg.nii.gz \
                -refset ${inputparc}+aseg.nii.gz \
                -mask ${brainmask} \
                -wm_skel wm_anat.nii.gz \
                -skel_thr 0.5 \
                ${l1} \
                ${l5} \
                -nifti \
                -overwrite;
	
	#generate rois
        FREEROIS=`echo ${freesurferROIs} | cut -d',' --output-delimiter=$'\n' -f1-`
        for FREE in ${FREEROIS}
        do
                3dcalc -a ${inputparc}+aseg_inflate_GMI.nii.gz -expr 'equals(a,'${FREE}')' -prefix ROI0000${FREE}.nii.gz
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
		-skel_thr 0.5 \
		${l1} \
		${l3} \
		-nifti \
		-overwrite;

	#generate rois
        THALROIS=`echo ${thalamicROIs} | cut -d',' --output-delimiter=$'\n' -f1-`
        for THAL in ${THALROIS}
        do
                3dcalc -a thalamus_inflate_GMI.nii.gz -expr 'equals(a,'${THAL}')' -prefix ROI00${THAL}.nii.gz
        done
fi

# inflate visual areas
if [[ -z ${visROIs} ]]; then
        echo "no visual area inflation"
else
        3dROIMaker \
                -inset parc_dwi.nii.gz \
                -refset parc_dwi.nii.gz \
                -mask ${brainmask} \
                -wm_skel wm_anat.nii.gz \
                -skel_thr 0.5 \
                ${l1} \
                ${l4} \
                -nifti \
                -overwrite;

	#generate rois
	VISROIS=`echo ${visROIs} | cut -d',' --output-delimiter=$'\n' -f1-`
        for VIS in ${VISROIS}
        do
                3dcalc -a visarea_inflate_GMI.nii.gz -expr 'equals(a,'${VIS}')' -prefix ROI000${VIS}.nii.gz
        done
fi

if [[ -z ${subcorticalROIs} ]]; then
        echo "no subcortical rois"
else
        #generate rois
        SUBROIS=`echo ${subcorticalROIs} | cut -d',' --output-delimiter=$'\n' -f1-`
        for SUB in ${SUBROIS}
        do
                3dcalc -a ${inputparc}+aseg.nii.gz -expr 'equals(a,'${SUB}')' -prefix ROI0${SUB}.nii.gz
        done
fi

# rename rois
visROIs=($visROIs)
visROINames=($visROINames)
for ROIS in ${!visROIs[@]}
do
        mv ROI000${visROIs[$ROIS]}.nii.gz ROI${visROINames[$ROIS]}.nii.gz
done

mv ROI008109.nii.gz ROIlh.lgn.nii.gz
mv ROI008209.nii.gz ROIrh.lgn.nii.gz
mv ROI085.nii.gz ROIoptic-chiasm.nii.gz

# create empty roi to fill
3dcalc -a ${inputparc}+aseg.nii.gz -prefix zeroDataset.nii.gz -expr '0'

if [[ -z ${mergeROIsL} ]] || [[ -z ${mergeROIsR} ]]; then
        echo "no merging of rois"
else
        #merge rois
        if [[ ! -z ${mergeROIsL} ]]; then
                mergeArrayL=""
                for i in "${mergeL[@]}"
                do
                        mergeArrayL="$mergeArrayL `echo ROI*0"$i".nii.gz`"
                done
                
                3dTcat -prefix merge_preL.nii.gz zeroDataset.nii.gz `ls ${mergeArrayL}`
                3dTstat -argmax -prefix ${mergename}L_nonbyte.nii.gz merge_preL.nii.gz
                3dcalc -byte -a ${mergename}L_nonbyte.nii.gz -expr 'a' -prefix ${mergename}L_allbytes.nii.gz
                3dcalc -a ${mergename}L_allbytes.nii.gz -expr 'step(a)' -prefix ROIlh.${mergename}.nii.gz
                rm -rf ${mergename}L_nonbyte.nii.gz ${mergename}L_allbytes.nii.gz
                mv *`ls ${mergeArrayL}`* ./rois/rois/
        fi
        if [[ ! -z ${mergeROIsR} ]]; then
                mergeArrayR=""
                for i in "${mergeR[@]}"
                do
                        mergeArrayR="$mergeArrayR `echo ROI*0"$i".nii.gz`"
                done
                3dTcat -prefix merge_preR.nii.gz zeroDataset.nii.gz `ls ${mergeArrayR}`
                3dTstat -argmax -prefix ${mergename}R_nonbyte.nii.gz merge_preR.nii.gz
                3dcalc -byte -a ${mergename}R_nonbyte.nii.gz -expr 'a' -prefix ${mergename}R_allbytes.nii.gz
                3dcalc -a ${mergename}R_allbytes.nii.gz -expr 'step(a)' -prefix ROIrh.${mergename}.nii.gz
                rm -rf ${mergename}R_nonbyte.nii.gz ${mergename}R_allbytes.nii.gz
                mv *`ls ${mergeArrayR}`* ./rois/rois/
        fi
fi

# move exclusion files as to not include in parcellation (significant overlap)
mv *${mergename}*.nii.gz ./rois/rois/

# create parcellation of all rois
3dTcat -prefix all_pre.nii.gz zeroDataset.nii.gz *ROI*.nii.gz
3dTstat -argmax -prefix allroiss.nii.gz all_pre.nii.gz
3dcalc -byte -a allroiss.nii.gz -expr 'a' -prefix allrois_byte.nii.gz

# create key.txt for parcellation
FILES=(`echo "*ROI*.nii.gz"`)
for i in "${!FILES[@]}"
do
	oldval=`echo "${FILES[$i]}" | sed 's/.*ROI\(.*\).nii.gz/\1/'`
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

# clean up
if [ -f allrois_byte.nii.gz ]; then
        mv allrois_byte.nii.gz ./parc/parc.nii.gz;
        mv key.txt ./parc/key.txt;
        mv label.json ./parc/label.json
        mv *ROI*.nii.gz ./rois/rois/;
	mv ${inputparc}+aseg.nii.gz ./tmp/
        rm -rf *.nii.gz* *.niml.* tmp.json
fi

