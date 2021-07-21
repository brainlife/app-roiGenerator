#!/bin/bash

echo "Setting file paths"

# parse inputs
anat=`jq -r '.t1' config.json`;

echo "Files loaded"

# Brain extraction before alignment
bet ${anat} \
	brain \
	-f 0.3 \
	-g 0 \
	-R \
	-m;
  
mv brain_mask.nii.gz mask.nii.gz;

echo "brainmask creation complete"
