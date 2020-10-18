[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-brainlife.app.242-blue.svg)](https://doi.org/10.25663/brainlife.app.242)

# Generate ROIs in DMRI Space 

This app will generate regions-of-interest (ROIs) in dMRI space. This app is intended to be used in combination with apps that require the ROIs to have the same dimensions as the dMRI image including ROI to ROI tracking apps and the 'Extract diffusion metrics inside ROIs' app. This app takes in the following required inputs: DWI, Freesurfer. Optionally, this app can take any parcellation/volume datatype, pRF visual area segmentation, and can process individual thalamic nuclei segmented using Freesurfer. This app outputs a rois datatype containing the individual NIFTIs for each ROI requested and a parcellation/volume datatype containing a combined parcellation of the individual ROIs. This app uses AFNI's 3dROIMaker functionality.

In order to extract a specific ROI, the user must input the index number of that specific ROI. This information can be found in the respective LUTs or key.txt files. Before running, it is recommended that the user identifies the specific LUT or key.txt file and identify the appropriate ROI index. The ROI numbers must be inputted into the specific input type ROIs field. For example, if a user wanted to generate a ROI from Freesurfer's aparc.a2009s parcellation of the Left Middle Frontal gyrus, the user should input 11115 in the freesurferROIs field. The user should also specify the aparc.a2009s as the 'inputparc'. If a user wanted to also generate a ROI of the Left Caudate from the aseg provided by Freesurfer, the user should input 11 in the subcorticalROIs field. If multiple ROIs are requested, the user can input each ROI number separated by a space in the respective ROI field.

This app also allows the user to merge ROIs together. For example, if a user wanted to merge the Left Middle Frontal gyrus and Left Superior Frontal gyrus from Freesurfer, the user would input 11115 11116 in both the Freesurfer ROIs and the mergeROIsL fields. The user can then specify what the output name of the ROI will be (example: mid_sup_frontal_gyrus).

Finally, this app can inflate the ROIs into the white matter using AFNI's functionality. To inflate the Left Middle Frontal gyrus by 1 voxel in each x,y,z direction, the user should specify 1 in the freesurferInflate field. The app can use a white matter mask to guide inflation by selecting the 'whitematter' boolean field. If the user does not want the inflation to be limited by the white matter, set this field to false. However, note this may cause some ROIs not to be generated and could cause the app to fail.

Please look at the app details regarding formatting of ROI inputs and for an explanation of the ROI output numbering system.  

### Authors 

- Brad Caron (bacaron@iu.edu)
- Ilaria Sani (isani01@rockefeller.edu) 

### Contributors 

- Soichi Hayashi (hayashis@iu.edu) 

### Funding 

[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-ACI-1916518](https://img.shields.io/badge/NSF_ACI-1916518-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1916518)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://grantome.com/grant/NIH/R01-EB029272-01)

### Citations 

Please cite the following articles when publishing papers that used data, code or other resources created by the brainlife.io community. 

1. Taylor PA, Saad ZS (2013).  FATCAT: (An Efficient) Functional And Tractographic Connectivity Analysis Toolbox. Brain Connectivity 3(5):523-535. 

## Running the App 

### On Brainlife.io 

You can submit this App online at [https://doi.org/10.25663/brainlife.app.242](https://doi.org/10.25663/brainlife.app.242) via the 'Execute' tab. 

### Running Locally (on your machine) 

1. git clone this repo 

2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files. 

```json 
{
   "dwi":    "testdata/dwi/dwi.nii.gz",
   "bvals":    "testdata/dwi/dwi.bvals",
   "bvecs":    "tesdata/dwi/dwi.bvecs",
   "freesurfer":    "testdata/freesurfer/output/",
   "parcellationROIs":    "null",
   "subcorticalROIs":    "12",
   "thalamicROIs":    "null",
   "prfROIs":    "null",
   "freesurferROIs":    "11115",
   "mergeROIsL":    "null",
   "mergeROIsR":    "null",
   "mergename":    "null",
   "parcInflate":    "null",
   "thalamusInflate":    "null",
   "visInflate":    "null",
   "freesurferInflate":    "null",
   "inputparc":    "aparc.a2009s",
   "whitematter":    true
} 
``` 

### Sample Datasets 

You can download sample datasets from Brainlife using [Brainlife CLI](https://github.com/brain-life/cli). 

```
npm install -g brainlife 
bl login 
mkdir input 
bl dataset download 
``` 

3. Launch the App by executing 'main' 

```bash 
./main 
``` 

## Output 

The main output of this App is contains a directory containing all of the ROI NIFTI images and a parcellation datatype with all of the ROIs in a single NIFTI image. Parcellation ROIs will have outputs with the name ROI<ROI #>.nii.gz. Freesurfer subcortical ROIs will have outputs with the name ROI0<ROI #>. Thalamic ROIs will have outputs with the name ROI00<ROI #>. Visual Areas ROIs will have outputs with the name ROI000<ROI #>. Freesurfer cortical ROIs will have outputs with the name ROI0000<ROI #>. 

#### Product.json 

The secondary output of this app is `product.json`. This file allows web interfaces, DB and API calls on the results of the processing. 

### Dependencies 

This App requires the following libraries when run locally. 

- AFNI: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/install_instructs/index.html
- FSL: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation
- Freesurfer: https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall
- jsonlab: https://github.com/fangq/jsonlab
- singularity: https://singularity.lbl.gov/quickstart
