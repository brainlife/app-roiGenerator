[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/soichih/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-bl.app.37-blue.svg)](https://doi.org/10.25663/bl.app.37)

# app-roiGenerator
This app will generate nifti files for specific ROIs, or every ROI, of a parcellation (either freesurfer or atlas). First, the user-specfied parcellation is converted to nifti and a white matter and brain mask are generated using Freesurfer by running the create_wm_mask script. Then, the ROIs are inflated by N voxels, and the white matter mask is removed from the parcellation, using AFNI's 3dROIMaker by running the roiInflate script. Finally, a nifti of the ROIs are generated using Vistasoft's dtiRoiNiftiFromMat function by running the roiGeneration script.

### Authors
- Brad Caron (bacaron@iu.edu)
- Ilaria Sani (isani01@rockefeller.edu)

### Contributors
- Soichi Hayashi (hayashi@iu.edu)
- Franco Pestilli (franpest@indiana.edu)

### Funding
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)

## Running the App 

### On Brainlife.io

You can submit this App online at [https://doi.org/10.25663/bl.app.37](https://doi.org/10.25663/bl.app.37) via the "Execute" tab.

### Running Locally (on your machine)

1. git clone this repo.
2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files.

```json
{
        "t1": "./input/t1/t1.nii.gz",
        "parc": "./input/parc/",
        "dtiinit": "./input/dtiinit/",
        "fsurfer": "./input/freesurfer/",
        "inflate": 1,
        "rois": "45,54" 
}
```

### Sample Datasets

You can download sample datasets from Brainlife using [Brainlife CLI](https://github.com/brain-life/cli).

```
npm install -g brainlife
bl login
mkdir input
bl dataset download 5b96bd23059cf900271924f8 && mv 5b96bd23059cf900271924f8 input/t1
bl dataset download 5b96bd26059cf900271924f9 && mv 5b96bd26059cf900271924f9 input/parc
bl dataset download 5b96bc8d059cf900271924f5 && mv 5b96bc8d059cf900271924f5 input/dtiinit
bl dataset download 5b96bc8f059cf900271924f6 && mv 5b96bc8f059cf900271924f6 input/freesurfer
```


3. Launch the App by executing `main`

```bash
./main
```

## Output

The main output of this App is a folder called "parc". This folder contains nifti images of each ROI requested, the inflated parcellation, and the original t1.

#### Product.json
The secondary output of this app is `product.json`. This file allows web interfaces, DB and API calls on the results of the processing. 

### Dependencies

This App requires the following libraries when run locally.

  - singularity: https://singularity.lbl.gov/
  - VISTASOFT: https://github.com/vistalab/vistasoft/
  - ENCODE: https://github.com/brain-life/encode
  - Freesurfer: https://hub.docker.com/r/brainlife/freesurfer/tags/6.0.0
  - AFNI: https://hub.docker.com/r/brainlife/afni/tags/16.3.0
  - jsonlab: https://github.com/fangq/jsonlab.git
