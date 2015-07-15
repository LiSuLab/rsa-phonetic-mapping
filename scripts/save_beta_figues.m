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
           
           beta_matrix = beta_responses.(feature).(chi);
           
           % plot the figure
           imagesc(beta_matrix);
           
           % make it look nice
           colormap(rsa.fig.invert_colormap(gray));
           axis off;
           
           % save the figure
           saveas(this_figure, lower(sprintf('tonotopy_betas_%s-%sh.png', feature, chi)));
           
           % close it
           close(this_figure);
           
           %% Plot the distribution over time
           
           time_graph = squeeze(mean(beta_matrix, 1));
           
           time_fig = figure;
           
           plot(time_graph);
           
           % remove bounding box
           set(gca, 'box', 'off');
           
           % set background colour to white, not grey
           set(gcf, 'color', [1 1 1]);
           
           saveas(time_fig, lower(sprintf('time_plot_%s-%sh.png', feature, chi)));
           
           close(time_fig);
           
           
           %% Plot the distribution over frequencies
           
           frequency_graph = squeeze(mean(beta_matrix, 2));
           
           frequency_fig = figure;
           
           plot(frequency_graph);
           
           % rotate
           view(90, 90);
           
           % remove bounding box
           set(gca, 'box', 'off');
           
           % set background colour to white, not grey
           set(gcf, 'color', [1 1 1]);
           
           saveas(frequency_fig, lower(sprintf('frequency_plot_%s-%sh.png', feature, chi)));
           
           close(frequency_fig);
           
       end
    end

end%function
