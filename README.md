# app-roiGenerator
This app will generate nifti files for specific ROIs, or every ROI, for a parcellation (either freesurfer or atlas).

## Output

For every measure (i.e. tensors: AD, FA, MD, RD; nod: ICVF, ISOVF, OD), you’ll have two outputs (i.e. _1, _2). ‘_1’ corresponds to the tract profile values for each node, while ‘_2’ corresponds to the standard deviation for each node.

For every measure, there’s also the inverse values (i.e. I took the measure maps, inverted the data, ran them through the profile generation code). We added the inverse measures because we were trying to replicate some papers that looked at relationships between NODDI measures and inverse tensor measures.


