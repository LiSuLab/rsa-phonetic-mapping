function [feature_fits, bar_heights, error_bars] =  graph_feature_fits(model_rdms, output_dir)

    import rsa.*
    import rsa.rdm.*
    import rsa.util.*
    
    %% Models

    [M, PHONES, FEATURES] = phonetic_feature_matrix();
    
    n_timepoints = size(model_rdms, 1);
    
    n_entries = numel(rsa.rdm.vectorizeRDM(model_rdms(1, 1).RDM));
    
    n_phones  = numel(PHONES);
    n_features = numel(FEATURES);
    
    % Remove the outliers
    rdms(1:n_timepoints, n_phones) = struct('name', nan, 'RDM', nan, 'phone', nan);
    for phone_i = 1:n_phones
       % find the all_rdms-index for this phone
       this_phone = PHONES{phone_i};
       rdm_i = find(ismember({ model_rdms(1, :).phone }, lower(this_phone)));
       rdms(:, phone_i) = model_rdms(:, rdm_i); %#ok<FNDSB>
    end
    
    clear all_rdms;
    
    %% Compte overall second-order similarity matrix for model RDMs
    
    % Get model RDMs into shape
    
    rsa.util.prints('Collecting data together...');
    
    all_model_data = nan(n_phones, n_timepoints, n_entries);
    
    for phone_i = 1:n_phones
        for t = 1:n_timepoints
            all_model_data(phone_i, t, :) = rsa.rdm.vectorizeRDM(rdms(t, phone_i).RDM);
        end
    end
    
    rsa.util.prints('Computing second-order distance matrices from dynamic RDMs...');
    
    if exist(fullfile(output_dir, 'second_order_Ds.mat'), 'file')
        D_cell = rsa.util.directLoad(fullfile(output_dir, 'second_order_Ds'));
    else
        % Calculate dynamic distance matrix
        D_cell = dynamic_distance_matrix(all_model_data, 'Euclidean');
        save(fullfile(output_dir, 'second_order_Ds'), 'D_cell', '-v7.3');
    end
    
    
    %% Test each model arrangement hypothesis in turn
    feature_fits = nan(n_timepoints, n_features);
    
    for f = 1:n_features
        feature_hypothesis_dm = binary_categorical_rdm(M(f, :));
        for t = 1:n_timepoints
            model_dm = D_cell{t};

            feature_fits(t, f) = rsa.stat.rankCorr_Kendall_taua(model_dm, feature_hypothesis_dm);
        end
    end
   
   
    %% Graph it
    
    % average over time
    bar_heights = squeeze(mean(feature_fits, 1));
    
    % error bars
    error_bars = squeeze(std(feature_fits, 0, 1));
    
    % Plot the graph
    figure;
    hold on;
    
    bar(1:n_features, bar_heights);
    errorbar(1:n_features, bar_heights, error_bars);

end%function

% Dynamic distnaces/
%
% Returns D_cell, a n_timepoints-length cell array of distance matrices.
%
% CW 2015-06
function D_cell = dynamic_distance_matrix(all_model_data, disttype)

    [n_models, n_timepoints, n_rdm_entries] = size(all_model_data);
    
    Ds = zeros(n_timepoints, n_models, n_models);
    
    for model_1 = 1:n_models-1
        
        for model_2 = model_1+1:n_models
            
            rsa.util.prints('Calculating distance between models %d and %d...', model_1, model_2);
            
            % ds is a n_timepoints-length array of distances between this
            % pair of models.
            ds = compare_dynamic_rdms( ...
                squeeze(all_model_data(model_1, :, :)), ...
                squeeze(all_model_data(model_2, :, :)), ...
                'disttype', disttype);
            Ds(:, model_2, model_1) = ds;
        end
    end
    
    D_cell = cell(n_timepoints, 1);
    
    for t = 1:n_timepoints
        D_cell{t} = squareform(squeeze(Ds(t, :,:)));
    end

end%function


% Compares two dynamic RDMs.
%
% Each input RDM should be a (rdm_i, rdm_entries)
%
% Returns list_of_distances, a rdm_i-length array of pairwise distances.
%
% CW 2015-06
function list_of_distances = compare_dynamic_rdms(rdms_a, rdms_b, varargin)
    
    %% Parse inputs
    
    nameDistType    = 'disttype';
    validDistType   = {'Pearson', 'Spearman', 'Kendalltaua', 'Euclidean'};
    checkDistType   = @(x) (any(validatestring(x, validDistType)));
    defaultDistType = 'Kendalltaua';

    ip = inputParser;
    ip.CaseSensitive = false;
    ip.StructExpand  = false;
    
    addParameter(ip, nameDistType, defaultDistType, checkDistType);
    
    parse(ip, varargin{:});
    
    dist_type = ip.Results.(nameDistType);
    
    %% Constants
    [dynamic_length, model_size] = size(rdms_a);
    
    list_of_distances = nan(dynamic_length, 1);
    
    for rdm_i = 1:dynamic_length
        rdm_a = squeeze(rdms_a(rdm_i, :))';
        rdm_b = squeeze(rdms_b(rdm_i, :))';
        
        % hack
        if all(rdm_a == 0) || all(rdm_b == 0)
            list_of_distances(rdm_i) = 0;
        elseif strcmpi(dist_type, 'Euclidean')
            list_of_distances(rdm_i) = sqrt(sum((rdm_a - rdm_b) .^ 2));
        elseif strcmpi(dist_type, 'Kendalltaua')
            list_of_distances(rdm_i) = 1 - rsa.stat.rankCorr_Kendall_taua(rdm_a, rdm_b);
        else
            list_of_distances(rdm_i) = 1 - corr(rdm_a, rdm_b, 'type', dist_type);
        end
        
    end%for
    
end%function



