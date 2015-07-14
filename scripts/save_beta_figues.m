function save_beta_figues(beta_responses_positive, userOptions)

    figures_dir = fullfile(userOptions.rootPath, 'Figures');
    rsa.util.gotoDir(figures_dir);
    
    features = fieldnames(beta_responses_positive)';
    
    for feature = features
       feature = feature{1}; %#ok<FXSET> % unwrap
       
       for chi = fieldnames(beta_responses_positive.(feature))'
           chi = chi{1}; %#ok<FXSET> % unwrap
           
           % make the figure
           this_figure = figure;
           this_axis = axes('Parent', this_figure);
           
           % plot the figure
           imagesc(beta_responses_positive.(feature).(chi));
           
           % make it look nice
           colormap(rsa.fig.invert_colormap(gray));
           axis off;
           
           % save the figure
           saveas(this_figure, lower(sprintf('tonotopy_betas_%s-%sh.png', feature, chi)));
           
           % close it
           close(this_figure);
       end
    end

end%function
