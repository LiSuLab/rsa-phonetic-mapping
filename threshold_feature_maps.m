function [thresholded_paths, threshold_vis] = threshold_feature_maps(feature_paths_ea, feature_threshold_levels, separate_fit_thresholds, userOptions)

    meshes_dir = fullfile(userOptions.rootPath, 'Meshes');

    % Initialise.
    thresholded_paths = struct();
    threshold_vis = struct();

    features = fieldnames(feature_threshold_levels)';
    
    for feature = features
       feature = feature{1}; %#ok<FXSET> % unwrap
       
       % Initialise inside fields.
       thresholded_paths.(feature) = struct();
       threshold_vis.(feature) = struct();
       
       for chi = fieldnames(feature_threshold_levels.(feature))'
           chi = chi{1}; %#ok<FXSET> % unwrap
           
           % Have to do this silly [chi 'ea'] thing because of an 
           % idiotic choice I made a while ago. Probably worth
           % fixing at some point.
           threshold = separate_fit_thresholds(feature_threshold_levels.(feature).(chi)).(feature).([chi 'ea']);
           
           thresholded_paths.(feature).(chi) = fullfile(meshes_dir, sprintf('artificially_thresholded_%s_%d_%sh.stc', feature, threshold, chi));
           
           unthresholded_snapshot = mne_read_stc_file1(feature_paths_ea.(feature).(chi));
           
           % We read in a snapshot, so we can just take out one copy of it.
           data = squeeze(unthresholded_snapshot.data(1,:));
           
           % Get out the vertex indices of the super-threshold vertices
           threshold_vis.(feature).(chi) = find(data > threshold);
           
           % Apply the threshold and write it out again.
           data(data < threshold) = 0;
           rsa.meg.write_stc_snapshot(unthresholded_snapshot, data, thresholded_paths.(feature).(chi));
           
       end
    end

end%function
