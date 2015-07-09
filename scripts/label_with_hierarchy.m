% Labels the mesh with the features and phones whose combined beta weights
% pass threshold.
%
% Cai Wingfield 2015-05
function [paths] = label_with_hierarchy(glm_paths, model_hierarchy, feature_matrix, sum_threshold, userOptions)

    import rsa.*
    import rsa.meg.*
    import rsa.rdm.*
    import rsa.util.*

    for chi = 'LR'
        
        prints('Loading GLM meshes...');
        
        glm_mesh_betas = directLoad(glm_paths.(chi));
        % Trim the all-1s predictor.
        glm_mesh_betas = glm_mesh_betas(:, :, 2:end);
        
        [n_vertices, n_timepoints, n_betas] = size(glm_mesh_betas);
        
        % (n_features, n_betas)
        [n_features, ~] = size(feature_matrix);
        
        %% Label and threshold
        
        prints('Labelling and thresholding with feature models...');
        
        % In the labelling, we'll use:
        %  - Positive integers to represent phones.
        %  - Negative integers to represent features.
        %  - Zero to represent sub-threshold vertices.
        %
        % The model hierarchy is a tree: each node is a cell triple:
        %  {
        %    feature distinction for this level,
        %    sub-tree for phones which have this feature,
        %    sub-tree for phones which don't have this feature
        %  }
        %
        % A sub-tree is either:
        %  - A triple like the above.
        %  - A list of phones (indices) for which no further
        %    feature will distinguish them.
        
        % Preallocate
        labels = cell(n_vertices, n_timepoints);
        
        parfor t = 1:n_timepoints
            
            prints('Working on timepoint %d of %d...', t, n_timepoints);
            
            for v = 1:n_vertices
                
                beta_profile = squeeze(glm_mesh_betas(v, t, :));
                    
                labels{v, t} = label_with_traversal( ...
                    beta_profile, ...
                    model_hierarchy, ...
                    feature_matrix, ...
                    sum_threshold, ...
                    ...% no masking to begin with
                    ones(n_betas, 1)); %#ok<PFOUS> it's saved
            end
        end
        
        prints('Saving results...');
        
        glm_mesh_dir = fullfile(userOptions.rootPath, 'Meshes');
        paths.(chi) = fullfile(glm_mesh_dir, sprintf('hierarchical_map-%sh', lower(chi)));
        save(paths.(chi), 'labels', '-v7.3');
        
        
    end%for

end%function


% Labels a given datapoint with the nodes and phones with a super-threshold
% match to the data.
%
% CW 2015-05
function labels = label_with_traversal(beta_profile, model_hierarchy, feature_matrix, sum_threshold, parent_feature_profile)

    import rsa.*
    import rsa.util.*
    
    % For now, we are avoiding actual phone labels.
    observe_phone_labels = false;
    
    [n_features, n_phones] = size(feature_matrix);
    
    % The list of labels for the datapoint at this level of the
    % hierarchy. We start with it empty and add on labels as
    % they are shown to pass the threshold.
    labels = [];
    
    % First we check if we are at a leaf node in the model
    % hierarchy
    if ~iscell(model_hierarchy)
        if observe_phone_labels
        
            % If it's not a cell, then we're at a leaf node, in
            % which case the labels here are just the phones labels.
            % We'll add all those which pass the threshold...
            for phone_i = 1:numel(model_hierarchy)
                phone = model_hierarchy(phone_i);
                if beta_profile(phone) > sum_threshold
                    % We're (goofily) adding on the number of features here,
                    % which ensures that we don't get overlaps.  So if there
                    % are 13 features then the first phone will have number 14.
                    % This makes the labelling unique, but will make lookup
                    % hard. We should think of a better way to do this.
                    labels = [labels, phone + n_features];
                end
            end
        end
        % ...and we're done for this level.
        return;
    else

        % If it is a cell, then we're at a feature node, in which
        % case the there is work to do.  We'll start with empty
        % features.

        % At this level of the hierarchy, we'll check
        % whether the feature profiles match the beta
        % profile for this datapoint.

        feature_i = model_hierarchy{1};

        % Our profile of betas at this level is masked
        % (intersected/bitwise-anded) with the feature profile of the
        % parent feature, to ensure hierarchy.
        w_feature_profile = parent_feature_profile .* feature_matrix(feature_i, :)';
        wo_feature_profile = parent_feature_profile .* (1 - feature_matrix(feature_i, :)');
        
        w_feature_match = sum(beta_profile .* w_feature_profile);
        wo_feature_match = sum(beta_profile .* wo_feature_profile);

        % We will tag this with the feature if it matches sufficiently
        
        if w_feature_match > sum_threshold
            % We add the feature match as a cell entry with a positive
            % value.
            labels = [labels, {feature_i}];
            labels = [labels, label_with_traversal( ...
                beta_profile, ...
                model_hierarchy{2}, ...
                feature_matrix, ...
                sum_threshold, ...
                w_feature_profile)];
        end
        if wo_feature_match > sum_threshold
            % We add a feature non-match as a cell entry with a negative
            % value.
            labels = [labels, {-feature_i}];
            labels = [labels, label_with_traversal( ...
                beta_profile, ...
                model_hierarchy{3}, ...
                feature_matrix, ...
                sum_threshold, ...
                wo_feature_profile)];
        end
    end%if model_hierarchy is a cell array

end%function
