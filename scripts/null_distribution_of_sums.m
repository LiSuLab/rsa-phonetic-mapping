% CW 2015-05 -- 2015-06
function [feature_thresholds] = null_distribution_of_sums(h0_paths, M, FEATURES, userOptions, varargin)
    
    import rsa.*
    import rsa.util.*
    
    %% Parse inputs
    
    % 'threshold'
    nameThreshold = 'threshold';
    checkThreshold = @(x) (isnumeric(x) && (x >= 0));
    defaultThreshold = 0.05;
    
    % Set up parser
    ip = inputParser;
    ip.CaseSensitive = false;
    ip.StructExpand  = false;
    
    % Parameters
    addParameter(ip, nameThreshold, defaultThreshold, checkThreshold);
    
    % Parse the inputs
    parse(ip, varargin{:});
    
    % Get some nicer variable names
    
    % The file name prefix
    threshold = ip.Results.(nameThreshold);
    
    
    %% Begin

    for chi = 'LR'
        
        %% Load in the ungrouped null distributions for each hemisphere.
        
        prints('Loading null distribution...');
    
        % (vertices, timepoints, betas, permutations)
        h0_betas.(chi) = directLoad(h0_paths.(chi));
        
        % This is just here to remind me what each dimension means!
        [n_vertices, n_timepoints, n_betas, n_permutations] = size(h0_betas.(chi));
        
    end%for:chi
    
    %% A separate sum-distribution for each feature mask.
        
    prints('Computing threshold for each feature template...');
    
    for feature_i = 1:numel(FEATURES)
        
        feature_name = FEATURES{feature_i};
        feature_template = find(M(feature_i, :));
        
        feature_fits_h0_both = [];
        
        for chi = 'LR'
            h0_betas_this_feature = h0_betas.(chi)(:, :, feature_template, :); %#ok<FNDSB> "fixing" this causes weird results...
            feature_fit_h0_maps = sum(h0_betas_this_feature, 3);
            feature_fits_h0_both = [feature_fits_h0_both; feature_fit_h0_maps(:)];
            feature_threshold = quantile( ...
                feature_fit_h0_maps(:), ...
                ...% It's 1- so that "0.05" becomes the 0.95 quantile.
                1-threshold);
            feature_thresholds.(feature_name).(chi) = feature_threshold;
            
            % epoch average
            % v b p
            h0_ea = squeeze(mean(h0_betas_this_feature, 2));
            % v p
            h0_ea = squeeze(sum(h0_ea, 2));
            h0_ea_threshold = quantile( ...
                h0_ea(:), ...
                1-threshold);
            feature_thresholds.(feature_name).([chi 'ea']) = h0_ea_threshold;
       end%for
        
        threshold_this_feature_both = quantile( ...
            feature_fits_h0_both(:), ...
            1-threshold);
        feature_thresholds.(feature_name).both = threshold_this_feature_both;
    end%for:feature
    
    feature_thresholds.ALL.L = quantile( ...
        h0_betas.L(:), ...
        1-threshold);
    feature_thresholds.ALL.R = quantile( ...
        h0_betas.R(:), ...
        1-threshold);
    feature_thresholds.ALL.both = quantile( ...
        [h0_betas.L(:); h0_betas.R(:)], ...
        1-threshold);
        
end%function
