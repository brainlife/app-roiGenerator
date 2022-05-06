#!/bin/bash

echo "Setting file paths"

# parse whether input is dtiinit or dwi
fmri=`jq -r '.bold' config.json

echo "Files loaded"

# select first volume
fslselectvols -i ${fmri} -o nodif.nii.gz --vols=0

# Brain extraction before alignment
bet nodif.nii.gz \
	nodif_brain \
	-f 0.3 \
	-g 0 \
	-m;

mv nodif_brain_mask.nii.gz mask.nii.gz;

echo "brainmask creation complete"
