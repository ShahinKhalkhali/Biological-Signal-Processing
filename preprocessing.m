%-----------------------------------------------------------------------
% Job saved on 12-Apr-2025 10:30:05 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
clear
%% INIT
% spm('defaults', 'FMRI'); % uncomment if you want to launch script without opening SPM
spm_jobman('initcfg');
matlabbatch = {};

% modify your dataset folder here:
project_folder = 'C:\Users\Shahi\OneDrive - Concordia University - Canada\WINTER 2025\ELEC 445\Project\ELEC 445 - Other Test Subjects\';
% modify your subject here:
subject = 'Sub08'; % 1 to 16, keep 0 padding for 1 digit subjects
% modify the run here:
run = 9; % 1 to 9

subject_folder = append(project_folder, subject);
run_number = append('Run_0', int2str(run));

ANAT_file = append(subject_folder, '\T1\mprage.nii');

BOLDS = dir(fullfile(subject_folder, 'BOLD', run_number, '*.nii'));
BOLD_files = cell(size(BOLDS, 1), 1);
for iFile = 1:size(BOLDS, 1)
    BOLD_files{iFile} = fullfile(BOLDS(iFile).folder, BOLDS(iFile).name);
end

% Check total amount of BOLDs is 208 images
if iFile ~= 208
    disp('There seems to be a problem with the number of BOLD files: ');
    disp(' - Expected BOLD files: 208');
    disp([' - Imported BOLD files: ', int2str(iFile)]);
    disp(['Maybe you already processed this run? ( ', subject, ' : ', run_number, ' )']);
    return;
end

disp(['>> Pre-Processing: ', subject, ' - ', run_number, '...']);

%% SETUP FILES
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'ANAT';
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {{ ANAT_file }};
matlabbatch{2}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'BOLD';
matlabbatch{2}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = { BOLD_files }';

%% SLICE TIMING
matlabbatch{3}.spm.temporal.st.scans{1}(1) = cfg_dep('Named File Selector: BOLD(1) - Files', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
matlabbatch{3}.spm.temporal.st.nslices = 33;
matlabbatch{3}.spm.temporal.st.tr = 2;
matlabbatch{3}.spm.temporal.st.ta = 1.93939393939394;
matlabbatch{3}.spm.temporal.st.so = [1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32];
matlabbatch{3}.spm.temporal.st.refslice = 16;
matlabbatch{3}.spm.temporal.st.prefix = 'a';

%% REALIGN
matlabbatch{4}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{4}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{4}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{4}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{4}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{4}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{4}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{4}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{4}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{4}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{4}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{4}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{4}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

%% COREGISTER
matlabbatch{5}.spm.spatial.coreg.estwrite.ref(1) = cfg_dep('Named File Selector: ANAT(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
matlabbatch{5}.spm.spatial.coreg.estwrite.source(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{5}.spm.spatial.coreg.estwrite.other(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
matlabbatch{5}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{5}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{5}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{5}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{5}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{5}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{5}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{5}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

%% NORMALISE
matlabbatch{6}.spm.spatial.normalise.estwrite.subj.vol(1) = cfg_dep('Named File Selector: ANAT(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
matlabbatch{6}.spm.spatial.normalise.estwrite.subj.resample(1) = cfg_dep('Coregister: Estimate & Reslice: Resliced Images', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
matlabbatch{6}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
matlabbatch{6}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
matlabbatch{6}.spm.spatial.normalise.estwrite.eoptions.tpm = {'C:\Users\Shahi\Documents\spm12\spm12\tpm\TPM.nii'};
matlabbatch{6}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
matlabbatch{6}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{6}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
matlabbatch{6}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
matlabbatch{6}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70
                                                             78 76 85];
matlabbatch{6}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
matlabbatch{6}.spm.spatial.normalise.estwrite.woptions.interp = 4;
matlabbatch{6}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';

%% SMOOTHING
matlabbatch{7}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Estimate & Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{7}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{7}.spm.spatial.smooth.dtype = 0;
matlabbatch{7}.spm.spatial.smooth.im = 0;
matlabbatch{7}.spm.spatial.smooth.prefix = 's';

%% RUN PRE-PROCESSING
spm_jobman('serial', matlabbatch)
disp('>> Preprocessing Done!')