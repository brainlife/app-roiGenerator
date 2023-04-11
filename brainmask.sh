#!/bin/bash

echo "Setting file paths"

# parse whether input is dtiinit or dwi
dwi=`jq -r '.dwi' config.json`;
bvals=`jq -r '.bvals' config.json`;
bvecs=`jq -r '.bvecs' config.json`;

echo "Files loaded"

# Create b0
select_dwi_vols \
	${dwi} \
	${bvals} \
	nodif.nii.gz \
	0;

# Brain extraction before alignment
bet nodif.nii.gz \
	nodif_brain \
	-f 0.3 \
	-g 0 \
	-m;

mv nodif_brain_mask.nii.gz mask.nii.gz;

echo "brainmask creation complete"
