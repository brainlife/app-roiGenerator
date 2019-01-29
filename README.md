[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-bl.app.37-blue.svg)](https://doi.org/10.25663/bl.app.37)

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

## Running the App 

### On Brainlife.io

You can submit this App online at [https://doi.org/10.25663/bl.app.53](https://doi.org/10.25663/bl.app.37) via the "Execute" tab.

### Running Locally (on your machine)

1. git clone this repo.
2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files.

```json
{
        "t1": "./input/t1/t1.nii.gz",
        "dtiinit": "./input/dtiinit/.",
        "freesurfer": "./input/freesurfer/output",
        "parcellation": "",
        "key":  "",
        "ROI":  "45,54",
        "inflate":  5,
}
```

### Sample Datasets

You can download sample datasets from Brainlife using [Brainlife CLI](https://github.com/brain-life/cli).

```
npm install -g brainlife
bl login
mkdir input
bl dataset download 5b96bbbf059cf900271924f2 && mv 5b96bbbf059cf900271924f2 input/t1
bl dataset download 5c45e58c287fa00144a33567 && mv 5c45e58c287fa00144a33567 input/dtiinit
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

