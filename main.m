function [] = main()

if ~isdeployed
    switch getenv('ENV')
    case 'IUHPC'
        disp('loading paths (HPC)')
        addpath(genpath('/N/u/brlife/git/encode'))
        addpath(genpath('/N/u/brlife/git/vistasoft'))
        addpath(genpath('/N/u/brlife/git/jsonlab'))
    case 'VM'
        disp('loading paths (VM)')
        addpath(genpath('/usr/local/encode-mexed'))
        addpath(genpath('/usr/local/vistasoft'))
        addpath(genpath('/usr/local/jsonlab'))
    end
end

disp('running')
outdir = 'output';
mkdir(outdir);
config = loadjson('config.json');
rois = str2num(config.rois);
fsOrParc = config.inputparc;

switch fsOrParc
    case 'freesurfer'
        fsDirMgz = fullfile(config.freesurfer);
        niiPath=fullfile(fsDirMgz,'/mri/','aparc+aseg.nii.gz');
        mgzfile='aparc+aseg.mgz';
        spaceChar={' '};
        quoteString=strcat('mri_convert',spaceChar, fsDirMgz,'/mri/',mgzfile ,spaceChar, niiPath);
        quoteString=quoteString{:};
        [status result] = system(quoteString, '-echo');
        fsDir = niiPath;
        if status~=0
            warning('/n Error generating aseg nifti file.  There may be a problem finding the file. Output: %s ',result)
        end
    case 'parcellation'
        fsDir = fullfile(config.parcellation,'parc.nii.gz');
end

refImg=fullfile(config.parcellation, 't1.nii.gz');
smoothFlag = config.smoothflag;

if strcmp('true',smoothFlag)
	smoothKernel = str2num(config.smoothkernel);
else
	smoothKernel = [];
end

%% ROI generation
%%%%    do this if want to create ROI pairs in single nifti %%%%
% index = 1:length((rois));
% odd = index(mod(index,2) == 1);
% even = index(mod(index,2) == 0);
% for ii = 1:length(odd)
%   roi_pair = [rois(odd(ii)),rois(even(ii))]
%   [matRoi] = bsc_roiFromFSnums(fsDir,roi_pair,smoothFlag,smoothKernel);
%   save(sprintf('roi_%s.mat',num2str(ii)),'matRoi','-v7.3');
%   roiName = sprintf('tract%s_roi.nii.gz',num2str(ii));
%   [ni, roiName] = dtiRoiNiftiFromMat_temp(matRoi,refImg,roiName,1);
%   clear('roi_pair', 'matRoi', 'roiName', 'ni')
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii = 1:length(rois)
    [matRoi] = bsc_roiFromFSnums(fsDir,rois(ii),smoothFlag,smoothKernel);
    save(fullfile(outdir,sprintf('roi_%s.mat',num2str(rois(ii)))),'matRoi','-v7.3');
    roiName = fullfile(outdir,sprintf('roi_%s.nii.gz',num2str(rois(ii))));
    [ni, roiName] = dtiRoiNiftiFromMat_temp(matRoi,refImg,roiName,1);
    clear('matRoi', 'roiName', 'ni');
end
exit;
end
