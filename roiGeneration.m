function [] = roiGeneration()

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
config = loadjson('config.json');
rois = str2num(config.ROI);
inputparc = config.inputparc;
refImg=fullfile(config.dwi);

if ~isempty(config.subcort)
	subcortROIs = str2num(config.subcort);
	subcortFSDir = fullfile(pwd,sprintf('%s+aseg.nii.gz',inputparc));
else
    subcortROIs = [];
end

%if exist(fullfile(pwd,'parc.nii.gz')) == 2
%    fsDir = fullfile(pwd,'parc.nii.gz');
%else
%    fsDir = fullfile(pwd,'aparc+aseg.nii.gz');
%end

fsDir = fullfile(pwd,'parc_inflate_GMI.nii.gz');

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
	[matRoi] = bsc_roiFromFSnums(fsDir,rois(ii),'false',[]);
	if isempty(matRoi.coords)
		display('ROI not found in parcellation. Please see parcellation LUT');
		exit;
	else
		save(sprintf('ROI%s.mat',num2str(rois(ii))),'matRoi','-v7.3');
		roiName = sprintf('ROI%s.nii.gz',num2str(rois(ii)));
		[ni, roiName] = dtiRoiNiftiFromMat_temp(matRoi,refImg,roiName,1);
		clear('matRoi', 'roiName', 'ni');
	end
end

if ~isempty(subcortROIs)
    for ii = 1:length(subcortROIs)
        [matRoi] = bsc_roiFromFSnums(subcortFSDir,subcortROIs(ii),'false',[]);
        if isempty(matRoi.coords)
            display('ROI not found in parcellation. Please see parcellation LUT');
            exit;
        else
            save(sprintf('ROI0%s.mat',num2str(subcortROIs(ii))),'matRoi','-v7.3');
            roiName = sprintf('ROI0%s.nii.gz',num2str(subcortROIs(ii)));
            [ni, roiName] = dtiRoiNiftiFromMat_temp(matRoi,refImg,roiName,1);
            clear('matRoi', 'roiName', 'ni');
        end
    end
end
%exit;
end
