%% Lab #4 - Script Analysis Subject Job

%-----------------------------------------------------------------------
% This script execute a single-subject analysis using SPM
% The pipeline consist of the standard preprocessing steps followed by 1st
% level GLM. 
%
% The preprocessing stapes are : 
%   1. Slice timing correction
%   2. Relaignment (or motion correction)
%   3. Co-registration
%   4. Normalization 
%   5. Smoothing
% The GLM steps are: 
%   1. Model specification
%   2. Model estimation
%   3. Constrast specification
% The studied constrast are: 
%   1. chkbd_h  or  [1   0   0   0   0   0   0   0   0   0]
%   2. chkbd_v or  [0  1    0   0   0   0   0   0   0   0]
%   3. chkbd_h - chkbd_v  [1   -1   0   0   0   0   0   0   0   0]
%   4. audio - video   [0     0     1    -1     1    -1     1    -1     1    -1];
%
%  In this script, we use two different pipeline, one for the
%  pre-processing and one for the GLM. This allow us to better control the
%  file used as input for the GLM and make sure we are selecting the proper
%  input. 
%
%  Warning; on line 103: matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.tpm = {'/Users/edelaire1/.brainstorm/plugins/spm12/spm12-maint/tpm/TPM.nii'};
%  Change the path toward your SPM installation
%
% Written by Edouard Delaire, March 1st 2025
%-----------------------------------------------------------------------


% Initialize SPM
spm('defaults', 'FMRI');
spm_jobman('initcfg')

% Set parameters values
dataset_folder  = '/Users/edelaire1/Documents/cours/TeachingAssistant/ELEC/winter2025/ELEC498_fmri_zero_grp2/origin/';
subject_name    = 'GH158';

%% Definition of the input / output 
% Path to the anatomical data
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'anat';
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {{ fullfile( dataset_folder , subject_name, 'anat', [subject_name '_anat.img'])}};

% Path to the functional dataz
BOLDS = dir(fullfile(dataset_folder,subject_name,'bold', [subject_name '_bold*.img']));
BOLDS_files = cell(size(BOLDS,1),1);
for iFile = 1:size(BOLDS,1)
    BOLDS_files{iFile} = fullfile(BOLDS(iFile).folder, BOLDS(iFile).name);
end


matlabbatch{2}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'BOLD';
matlabbatch{2}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = { BOLDS_files }';

% Path to the save the GLM results
matlabbatch{3}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent = {fullfile( dataset_folder , subject_name)};
matlabbatch{3}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.name = 'GLM';

%% Definition of the pipeline

