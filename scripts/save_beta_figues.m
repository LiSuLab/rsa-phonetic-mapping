function save_beta_figues(beta_responses, userOptions)

    figures_dir = fullfile(userOptions.rootPath, 'Figures');
    rsa.util.gotoDir(figures_dir);
    
    features = fieldnames(beta_responses)';
    
    for feature = features
       feature = feature{1}; %#ok<FXSET> % unwrap
       
       for chi = fieldnames(beta_responses.(feature))'
           chi = chi{1}; %#ok<FXSET> % unwrap
           
           % make the figure
           this_figure = figure;
           
           % set background colour to white, not grey
           set(gcf, 'color', [1 1 1]);
           
           %% time-frequency plot
           
           subplot(2, 2, 3);
           
           beta_matrix = beta_responses.(feature).(chi);
           
           abs_values = abs(beta_matrix);
           abs_max_value = max(abs_values(:));
           clims = [-abs_max_value, abs_max_value];
           
           % plot the figure
           imagesc(beta_matrix, clims);
           
           % make it look nice
           axis off;
           
           % Use parula because it's good at being symmetric about its
           % middle.
           colormap(parula);
           
           
           %% Plot the distribution over time
           
           subplot(2, 2, 1);
           
           time_graph = squeeze(mean(beta_matrix, 1));
           
           plot(time_graph, ...
               'LineWidth', 4);
           
           xlim([1, numel(time_graph)]);
           
           % remove bounding box
           set(gca, 'box', 'off');
           
           
           %% Plot the distribution over frequencies
           
           subplot(2, 2, 4);
           
           frequency_graph = squeeze(mean(beta_matrix, 2));
           
           plot(frequency_graph, ...
               'LineWidth', 4);
           
           xlim([1, numel(frequency_graph)]);
           
           % rotate
           view(90, 90);
           
           % remove bounding box
           set(gca, 'box', 'off');
           
           % set background colour to white, not grey
           set(gcf, 'color', [1 1 1]);
           
           %% label it
           
           subplot(2, 2, 2);
           
           % plot an empty imagesc so we can add a colorbar
           imagesc([], clims);
           axis off;
           
           text( ...
               ...% position
               0.5, 0.5, ...
               ...% string
               sprintf('%s (%sh)', lower(feature), lower(chi)), ...
               'FontSize', 24, ...
               'HorizontalAlignment', 'center');
           
           colorbar('SouthOutside');
           
           
           %% Save and close
           
           saveas(this_figure, lower(sprintf('beta_plot_%s-%sh.png', feature, chi)));
           
           close(this_figure);
           
       end
    end

end%function
