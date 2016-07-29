function [] = resave_as_masked_stc()

    import rsa.*
    import rsa.meg.*
    import rsa.util.*

    userOptions = phoneticMappingOptions();
    
    slMasks = MEGMaskPreparation_source(userOptions);
    slMasks = combineVertexMasks_source(slMasks, 'combined_mask', userOptions);

    %% Begin
    
    image_data_path = fullfile(userOptions.rootPath, 'ImageData');
    stc_output_dir = fullfile(userOptions.rootPath, 'ImageData_stc');
    
    [n_sessions, n_conditions] = size(lexproBetaCorrespondence);
    
    beta_correspondence = lexproBetaCorrespondence();

    % Save a separate file for each subject and each hemisphere
    for chi = 'LR'
        for subject_i = 1:numel(userOptions.subjectNames)
            
            thisSubjectName = userOptions.subjectNames{subject_i};
            
            subject_mesh_path = fullfile(image_data_path, [userOptions.analysisName, '_', userOptions.subjectNames{subject_i}, '_', lower(chi), 'h_CorticalMeshes.mat']);

            % Get metadata
            dummy_read_path = replaceWildcards(userOptions.betaPath, '[[betaIdentifier]]', beta_correspondence(1, 1).identifier, '[[subjectName]]', thisSubjectName, '[[LR]]', lower(chi));
            loaded_dummy_data = mne_read_stc_file1(dummy_read_path);
            STCMetadata = convertToSTCMetadata( ...
                loaded_dummy_data, ...
                true, slMasks([slMasks.chi] == chi), userOptions);
            
            all_masked_data = directLoad(subject_mesh_path);
            
            for s = 1:n_sessions
                for c = 1:n_conditions
                    
                    %% Save it!

                    stc_file_name = sprintf('%s_sess-%02d_cond-%03d_masked.stc', ...
                        thisSubjectName, s, c);
                    stc_file_path = fullfile(stc_output_dir, stc_file_name);
                    
                    masked_data = all_masked_data(:, :, c, s);

                    write_stc_file(STCMetadata, masked_data, stc_file_path);
                    
                end
            end
            
            
        end%for
    end%for

end%function


%%%%%%%%%%%%%%%%%%
%% Subfunctions %%
%%%%%%%%%%%%%%%%%%

% Converts raw STC metadata into a downsampled one
%
% Cai Wingfield 2015-03, based on Su Li's code
function STCMetadata = convertToSTCMetadata(MEGData_stc, usingMask, mask, userOptions)

    import rsa.*
    import rsa.meg.*
    import rsa.util.*
    
    % Raw data sizes, before downsampling

    % The number of vertices and timepoints in the raw data.
    [nVertices_raw, nTimepoints_raw] = size(MEGData_stc.data);
    
    % The time index of the first datapoint, in seconds.
    firstDatapointTime_raw = MEGData_stc.tmin;
    
    % The interval between successive datapoints in  the raw data,
    % in seconds.
    timeStep_raw = MEGData_stc.tstep;
    
    %% Downsampling constants

    % Sanity checks for downsampling
    if nVertices_raw < userOptions.targetResolution
        error('MEGDataPreparation_source:InsufficientSpatialResolution', 'There aren''t enough vertices in the raw data to meet the target resolution.');
    end

    % Now the actual downsampling targets can be calculated

    % We will be downsampling in space and time, so
    % we calculate some useful things here.
    
    % The number of timepoints in the downsampled data
    nTimepoints_downsampled = numel(1:userOptions.temporalDownsampleRate:nTimepoints_raw);
    timeStep_downsampled = timeStep_raw * userOptions.temporalDownsampleRate;

    % Time time index of the first datapoint doesn't change in the 
    % downsampled data
    firstDatapointTime_downsampled = firstDatapointTime_raw;

    % The time index of the last datapoint may change in the downsampled 
    % data, so should be recalculated
    lastDatapointTime_downsampled = firstDatapointTime_downsampled + (nTimepoints_downsampled * timeStep_downsampled);

    % This metadata struct will be useful for
    % writing appropriate files in future. This new
    % metadata should reflect the resolution and
    % specifices of the data which
    % MEGDataPreparation_source produces.
    STCMetadata.tmin  = firstDatapointTime_downsampled;
    STCMetadata.tmax  = lastDatapointTime_downsampled;
    STCMetadata.tstep = timeStep_downsampled;

    %% Apply mask

    % If we're using masks, we only want to include
    % those vertices which are inside the mask.
    if usingMask
        % Make sure we're using the vertices of the
        % mask on the correct hemisphere.
        % TODO: not actually downsampling here?!?! Need to intersect with
        % TODO: 1:targetResolution
        STCMetadata.vertices = uint32(sort(mask.vertices(:)));
    else
        % If we're not using a mask, we still need to
        % downsample the mesh to the target resolution.
        % Luckily, downsampling is just a matter of
        % taking low-numbered vertices, due to the way
        % they are laid out.
        STCMetadata.vertices = uint32((1:userOptions.targetResolution)');
    end%if
end%function