% 1. Slice timing correction
matlabbatch{4}.spm.temporal.st.scans{1}(1) = cfg_dep('Named File Selector: BOLD(1) - Files', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
matlabbatch{4}.spm.temporal.st.nslices = 40;
matlabbatch{4}.spm.temporal.st.tr = 2.4;
matlabbatch{4}.spm.temporal.st.ta = 2.34;
matlabbatch{4}.spm.temporal.st.so = [40:-2:1, 39:-2:1];
matlabbatch{4}.spm.temporal.st.refslice = 20;
matlabbatch{4}.spm.temporal.st.prefix = 'a';

% 2. Realignment
matlabbatch{5}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{5}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{5}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{5}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{5}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{5}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{5}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{5}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{5}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{5}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{5}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{5}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{5}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

% 3. Co-registration
matlabbatch{6}.spm.spatial.coreg.estwrite.ref(1)        = cfg_dep('Named File Selector: anat(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
matlabbatch{6}.spm.spatial.coreg.estwrite.source(1)     = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{6}.spm.spatial.coreg.estwrite.other(1)      = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.sep  = [4 2];
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.tol  = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';


% 4. Normalization
matlabbatch{7}.spm.spatial.normalise.estwrite.subj.vol(1)       = cfg_dep('Named File Selector: anat(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
matlabbatch{7}.spm.spatial.normalise.estwrite.subj.resample(1)  = cfg_dep('Coregister: Estimate & Reslice: Resliced Images', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.biasreg  = 0.0001;
matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;

% ???????? WARNING ???????? change path to your SPM installation
matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.tpm = {'/Users/edelaire1/.brainstorm/plugins/spm12/spm12-maint/tpm/TPM.nii'};
matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
matlabbatch{7}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
matlabbatch{7}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70
                                                             78 76 85];
matlabbatch{7}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
matlabbatch{7}.spm.spatial.normalise.estwrite.woptions.interp = 4;
matlabbatch{7}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';


% 5. Smoothing
matlabbatch{8}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Estimate & Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{8}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{8}.spm.spatial.smooth.dtype = 0;
matlabbatch{8}.spm.spatial.smooth.im = 0;
matlabbatch{8}.spm.spatial.smooth.prefix = 's';

% 10. Start the pipeline
% Note we could do one only pipeline but also separate have the option to
% run the GLM spearatly from the processing. 
% this is also a bit more safe as it is allowing us to more prescisly
% select the file used for the GLM

spm_jobman('serial', matlabbatch);


%% We start a new piepleine for the GLM
matlabbatch = {};

% Generate the list of file that were pre-processed, used as input for the
% GLM. 
preprocessed_BOLD = dir(fullfile(dataset_folder, subject_name,'bold', ['swrra' subject_name '_bold*.img']));
preprocessed_BOLD_files = cell(size(BOLDS,1),1);
for iFile = 1:size(BOLDS,1)
    preprocessed_BOLD_files{iFile} = fullfile(preprocessed_BOLD(iFile).folder, preprocessed_BOLD(iFile).name);
end
% 6. GLM: model specification

paradigm_file   = fullfile(dataset_folder,subject_name, 'bold',sprintf('%s_paradigm.csv',subject_name));
paradigm        = readtable(paradigm_file);
event_name      = unique(paradigm.Var2);

matlabbatch{1}.spm.stats.fmri_spec.dir(1) =  {fullfile( dataset_folder , subject_name,'GLM')};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2.4;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 40;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 20;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = preprocessed_BOLD_files;


for iEvent = 1:length(event_name)

    idx_events = strcmp(paradigm.Var2,event_name{iEvent} ); 

    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(iEvent).name       = event_name{iEvent};
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(iEvent).onset      = paradigm.Var3(idx_events);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(iEvent).duration   = paradigm.Var4(idx_events);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(iEvent).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(iEvent).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(iEvent).orth = 1;

end

matlabbatch{1}.spm.stats.fmri_spec.sess.multi   = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';


% 7. GLM: model estimation

matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


% 8. GLM: contrast estimation


matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));

matlabbatch{3}.spm.stats.con.consess{1}.tcon.name      = 'chkbd_h';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights   = real(strcmp(event_name, 'chkbd_h')'); % [1   0   0   0   0   0   0   0   0   0]
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep   = 'none';

matlabbatch{3}.spm.stats.con.consess{2}.tcon.name      = 'chkbd_v';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights   = real(strcmp(event_name, 'chkbd_v')'); % [0   1   0   0   0   0   0   0   0   0]];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep   = 'none';

matlabbatch{3}.spm.stats.con.consess{3}.tcon.name      = 'chkbd_h - chkbd_v';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights   = real(strcmp(event_name, 'chkbd_h')'  - strcmp(event_name, 'chkbd_v')'); % [1   -1   0   0   0   0   0   0   0   0]];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep   = 'none';

matlabbatch{3}.spm.stats.con.consess{4}.tcon.name      = 'audio - video';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights   = real(contains(event_name, 'audio')'  - contains(event_name, 'video')'); % [0     0     1    -1     1    -1     1    -1     1    -1];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep   = 'none';

matlabbatch{3}.spm.stats.con.delete = 1;


% 10. Start the pipeline
spm_jobman('serial', matlabbatch);





