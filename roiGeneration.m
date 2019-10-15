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

% load config and input parcellation
config = loadjson('config.json');

% parse whether input is dwi or dtiinit
if ~isemtpy(config.dtiinit)
	refImg=fullfile(config.dwi);
else
    dt6=loadjson(fullfile(config.dtiinit,'dt6.json'));
	refImg=fullfile(config.dtiinit,dt6.files.alignedDwRaw);
end

% cortical ROIs
if ~isempty(config.corticalROIs)
    cortROIs = str2num(config.corticalROIs);
    cortDir = fullfile(pwd,'parc_inflate_GMI.nii.gz');
else
    display('no cortical rois')
end

% subcortical ROIs
if ~isempty(config.subcorticalROIs)
    inputparc = config.inputparc;
	subcortROIs = str2num(config.subcorticalROIs);
	subcortFSDir = fullfile(pwd,sprintf('%s+aseg.nii.gz',inputparc));
else
	display('no subcortical rois');
end

% thalamic ROIs
if ~isempty(config.thalamicROIs)
	thalamusROIs = str2num(config.thalamicROIs);
	thalamusDir = fullfile(pwd,'thalamus_inflate_GMI.nii.gz');
else
	display('no thalamic segmentation')
end

% % hippocampal ROIs: to do later!
% if ~isempty(config.hippocampalROIs)
% 	hippocampusROIs = str2num(config.hippocampalROIs);
% 	hippocampusDir = fullfile(pwd,'hippocampal_inflate_GMI.nii.gz');
% else
% 	display('no hippocampal segmentation')
% end

%% ROI generation
% cortical rois
if ~isempty(cortROIs)
    for ii = 1:length(cortROIs)
        [matRoi] = bsc_roiFromFSnums(fsDir,cortROIs(ii),'false',[]);
        if isempty(matRoi.coords)
            display('ROI not found in parcellation. Please see parcellation LUT');
            exit;
        else
            save(sprintf('ROI%s.mat',num2str(cortROIs(ii))),'matRoi','-v7.3');
            roiName = sprintf('ROI%s.nii.gz',num2str(cortROIs(ii)));
            [ni, roiName] = dtiRoiNiftiFromMat_temp(matRoi,refImg,roiName,1);
            clear('matRoi', 'roiName', 'ni');
        end
    end
end

% subcortical rois
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

% thalamus rois
if ~isemtpy(thalamusROIs)
	for ii = 1:length(thalamusROIs)
		[matRoi] = bsc_roiFromFSnums(thalamusDir,thalamusROIs(ii),'false',[]);
		if isempty(matRoi.coords)
		     display('ROI not found in thalamus segmentation. Please see thalamus segmentation');
		     exit;
		else
		     save(sprintf('ROI%s.mat',num2str(thalamusROIs(ii))),'matRoi','-v7.3');
		     roiName = sprintf('ROI%s.nii.gz',num2str(thalamusROIs(ii)));
		     [ni, roiName] = dtiRoiNiftiFromMat_temp(matRoi,refImg,roiName,1);
		     clear('matRoi', 'roiName', 'ni');
		end
	end
end

% hippocampus rois: to do later!
% if ~isemtpy(hippocampusROIs)
% 	for ii = 1:length(hippocampusROIs)
% 		[matRoi] = bsc_roiFromFSnums(hippocampusDir,hippocampusROIs(ii),'false',[]);
% 		if isempty(matRoi.coords)
% 		     display('ROI not found in hippocampus segmentation. Please see hippocampus segmentation');
% 		     exit;
% 		else
% 		     save(sprintf('ROI%s.mat',num2str(hippocampusROIs(ii))),'matRoi','-v7.3');
% 		     roiName = sprintf('ROI%s.nii.gz',num2str(hippocampusROIs(ii)));
% 		     [ni, roiName] = dtiRoiNiftiFromMat_temp(matRoi,refImg,roiName,1);
% 		     clear('matRoi', 'roiName', 'ni');
% 		end
% 	end
% end
%exit;
end
