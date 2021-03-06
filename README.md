[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-bl.app.223-blue.svg)](https://doi.org/10.25663/brainlife.app.223)

# app-roiGenerator
This app will generate region-of-interest (ROI) niftis from either a Freesurfer parcellation or another parcellation. This app will use AFNI to inflate parcellations and VISTASOFT to extract inputted ROIs and create ROI niftis. The inputs are: T1, DTIINIT, Freesurfer, parcellation (optional). The outputs are: parcellation (inflated), rois (niftis).

### Authors
- Brad Caron (bacaron@iu.edu)

### Contributors
- Soichi Hayashi (hayashi@iu.edu)
- Franco Pestilli (franpest@indiana.edu)

### Funding
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)

### Citations 

Please cite the following articles when publishing papers that used data, code or other resources created by the brainlife.io community. 

1. Taylor PA, Saad ZS (2013). FATCAT: (An Efficient) Functional And Tractographic Connectivity Analysis Toolbox. Brain Connectivity 3(5):523-535.

## Running the App 

### On Brainlife.io

You can submit this App online at [https://doi.org/10.25663/brainlife.app.223](https://doi.org/10.25663/brainlife.app.223) via the "Execute" tab.

### Running Locally (on your machine)

1. git clone this repo.
2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files.

```json
{
	"dwi":	"test/data/dwi/dwi.nii.gz",
	"bvals":	"test/data/dwi/dwi.bvals",
	"bvecs":	"test/data/dwi/dwi.bvecs",
	"t1":	"test/data/anat/t1.nii.gz",
	"freesurfer":	"test/data/freesurfer",
	"ROI":	"11101,11102",
	"inputparc":	"aparc.a2009s",
        "parcellation": "",
	"subcortical":	false
}

```

### Sample Datasets

You can download sample datasets from Brainlife using [Brainlife CLI](https://github.com/brain-life/cli).

```
npm install -g brainlife
bl login
mkdir input
bl dataset download 5b96bbbf059cf900271924f2 && mv 5b96bbbf059cf900271924f2 input/t1
bl dataset download 5c45e58c287fa00144a33567 && mv 5c45e58c287fa00144a33567 input/dwi
bl dataset download 5967bffa9b45c212bbec8958 && mv 5967bffa9b45c212bbec8958 input/freesurfer

```


3. Launch the App by executing `main`

```bash
./main
```

## Output

The main outputs of this App are an inflated parcellation datatype and an roi (niftis) datatype.

#### Product.json
The secondary output of this app is `product.json`. This file allows web interfaces, DB and API calls on the results of the processing. 

### Dependencies

This App requires the following libraries when run locally.

  - singularity: https://singularity.lbl.gov/
  - VISTASOFT: https://github.com/vistalab/vistasoft/
  - SPM 8: https://www.fil.ion.ucl.ac.uk/spm/software/spm8/
  - Freesurfer: https://hub.docker.com/r/brainlife/freesurfer/tags/6.0.0
  - AFNI: https://hub.docker.com/r/brainlife/afni/tags/16.3.0
  - jsonlab: https://github.com/fangq/jsonlab.git

