#!/bin/bash

export SUBJECTS_DIR=./
dwi=`jq -r '.dwi' config.json`

[ ! -d tmp ] && mkdir tmp
tmpdir="./tmp"

mv ./rois/rois/*.nii.gz ${tmpdir}/
files=`find ${tmpdir}/*.nii.gz`

for i in ${files}
do
	echo "reslicing `echo ${i} | grep -Po '(?<=(./rois/rois/)).*(?=.nii.gz)'` to diffusion space"
	mri_vol2vol --mov ${i} --targ ${dwi} --regheader --interp nearest --o ./rois/rois/${i##./tmp/}
done

rm -rf ${tmpdir}

mv ./parc/parc.nii.gz ./
mri_vol2vol --mov parc.nii.gz --targ ${dwi} --regheader --interp nearest --o ./parc/parc.nii.gz
