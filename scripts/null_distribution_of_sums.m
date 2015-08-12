% CW 2015-05 -- 2015-06
function [feature_thresholds] = null_distribution_of_sums(h0_paths, FEATURES, varargin)
    
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
        
        prints('Loading null distribution for %sh hemi...', lower(chi));
    
        % (vertices, timepoints, betas, permutations)
        h0_betas.(chi) = directLoad(h0_paths.(chi));
        
        % This is just here to remind me what each dimension means!
        [n_vertices, n_timepoints, n_betas, n_permutations] = size(h0_betas.(chi));
        
    end%for:chi
    
    %% A separate sum-distribution for each feature mask.
    
    feature_names = fieldnames(FEATURES);
    
    for feature_i = 1:numel(feature_names)
        
        feature_name = feature_names{feature_i};
        
        prints('Computing threshold for feature "%sh"...', lower(feature_name));
    
        feature_template = logical(FEATURES.(feature_name));
        
        for chi = 'LR'
            h0_betas_this_feature = h0_betas.(chi)(:, :, feature_template, :);
            
            % average betas over epoch
            
            % v b p
            h0_ea = squeeze(mean(h0_betas_this_feature, 2));
            % v p
            h0_ea = squeeze(sum(h0_ea, 2));
            
            h0_ea_threshold = quantile( ...
                h0_ea(:), ...
                1 - threshold);
            
            feature_thresholds.(feature_name).(chi) = h0_ea_threshold;
       end%for
    end%for:feature
        
end%function
