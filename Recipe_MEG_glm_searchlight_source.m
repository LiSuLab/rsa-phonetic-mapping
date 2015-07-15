% TODO: Documentation
%
% Cai Wingfield 2010-05, 2010-08, 2015-03--2015-06
% update by Li Su 3-2012, 11-2012
% updated Fawad 12-2013, 02-2014, 10-2014

import rsa.*
import rsa.util.*
import rsa.par.*
import rsa.meg.*

userOptions = phoneticMappingOptions();

prints('Starting RSA analysis "%s".', userOptions.analysisName);


%% %%%%%%%%%%%%%%%%%%%%%%%%
prints('Preparing model RDMs...');
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%models = constructModelRDMs(userOptions);
% Here are some I made earlier
models = directLoad('/imaging/cw04/Neurolex/Lexpro/Analysis_Phonetic_mapping/Model_HTK_triphone_probabilities/triphone-likelihood-RDMs.mat');


%% %%%%%%%%%%%%%%%%%%%
prints('Preparing masks...');
%%%%%%%%%%%%%%%%%%%%%%

% TODO: Don't enforce use of both hemispheres

usingMasks = ~isempty(userOptions.maskNames);
if usingMasks
    slMasks = MEGMaskPreparation_source(userOptions);
    % For this searchlight analysis, we combine all masks into one
    slMasks = combineVertexMasks_source(slMasks, 'combined_mask', userOptions);  
else
    slMasks = allBrainMask(userOptions);
end


%% Compute some constats
nSubjects = numel(userOptions.subjectNames);
adjacencyMatrices = calculateMeshAdjacency(userOptions.targetResolution, userOptions.sourceSearchlightRadius, userOptions, 'hemis', 'LR');


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
prints('Starting parallel toolbox...');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if userOptions.flush_Queue
    flushQ();
end

if userOptions.run_in_parallel
    p = initialise_CBU_Queue(userOptions);
end


%% %%%%%%%%%%%%%%%%%%
prints('Loading brain data...');
%%%%%%%%%%%%%%%%%%%%%

[meshPaths, STCMetadatas] = MEGDataPreparation_source( ...
    lexproBetaCorrespondence(), ...
    userOptions, ...
    'mask', slMasks);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prints('Searchlight Brain RDM Calculation...');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[RDMsPaths, slSTCMetadatas] = MEGSearchlightRDMs_source( ...
    meshPaths, ...
    slMasks, ...
    ...% Assume that both hemis' adjacency matrices are the same so only use one.
    adjacencyMatrices.L, ...
    STCMetadatas, ...
    userOptions);


%% %%%%%
prints('Averaging searchlight RDMs...');
%%%%%%%%

averageRDMPaths = averageSearchlightRDMs(RDMsPaths, userOptions);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prints('GLM-fitting models to searchlight RDMs...');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

first_model_frame = 5;

[glm_paths, lagSTCMetadatas] = searchlight_dynamicGLM_source( ...
    averageRDMPaths, ...
    models, first_model_frame, ...
    slSTCMetadatas, ...
    userOptions, ...
    'lag', 100);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prints('Thresholding GLM values...');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
[M, PHONES, FEATURES] = phonetic_feature_matrix();

[h0_paths] = searchlight_GLM_permutation_source( ...
    averageRDMPaths, ...
    models, ...
    slSTCMetadatas, ...
    lagSTCMetadatas, ...
    ...% FIX ME
    first_model_frame, ...
    ...% number of permutation batches
    ...%TODO make this into optional argument
    30, ... % 30
    userOptions);

% Compute thresholds for different levels of significance.
% Index equals number of stars.
separate_fit_thresholds(1) = null_distribution_of_sums( ...
    h0_paths, ...
    M, FEATURES, ...
    userOptions, ...
    'threshold', 0.05);
separate_fit_thresholds(2) = null_distribution_of_sums( ...
    h0_paths, ...
    M, FEATURES, ...
    userOptions, ...
    'threshold', 0.01);
separate_fit_thresholds(3) = null_distribution_of_sums( ...
    h0_paths, ...
    M, FEATURES, ...
    userOptions, ...
    'threshold', 0.001);

[feature_paths, feature_paths_mean, feature_paths_ea] = label_with_features( ...
    glm_paths, ...
    M, FEATURES, ...
    lagSTCMetadatas, ...
    true, ...
    userOptions);

% Print out the thresholded values
rsa.util.display_singleton_struct(separate_fit_thresholds);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prints('Anlysing feature patches...');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check to see if the thresholded features in the paper are being extracted
% properly.

feature_threshold_levels = custom_feature_thresholds();

[feature_thresholded_paths, threshold_vis] = threshold_feature_maps( ...
    feature_paths_ea, ...
    feature_threshold_levels, ...
    separate_fit_thresholds, ...
    userOptions);
    
% TODO: get this path right, maybe include the to-be-loaded file it in the repo?
tonotopy_paths = directLoad('/imaging/cw04/Neurolex/Lexpro/Analysis_Phonetic_mapping/analysis-phonetc-mapping-scripts/tonotopy_paths.mat');

[beta_responses, beta_responses_positive, beta_sds] = group_tonotopy_betas_inside_patches( ...
    threshold_vis, ...
    tonotopy_paths);

save_beta_figues( ...
    beta_responses_positive, ...
    userOptions);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prints('Cleaning up...');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Close the parpool
if userOptions.run_in_parallel
    delete(p);
end

% Sending an email
if userOptions.recieveEmail
    setupInternet();
    setupEmail(userOptions.mailto);
end

prints( ...
    'RSA COMPLETE!');
