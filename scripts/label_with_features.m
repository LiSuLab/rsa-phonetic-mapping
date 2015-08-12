% CW 2015-06
function [feature_paths, feature_paths_mean, feature_paths_ea] = label_with_features(glm_paths, M, FEATURES, lagSTCMetadatas, show_positives, userOptions)
    
    import rsa.*
    import rsa.meg.*
    import rsa.rdm.*
    import rsa.util.*
    
    for chi = 'LR'
        
        prints('Loading GLM mesh for %sh...', lower(chi));
        
        glm_mesh_betas = directLoad(glm_paths.betas.(chi));
        
        % Trim the all-1s predictor.
        glm_mesh_betas = glm_mesh_betas(:, :, 2:end);
        
        [n_vertices, n_timepoints, n_betas] = size(glm_mesh_betas);
        
        % v b
        epoch_average_betas = squeeze(mean(glm_mesh_betas, 2));
        
        %% Label and threshold
        
        prints('Labelling and thresholding with feature models...');
        
        feature_names = fieldnames(FEATURES);
        
        for f = 1:numel(feature_names)
            
            feature_name = feature_names{f};
            feature_template = logical(FEATURES.(feature_name));
            
            % Preallocate and reset for this hemisphere
            feature_map = zeros(n_vertices, n_timepoints);
            feature_map_ea = zeros(n_vertices, 1);

            for v = 1:n_vertices
                for t = 1:n_timepoints
                    beta_values = squeeze(glm_mesh_betas(v, t, :));
                    % Calculate feature fit
                    feature_map(v, t) = dot(beta_values, feature_template');
                end
                beta_values_ea = squeeze(epoch_average_betas(v, :));
                feature_map_ea(v) = dot(beta_values_ea, feature_template');
            end
            
            % For display, we pick out the positive values, indicating model
            % fit.
            if show_positives
               feature_map(feature_map < 0) = 0;
               feature_map_ea(feature_map_ea < 0) = 0;
            end
            
            % Collapse over time
            feature_map_mean = squeeze(mean(feature_map, 2));
            
            feature_paths.(feature_name).(chi) = fullfile(userOptions.rootPath, 'Meshes', sprintf('feature-%s-%sh.stc', lower(feature_name), lower(chi)));
            feature_paths_mean.(feature_name).(chi) = fullfile(userOptions.rootPath, 'Meshes', sprintf('feature-%s-mean-%sh.stc', lower(feature_name), lower(chi)));
            feature_paths_ea.(feature_name).(chi) = fullfile(userOptions.rootPath, 'Meshes', sprintf('feature-%s-ea-%sh.stc', lower(feature_name), lower(chi)));
            
            write_stc_file( ...
                lagSTCMetadatas.(chi), ...
                feature_map, ...
                feature_paths.(feature_name).(chi));
            
            write_stc_snapshot( ...
                lagSTCMetadatas.(chi), ...
                feature_map_mean, ...
                feature_paths_mean.(feature_name).(chi));
            write_stc_snapshot( ...
                lagSTCMetadatas.(chi), ...
                feature_map_ea, ...
                feature_paths_ea.(feature_name).(chi));
                
        end%for:features
        
    end%for:chi

end%function
