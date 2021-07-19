#!/bin/bash

echo "Setting file paths"

# parse inputs
fmri=`jq -r '.fmri' config.json`;

echo "Files loaded"

# Brain extraction before alignment
bet ${fmri} \
	brain \
	-f 0.3 \
	-g 0 \
	-F \
	-m;
  
mv brain_mask.nii.gz mask.nii.gz;

echo "brainmask creation complete"
