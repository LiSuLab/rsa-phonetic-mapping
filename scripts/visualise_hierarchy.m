% Converts a labelled mesh into a visualisable stc file.
%
% Cai Wingfield 2015-05
function [hierarchy_labelled_paths] = visualise_hierarchy(lagSTCMetadatas, hierarchy_paths, model_hierarchy, userOptions)

    import rsa.*
    import rsa.meg.*
    import rsa.rdm.*
    import rsa.util.*

    for chi = 'LR'
        
        prints('Producing stc file for %sh...', lower(chi));
        
        labels = directLoad(hierarchy_paths.(chi));
        
        [n_vertices, n_timepoints] = size(labels);
        
        % preallocate
        labels_for_vertices = zeros(n_vertices, n_timepoints);
        
        for t = 1:n_timepoints
            prints('Working on timepoint %d/%d...', t, n_timepoints);
            for v_i = 1:n_vertices
                % second to last element is the final cateory
                if numel(labels{v_i, t}) > 0
                    ls = labels{v_i, t}{end};
                    if numel(ls) == 1
                        labels_for_vertices(v_i, t) = ls;
                    else
                        % If there are more than one phone that match
                        % significatly, we'll just take the first.
                        %
                        % This isn't great, but we're just diopng this for 
                        % a first run.
                        labels_for_vertices(v_i, t) = ls(1);
                    end
                end
            end
        end
        
        hierarchy_labelled_paths.(chi) = fullfile(userOptions.rootPath, 'Meshes', sprintf('model_hierarchy_map-%sh.stc', lower(chi)));
        
        write_stc_file( ...
            lagSTCMetadatas.(chi), ...
            labels_for_vertices, ...
            hierarchy_labelled_paths.(chi));
        
    end%for

end%function
