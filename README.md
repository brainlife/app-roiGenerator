<h1 align="center">ROI Generator</h1>

<p align="center">
  Regions of interest and volumetric parcellations in diffusion, functional or anatomical space, from FreeSurfer, other parcellations and pRF visual-field maps.
</p>

<p align="center">
  <a href="https://github.com/brainlife/abcd-spec"><img src="https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg" alt="ABCD Spec v1.1"></a>
  <a href="https://doi.org/10.25663/brainlife.app.591"><img src="https://img.shields.io/badge/Brainlife-brainlife.app.591-blue.svg" alt="Run on brainlife.io"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="MIT license"></a>
</p>

> **This branch, `merge-dwi-v1.4-fa`, is the brainlife.io App Generate ROIs in DMRI Space with FA Skeleton mask** ([doi:10.25663/brainlife.app.591](https://doi.org/10.25663/brainlife.app.591)). The other Apps in this repository are listed under **Versions on brainlife.io** below.

## At a glance

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **Generates ROIs in DWI space from FreeSurfer labels, an optional volume parcellation and pRF visual areas, inflating them toward white matter with AFNI 3dROIMaker guided by a FA skeleton mask.**

Converts the requested labels from a FreeSurfer output (aparc/aseg, thalamic nuclei, hippocampal subfields, amygdala), an optional volume parcellation and an optional pRF visual-area segmentation into DWI space, writes each as a binary ROI, optionally merges ROIs and inflates them into white matter with AFNI 3dROIMaker, and combines them into a parcellation. ROIs are chosen by label number in the *ROIs parameters. Inflation is limited by an FA map used as the white matter skeleton (threshold skel_thr). Use it to prepare ROIs for ROI-to-ROI tracking or diffusion metric extraction on the DWI grid; a brain mask is computed from the DWI with FSL bet unless one is supplied.

| | |
|---|---|
| **Inputs** | `neuro/dwi` · `neuro/freesurfer` · `neuro/parcellation/volume` (optional) · `neuro/mask` (optional) · `neuro/prf` (optional) · `neuro/tensor` |
| **Outputs** | `neuro/parcellation/volume` · `neuro/rois` |
| **Container** | `brainlife/fsl:5.0.9` |
| **Resources** | 1 CPUs · 16 GB memory · 1 h walltime |
| **Requires** | `FREESURFER_LICENSE` |
| **Run it** | [doi.org/10.25663/brainlife.app.591](https://doi.org/10.25663/brainlife.app.591) |

#### Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `dwi` | `neuro/dwi` | yes | The path to the DWI datatype |
| `freesurfer` | `neuro/freesurfer` | yes | The path to the top directory containing the output from freesurfer. If you want thalamic ROIs, make sure to use the output from app-segment-thalamic-nuclei |
| `parcellation` | `neuro/parcellation/volume` | no | The non-freesurfer parcellation to make ROIs from (optional). |
| `mask` | `neuro/mask` (brain, dwi) | no | Specify this if you want to use your custom brainmask. If neither dtiinit nor brainmask is specified, this App will create brainmask from your dwi input using FSL bet. |
| `prf` | `neuro/prf` | no | Specify prf input if you want to generate ROIs from the PRF/varea parcellation. |
| `fa` | `neuro/tensor` | yes | Tensor dataset whose FA map is used as the white matter skeleton (wm_skel) that limits ROI inflation. |

#### Outputs

| Output | Datatype | Description |
|---|---|---|
| `parc` | `neuro/parcellation/volume` | The parcellation containing all of the ROIs in a single nifti |
| `rois` | `neuro/rois` | The directory containing all of the ROIs |

<details>
<summary><b>Parameters</b> (20)</summary>

| Parameter | Type | Default | Description |
|---|---|---|---|
| `parcellationROIs` | string |  | If a non-freesurfer parcellation is used, enter ROI numbers from key.txt (parcellation) ROIs wanted. Example: 45,54 ROIs will be outputted with following name format to avoid complications with other parcellations and similar ROI numbers: ROIparc-#.nii.gz, with # being the number of the ROI |
| `subcorticalROIs` | string |  | Enter the number of the subcortical ROI (if wanted). ROIs will be outputted with following name format to avoid complications with other parcellations and similar ROI numbers: ROIsubcortical#.nii.gz, with # being the number of the ROI. |
| `thalamicROIs` | string |  | If thalamic nuclei segmentation from freesurfer is used, enter the number of the thalamic ROI (if wanted). Please refer to this color lut (https://github.com/freesurfer/freesurfer/blob/dev/ThalamicNuclei/compressionLookupTable.txt) and your thalamic segmentation for specific ROI numbers ROIs will be outputted with following name format to avoid complications with other parcellations and similar ROI numbers: ROIthalamus-#.nii.gz, with # being the number of the ROI. |
| `hippocampalROIs` | string |  | If hippocampal segmentation from freesurfer is used, enter the number of the hippocampusROI (if wanted). Please refer to this color lut (https://github.com/freesurfer/freesurfer/blob/dev/ThalamicNuclei/compressionLookupTable.txt) and your hippocampal segmentation for specific ROI numbers ROIs will be outputted with following name format to avoid complications with other parcellations and similar ROI numbers: ROIhippocampus-#.nii.gz, with # being the number of the ROI. |
| `amygdalaROIs` | string |  | If amygdala segmentation from freesurfer is used, enter the number of the amygdala ROI (if wanted). Please refer to this color lut (https://github.com/freesurfer/freesurfer/blob/dev/ThalamicNuclei/compressionLookupTable.txt) and your amygdala segmentation for specific ROI numbers ROIs will be outputted with following name format to avoid complications with other parcellations and similar ROI numbers: ROIamygdala-#.nii.gz, with # being the number of the ROI. |
| `prfROIs` | string |  | If a visual area segmentation from a PRF mapping app is used, enter the number of the visual field ROI (if wanted). Please refer to visual area segmentation from the PRF to determine ROI numbers. ROIs will be outputted with following name format to avoid complications with other parcellations and similar ROI numbers: ROIvarea-#.nii.gz, with # being the number of the ROI. |
| `freesurferROIs` | string |  | If ROIs from the freesurfer segmentation is desired, enter the number of the ROI from the freesurfer colorLUT. ROIs will be outputted with following name format to avoid complications with other parcellations and similar ROI numbers: ROIfreesurfer-#.nii.gz, with # being the number of the ROI. |
| `mergeROIsL` | string |  | Left hemisphere ROI numbers and source parcellation you would like to merge into a single ROI Due to the possibility of different parcellations including the same set of labels, you must specify the source location using the following list of prefixes, followed by the roi number: freesurfer: freesurfer-# parcellation: parc-# subcortical: subcortical-# prf visual areas: varea-# amygdala: amygdala-# hippocampus: hippocampus-# thalamus: thalamus-# if the user wants to merge multiple ROIs made from subset of all ROIs, enter each set of ROIs on a new line. the mergename field will need to correspond to these pairings (i.e. same number of pairings per left and right hemisphere, same order) ex. freesurfer-11111 freesurfer-111112 freesurfer-11113 freesurfer-11114 freesurfer-11115 |
| `mergeROIsR` | string |  | Right hemisphere ROI numbers and source parcellation you would like to merge into a single ROI. Due to the possibility of different parcellations including the same set of labels, you must specify the source location using the following list of prefixes, followed by the roi number: freesurfer: freesurfer-# parcellation: parc-# subcortical: subcortical-# prf visual areas: varea-# amygdala: amygdala-# hippocampus: hippocampus-# thalamus: thalamus-# if the user wants to merge multiple ROIs made from subset of all ROIs, enter each set of ROIs on a new line. the mergename field will need to correspond to these pairings (i.e. same number of pairings per left and right hemisphere, same order) ex. freesurfer-12111 freesurfer-121112 freesurfer-12113 freesurfer-12114 freesurfer-12115 |
| `mergename` | string |  | Name for the ROI that you would like merged. The output will be in the following format: ROI${mergename}.nii.gz if the user wants to merge multiple ROIs made from subset of all ROIs, enter each name on a line. this field will need to correspond to these pairings (i.e. same number of pairings per left and right hemisphere, same order) ex. test1 test2 |
| `parcInflate` | number |  | if parcellation ROI inflation into WM is wanted, specify the number of inflated voxels desired example: 1 |
| `thalamusInflate` | number |  | if ROI inflation into WM for thalamus segmentation is wanted, specify the number of inflated voxels desired example: 1 |
| `hippocampusInflate` | string |  | if ROI inflation into WM for hippocampal subfield segmentation is wanted, specify the number of inflated voxels desired example: 1 |
| `amygdalaInflate` | string |  | if ROI inflation into WM for amygdala segmentation is wanted, specify the number of inflated voxels desired example: 1 |
| `visInflate` | number |  | if ROI inflation into WM for visual area segmentation is wanted, specify the number of inflated voxels desired example: 1 |
| `freesurferInflate` | number |  | if ROI inflation into WM for freesurfer segmentation is wanted, specify the number of inflated voxels desired example: 1 |
| `inputparc` | enum | `aparc` | The input freesurfer parcellation Options: `aparc`, `aparc.a2009s`, `aparc.DKTatlas`. |
| `skel_stop` | enum | `skel_stop` | Determine how little inflation into white matter is performed Options: `skel_stop`, `skel_stop_strict`, `no_stop`. |
| `skel_thr` | number | `0.2` | Threshold for FA white matter skeleton |
| `neigh_def` | enum | `neigh_face_only` | Determines how neighbor voxels are defined Options: `neigh_face_only`, `neigh_face_edge`, `neigh_upto_vert`. |

</details>

<!-- brainlife-app:end -->

## Versions on brainlife.io

This repository hosts a family of related Apps, each built from its own branch. The current Apps fall into four groups:

- **ROIs in a target space** (*Generate ROIs in DMRI Space with FA/WM Skeleton mask*, *in FMRI Space*, *in Anatomical Space*): extract ROIs from FreeSurfer labels (cortical parcellation, `aseg`, thalamic, hippocampal and amygdala nuclei), an optional volumetric parcellation and pRF visual areas, optionally merge them and inflate them into the white matter with AFNI `3dROIMaker`.
- **Visual white matter ROIs** (*Generate ROIs for Visual White Matter Tracking…*, *Generate Visual Regions of Interest Binned by Eccentricity Estimates…*): V1 and other visual areas from a pRF/Benson or Glasser segmentation, optionally binned by eccentricity, plus LGN, optic chiasm and FreeSurfer exclusion ROIs, in diffusion, fMRI or FreeSurfer space, for optic radiation and visual white matter tracking.
- **pRF parcellations** (*Generate Polar Angle/Eccentricity Parcellations from pRF - Diffusion Space*, *Generate Eccentricity Parcellations from Visual ROIs*): bin a pRF polar-angle or eccentricity map into user-defined ranges and project the bins into the cortical ribbon as a volumetric parcellation.
- **Utilities** (*Generate Parcellation (Volume) from ROIs*, *Merge multiple ROIs together using AFNI*).

| App | Branch | Run it | Status |
|---|---|---|---|
| Generate Polar Angle Parcellations from pRF - Diffusion Space | [`polar-angle-parcellation-v1.3`](https://github.com/brainlife/app-roiGenerator/tree/polar-angle-parcellation-v1.3) | [doi:10.25663/brainlife.app.762](https://doi.org/10.25663/brainlife.app.762) | current |
| Generate Eccentricity Parcellations from pRF - Diffusion Space | [`eccentricity-parcellation-v1.3`](https://github.com/brainlife/app-roiGenerator/tree/eccentricity-parcellation-v1.3) | [doi:10.25663/brainlife.app.713](https://doi.org/10.25663/brainlife.app.713) | current |
| Merge multiple ROIs together using AFNI | [`merge-rois-v1.1`](https://github.com/brainlife/app-roiGenerator/tree/merge-rois-v1.1) | [doi:10.25663/brainlife.app.710](https://doi.org/10.25663/brainlife.app.710) | current |
| Generate Visual Regions of Interest Binned by Eccentricity Estimates (Benson Atlas) - fMRI Space | [`visual-white-matter-eccentricity-fmri-v1.1`](https://github.com/brainlife/app-roiGenerator/tree/visual-white-matter-eccentricity-fmri-v1.1) | [doi:10.25663/brainlife.app.624](https://doi.org/10.25663/brainlife.app.624) | current |
| Generate ROIs in DMRI Space with WM Skeleton mask | [`merge-dwi-v1.4-wm`](https://github.com/brainlife/app-roiGenerator/tree/merge-dwi-v1.4-wm) | [doi:10.25663/brainlife.app.592](https://doi.org/10.25663/brainlife.app.592) | current |
| **Generate ROIs in DMRI Space with FA Skeleton mask** (this branch) | [`merge-dwi-v1.4-fa`](https://github.com/brainlife/app-roiGenerator/tree/merge-dwi-v1.4-fa) | [doi:10.25663/brainlife.app.591](https://doi.org/10.25663/brainlife.app.591) | current |
| Generate ROIs in Anatomical Space | [`merge-t1-v1.0`](https://github.com/brainlife/app-roiGenerator/tree/merge-t1-v1.0) | [doi:10.25663/brainlife.app.549](https://doi.org/10.25663/brainlife.app.549) | current |
| Generate ROIs in FMRI Space | [`merge-fmri-v1.0`](https://github.com/brainlife/app-roiGenerator/tree/merge-fmri-v1.0) | [doi:10.25663/brainlife.app.546](https://doi.org/10.25663/brainlife.app.546) | current |
| Generate Parcellation (Volume) from ROIs | [`parcellation-generation-v1.0`](https://github.com/brainlife/app-roiGenerator/tree/parcellation-generation-v1.0) | [doi:10.25663/brainlife.app.453](https://doi.org/10.25663/brainlife.app.453) | current |
| Generate Visual Regions of Interest Binned by Eccentricity Estimates (Benson Atlas) - Freesurfer Space | [`visual-white-matter-eccentricity-t1-v1.2`](https://github.com/brainlife/app-roiGenerator/tree/visual-white-matter-eccentricity-t1-v1.2) | [doi:10.25663/brainlife.app.441](https://doi.org/10.25663/brainlife.app.441) | current |
| Generate ROIs for Visual White Matter Analysis in Freesurfer Space (Benson pRF) | [`visual-white-matter-t1space-v1.1`](https://github.com/brainlife/app-roiGenerator/tree/visual-white-matter-t1space-v1.1) | [doi:10.25663/brainlife.app.440](https://doi.org/10.25663/brainlife.app.440) | current |
| Generate Eccentricity Parcellations from Visual ROIs | [`eccentricity-parcellation-v1.2`](https://github.com/brainlife/app-roiGenerator/tree/eccentricity-parcellation-v1.2) | [doi:10.25663/brainlife.app.417](https://doi.org/10.25663/brainlife.app.417) | current |
| Generate Visual Regions of Interest Binned by Eccentricity Estimates (Benson Atlas) - Diffusion Space | [`visual-white-matter-eccentricity-dwi-v1.2`](https://github.com/brainlife/app-roiGenerator/tree/visual-white-matter-eccentricity-dwi-v1.2) | [doi:10.25663/brainlife.app.414](https://doi.org/10.25663/brainlife.app.414) | current |
| Generate ROIs for Visual White Matter Tracking in dMRI Space (Glasser Parcellation) | [`visual-white-matter-glasser-dwi-v1.2`](https://github.com/brainlife/app-roiGenerator/tree/visual-white-matter-glasser-dwi-v1.2) | [doi:10.25663/brainlife.app.411](https://doi.org/10.25663/brainlife.app.411) | current |
| Generate ROIs for Visual White Matter Tracking in dMRI Space (Benson pRF) | [`visual-white-matter-dwi-v1.2`](https://github.com/brainlife/app-roiGenerator/tree/visual-white-matter-dwi-v1.2) | [doi:10.25663/brainlife.app.349](https://doi.org/10.25663/brainlife.app.349) | current |
| Generate ROIs for Visual White Matter Tracking in dMRI Space (Glasser Parcellation) Binned by prf Eccentricity Estimates - Deprecated Surface | [`visual-white-matter-eccentricity-glasser-v1.0`](https://github.com/brainlife/app-roiGenerator/tree/visual-white-matter-eccentricity-glasser-v1.0) | [doi:10.25663/brainlife.app.413](https://doi.org/10.25663/brainlife.app.413) | deprecated |
| Generate ROIs in DMRI Space (dtiinit) | [`merge-dwi`](https://github.com/brainlife/app-roiGenerator/tree/merge-dwi) | [doi:10.25663/brainlife.app.342](https://doi.org/10.25663/brainlife.app.342) | deprecated |
| ROI Generation (merge) - dtiInit | [`master`](https://github.com/brainlife/app-roiGenerator/tree/master) | [doi:10.25663/brainlife.app.334](https://doi.org/10.25663/brainlife.app.334) | deprecated |
| Generate ROIs in DMRI Space | [`merge-dwi-v1.3`](https://github.com/brainlife/app-roiGenerator/tree/merge-dwi-v1.3) | [doi:10.25663/brainlife.app.242](https://doi.org/10.25663/brainlife.app.242) | deprecated |
| ROI Generation (no merge) | [`pre_merge`](https://github.com/brainlife/app-roiGenerator/tree/pre_merge) | [doi:10.25663/brainlife.app.235](https://doi.org/10.25663/brainlife.app.235) | deprecated |
| ROI Generation (thalamic nuclei) | [`subthalamic`](https://github.com/brainlife/app-roiGenerator/tree/subthalamic) | [doi:10.25663/brainlife.app.223](https://doi.org/10.25663/brainlife.app.223) | deprecated |
| ROI Generation (old) | [`non_dtiinit`](https://github.com/brainlife/app-roiGenerator/tree/non_dtiinit) | [doi:10.25663/brainlife.app.154](https://doi.org/10.25663/brainlife.app.154) | deprecated |
| ROI Generation (w/ dtiinit) | [`1.0`](https://github.com/brainlife/app-roiGenerator/tree/1.0) | [doi:10.25663/bl.app.37](https://doi.org/10.25663/bl.app.37) | deprecated |

## Running the App

### On brainlife.io

Pick the App for your target space and inputs from the table above, choose the inputs from your project, set the ROIs and press **Execute**. Most Apps need a FreeSurfer output and a FreeSurfer license; the outputs are a `neuro/rois` dataset (one NIfTI per ROI) and/or a `neuro/parcellation/volume` dataset combining them.

**Generate ROIs in dMRI, fMRI or anatomical space.** These Apps produce ROIs with the same dimensions as the target image, for use with ROI-to-ROI tracking Apps and the *Extract diffusion metrics inside ROIs* App. To extract a specific ROI, enter its index number from the relevant lookup table or `key.txt` in the matching field. For example, for the left middle frontal gyrus of FreeSurfer's `aparc.a2009s` parcellation, enter `11115` in `freesurferROIs` and set `inputparc` to `aparc.a2009s`; for the left caudate from the FreeSurfer `aseg`, enter `11` in `subcorticalROIs`. Separate multiple ROIs with spaces.

- **Merging.** To merge ROIs, list them in both the ROI field and `mergeROIsL` (or `mergeROIsR`), and set the output name in `mergename`; for example `11115 11116` in `freesurferROIs` and `mergeROIsL`, with `mergename` `mid_sup_frontal_gyrus`.
- **Inflation.** To inflate an ROI into the white matter, give the number of voxels in each x, y, z direction in the matching `*Inflate` field (for example `1` in `freesurferInflate`). `whitematter` limits inflation to a white-matter mask; turning it off may cause some ROIs not to be generated and the App to fail. The skeleton-mask variants guide inflation with an FA skeleton (`skel_thr`, default 0.2) or a white-matter skeleton.

**pRF polar angle and eccentricity parcellations** ([doi:10.25663/brainlife.app.762](https://doi.org/10.25663/brainlife.app.762), [doi:10.25663/brainlife.app.713](https://doi.org/10.25663/brainlife.app.713)). Choose a FreeSurfer output, a `neuro/prf` dataset and the DWI that defines the output grid, and set the bins as space-separated lower and upper bounds in `min_degree` and `max_degree`. The App bins the pRF surface map, projects each bin into the cortical ribbon with FreeSurfer and Connectome Workbench, and combines the bins into one parcellation with FSL.

### Locally

You need [Singularity/Apptainer](https://apptainer.org/), [`jq`](https://jqlang.github.io/jq/) and, for most Apps, a [FreeSurfer license](https://surfer.nmr.mgh.harvard.edu/registration.html). FreeSurfer, FSL, AFNI 16.3.0 and Connectome Workbench run inside containers.

1. Clone this repository and check out the branch of the App you want (for example `git checkout polar-angle-parcellation-v1.3`).
2. Create `config.json` with the paths to your inputs and the options you want. For the polar angle parcellation App:

   ```json
   {
       "freesurfer": "/input/freesurfer/output",
       "prfSurfacesDir": "/input/prf/prf_surfaces",
       "prfVerticesDir": "/input/prf/prf_verts",
       "dwi": "/input/dwi/dwi.nii.gz",
       "inputparc": "aparc.a2009s",
       "min_degree": "<space-separated lower bounds, degrees>",
       "max_degree": "<space-separated upper bounds, degrees>"
   }
   ```

   Each branch reads the keys of its own App; see the `jq` calls in that branch's scripts.

3. Export your license and run the App:

   ```bash
   export FREESURFER_LICENSE="$(cat ~/freesurfer/license.txt)"
   ./main
   ```

### Sample data

Download sample datasets from brainlife.io with the [brainlife CLI](https://github.com/brainlife/cli):

```bash
npm install -g brainlife
bl login
mkdir input
bl dataset download 5b96bbbf059cf900271924f2 && mv 5b96bbbf059cf900271924f2 input/t1
bl dataset download 5c45e58c287fa00144a33567 && mv 5c45e58c287fa00144a33567 input/dwi
bl dataset download 5967bffa9b45c212bbec8958 && mv 5967bffa9b45c212bbec8958 input/freesurfer
```

## Outputs

```text
rois/rois/           one NIfTI per requested ROI (ROI-generation Apps)
parc/
├── parc.nii.gz      volumetric parcellation combining the ROIs or bins
├── label.json       label names and voxel values
└── key.txt          mapping from original to new voxel values
```

## Troubleshooting

- **`ROI files missing.`**: no ROI was written. Check the ROI index numbers against the lookup table of the chosen `inputparc`, and that the FreeSurfer output contains the segmentations requested (for example thalamic nuclei for the LGN).
- **ROIs missing after inflation**: with `whitematter` off, or with large inflation values, some ROIs may not be generated; reduce the inflation or keep `whitematter` on.

## Citing

> [!TIP]
> If you use this App in your work, please cite the App, the software it builds on and brainlife.io (below). GitHub's **Cite this repository** button gives the App citation in APA and BibTeX.

If you use these Apps, please cite AFNI's ROI tools and brainlife.io:

- Taylor PA, Saad ZS. FATCAT: (an efficient) Functional And Tractographic Connectivity Analysis Toolbox. *Brain Connectivity* 3(5):523–535 (2013).
- Generate ROIs in DMRI Space with FA Skeleton mask. brainlife.io App. [doi:10.25663/brainlife.app.591](https://doi.org/10.25663/brainlife.app.591)
- Fischl. FreeSurfer. *NeuroImage* 62:774-781 (2012). [doi:10.1016/j.neuroimage.2012.01.021](https://doi.org/10.1016/j.neuroimage.2012.01.021)
- Jenkinson et al. FSL. *NeuroImage* 62:782-790 (2012). [doi:10.1016/j.neuroimage.2011.09.015](https://doi.org/10.1016/j.neuroimage.2011.09.015)
- Cox. AFNI: Software for Analysis and Visualization of Functional Magnetic Resonance Neuroimages. *Computers and Biomedical Research* 29:162-173 (1996). [doi:10.1006/cbmr.1996.0014](https://doi.org/10.1006/cbmr.1996.0014)
- Marcus et al. Informatics and Data Mining Tools and Strategies for the Human Connectome Project. *Frontiers in Neuroinformatics* 5 (2011). [doi:10.3389/fninf.2011.00004](https://doi.org/10.3389/fninf.2011.00004)
- Hayashi S, Caron BA, Heinsfeld AS, et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods* 21:809–813 (2024). [doi:10.1038/s41592-024-02237-2](https://doi.org/10.1038/s41592-024-02237-2)
- Avesani P, McPherson B, Hayashi S, et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. *Scientific Data* 6:69 (2019). [doi:10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)

## Authors

- Brad Caron

**Contributors:** Soichi Hayashi, Franco Pestilli

The older Apps use [vistasoft](https://github.com/vistalab/vistasoft), [SPM 8](https://www.fil.ion.ucl.ac.uk/spm/software/spm8/) and [jsonlab](https://github.com/fangq/jsonlab).

## Funding

[![Wellcome-226486/Z/22/Z](https://img.shields.io/badge/Wellcome-226486%2FZ%2F22%2FZ-purple.svg)](https://wellcome.org/)
[![NIH-NINDS-U24NS140384](https://img.shields.io/badge/NIH_NINDS-U24NS140384-green.svg)](https://reporter.nih.gov/project-details/11261037)
[![NIH-NINDS-UM1NS132207](https://img.shields.io/badge/NIH_NINDS-UM1NS132207-green.svg)](https://reporter.nih.gov/project-details/11411328)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://reporter.nih.gov/project-details/10262925)
[![NIH-NIBIB-R01EB030896](https://img.shields.io/badge/NIH_NIBIB-R01EB030896-green.svg)](https://reporter.nih.gov/project-details/10428625)
[![NIH-NIMH-R01MH126699](https://img.shields.io/badge/NIH_NIMH-R01MH126699-green.svg)](https://reporter.nih.gov/project-details/10460628)
[![NIH-NIDCD-R01DC020088](https://img.shields.io/badge/NIH_NIDCD-R01DC020088-green.svg)](https://reporter.nih.gov/project-details/11140284)
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-2203524](https://img.shields.io/badge/NSF_BCS-2203524-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2203524)
[![NSF-IIS-1636893](https://img.shields.io/badge/NSF_IIS-1636893-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-OAC-2148729](https://img.shields.io/badge/NSF_OAC-2148729-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148729)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NSF-IIS-2148700](https://img.shields.io/badge/NSF_IIS-2148700-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148700)
[![NSF-OAC-1916518](https://img.shields.io/badge/NSF_OAC-1916518-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1916518)

<sub>brainlife.io is publicly funded, and acknowledging that support helps keep it running. This App was developed with support from Wellcome, the U.S. National Institutes of Health (including the BRAIN Initiative BRAIN CONNECTS program: The Axonal Projectome EXchange, U24NS140384, and the Center for Mesoscale Connectomics, UM1NS132207) and the U.S. National Science Foundation.</sub>

## License

[MIT](LICENSE). FreeSurfer, FSL, AFNI and Connectome Workbench are distributed under their own licenses.
