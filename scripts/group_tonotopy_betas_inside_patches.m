function [beta_response_plots, beta_response_plots_positive] = group_tonotopy_betas_inside_patches(threshold_vis, tonotopy_paths)

    % Initialise
    beta_response_plots = struct();
    beta_response_plots_positive = struct();

    % Load in tonotopy betas.
    for chi = 'LR'
        
        % Tonotopy paths are in matlab format.
        % v, t, b+1
        tonotopy_betas.(chi) = rsa.util.directLoad(tonotopy_paths.betas.(chi));
        
        % strip all-1s beta
        % v, t, b
        tonotopy_betas.(chi) = tonotopy_betas.(chi)(:, :, 2:end);
    end
    
    features = fieldnames(threshold_vis)';
    
    for feature = features
       feature = feature{1}; %#ok<FXSET> % unwrap
       
       % Initialise inside
       beta_response_plots.(feature) = struct();
       
       for chi = fieldnames(threshold_vis.(feature))'
           chi = chi{1}; %#ok<FXSET> % unwrap
           
           vertices_this_mask = threshold_vis.(feature).(chi);
           
           % Mask the tonotopy betas inside the feature-thresholded
           % vertices.
           % v, t, b
           betas_within_mask = tonotopy_betas.(chi)(vertices_this_mask, :, :);
           
           % t, b
           average_over_mask = squeeze( ...
               ...% Average over vertices (dim 1)
               mean(betas_within_mask, 1));
           
           % Orient nicely
           % b, t
           average_over_mask = average_over_mask(:, end:-1:1)';
           
           % Average over the vertices to produce time/frequency matrices.
           beta_response_plots.(feature).(chi) = average_over_mask;
           
           % Positives
           average_over_mask(average_over_mask < 0) = 0;
           beta_response_plots_positive.(feature).(chi) = average_over_mask;
           
       end
    end

end%function
