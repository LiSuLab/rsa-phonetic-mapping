% CW 2015-06
function [feature_paths, feature_paths_ea] = label_with_features(glm_paths, FEATURES, lagSTCMetadatas, show_positives, userOptions)
    
    import rsa.*
    import rsa.meg.*
    import rsa.rdm.*
    import rsa.util.*
    
    for chi = 'LR'
        
        prints('Loading GLM mesh for %sh...', lower(chi));
        
        % v t b
        glm_mesh_betas = directLoad(glm_paths.betas.(chi));
        
        % Trim the all-1s predictor.
        glm_mesh_betas = glm_mesh_betas(:, :, 2:end);
        
        [n_vertices, n_timepoints, n_betas] = size(glm_mesh_betas);
        
        % v b
        epoch_average_betas = squeeze(mean(glm_mesh_betas, 2));
        
        %% Label and threshold
        
        feature_names = fieldnames(FEATURES);
        
        for f = 1:numel(feature_names)
            
            feature_name = feature_names{f};
        
            prints('Labelling and thresholding with feature model "%sh"...', lower(feature_name));
        
            feature_template = logical(FEATURES.(feature_name));
            
            % Preallocate and reset for this hemisphere
            feature_fit_map = zeros(n_vertices, n_timepoints);
            feature_fit_map_ea = zeros(n_vertices, 1);

            for v = 1:n_vertices
                for t = 1:n_timepoints
                    beta_values = squeeze(glm_mesh_betas(v, t, :));
                    % Calculate feature fit
                    feature_fit_map(v, t) = dot(beta_values, feature_template');
                end
                beta_values_ea = squeeze(epoch_average_betas(v, :));
                feature_fit_map_ea(v) = dot(beta_values_ea, feature_template');
            end
            
            % For display, we pick out the positive values, indicating model
            % fit.
            if show_positives
               feature_fit_map(feature_fit_map < 0) = 0;
               feature_fit_map_ea(feature_fit_map_ea < 0) = 0;
            end
            
            feature_paths.(feature_name).(chi) = fullfile(userOptions.rootPath, 'Meshes', sprintf('feature-%s-%sh.stc', lower(feature_name), lower(chi)));
            write_stc_file( ...
                lagSTCMetadatas.(chi), ...
                feature_fit_map, ...
                feature_paths.(feature_name).(chi));
            
            feature_paths_ea.(feature_name).(chi) = fullfile(userOptions.rootPath, 'Meshes', sprintf('feature-%s-ea-%sh.stc', lower(feature_name), lower(chi)));
            write_stc_snapshot( ...
                lagSTCMetadatas.(chi), ...
                feature_fit_map_ea, ...
                feature_paths_ea.(feature_name).(chi));
                
        end%for:features
        
    end%for:chi

end%function
