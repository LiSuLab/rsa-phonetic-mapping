function thresholded_paths = threshold_feature_maps(feature_paths_ea, feature_thresholds, userOptions)

    meshes_dir = fullfile(userOptions.rootPath, 'Meshes');

    thresholded_paths = struct();

    features = fieldnames(feature_thresholds)';
    
    for feature = features
       feature = feature{1}; %#ok<FXSET> % unwrap
       
       for chi = fieldnames(feature_thresholds.(feature))'
           chi = chi{1}; %#ok<FXSET> % unwrap
           
           threshold = feature_thresholds.(feature).(chi);
           
           thresholded_paths.(feature).(chi) = fullfile(meshes_dir, sprintf('artificially_thresholded_%s_%d_%sh.stc', feature, threshold, chi));
           
           unthresholded_snapshot = mne_read_stc_file1( ...
               ...% Have to do this silly [chi 'ea'] thing because of an 
               ...% idiotic choice I made a while ago. Probably worth
               ...% fixing at some point.
               feature_paths_ea.(feature).([chi 'ea']));
           
           data = unthresholded_snapshot.data;
           
           % Apply the threshold
           data(data < threshold) = 0;
           
           % Write it out again
           rsa.meg.write_stc_snapshot(unthresholded_snapshot, data, thresholded_paths.(feature).(chi));
           
       end
    end

end%function
