function flagged_neurons = plot_side_preference(selectivity_results_all, params,savepath)
    pool_types = {'left', 'right'};
    
    figure('Position', [100 100 400 400]);
    positions = utils.calculateFigurePositions(1, 5, .7, []);
    flagged_neurons = struct();
    
    for p_idx = 1:length(pool_types)
        pool = pool_types{p_idx};
        data = selectivity_results_all.both.(pool);
        
        % Create confusion matrix
        sides = {'left', 'right'};
        conf_mat = zeros(2);
        inconsistent_info = struct('index', {}, 'dataset_id', {}, 'active_pref', {}, 'passive_pref', {}); %false(length(data.active_preferred), 1);
        
        for i = 1:length(data.active_preferred)
            active_pref = data.active_preferred{i};
            passive_pref = data.passive_preferred{i};
 
            active_idx = strcmp(data.active_preferred{i}, sides);
            passive_idx = strcmp(data.passive_preferred{i}, sides);
            conf_mat(active_idx, passive_idx) = conf_mat(active_idx, passive_idx) + 1;

           % Check for inconsistent preference
            if strcmp(pool, 'left') && strcmp(active_pref, 'right') && strcmp(passive_pref, 'right')
                inconsistent_info(end+1) = struct( ...
                    'index', data.relative_cell_indices(i), ...
                    'dataset_id', data.dataset_ids(i), ...
                    'active_pref', active_pref, ...
                    'passive_pref', passive_pref);
            elseif strcmp(pool, 'right') && strcmp(active_pref, 'left') && strcmp(passive_pref, 'left')
                inconsistent_info(end+1) = struct( ...
                    'index', data.relative_cell_indices(i), ...
                    'dataset_id', data.dataset_ids(i), ...
                    'active_pref', active_pref, ...
                    'passive_pref', passive_pref);
            end

%             % Inconsistency check
%             % If the neuron is in left pool, but both prefs are 'right' => flag
%             % If in right pool, but both prefs are 'left' => flag
%             if strcmp(pool, 'left') && strcmp(active_pref, 'right') && strcmp(passive_pref, 'right')
%                 inconsistent_flags(i) = true;
%             elseif strcmp(pool, 'right') && strcmp(active_pref, 'left') && strcmp(passive_pref, 'left')
%                 inconsistent_flags(i) = true;
%             end
        end

        flagged_neurons.(pool) = inconsistent_info;

        
        % Plot
        subplot(1, 2, p_idx);
        imagesc(conf_mat);
        colorbar;
        title([upper(pool) ' Selective'],'FontWeight','normal');
        xlabel('Passive Preferred');
        ylabel('Active Preferred');
        set(gca, 'XTick', 1:2, 'XTickLabel', sides);
        set(gca, 'YTick', 1:2, 'YTickLabel', sides);
        if max(conf_mat,[],'all') < 100
            caxis([1,30])
        elseif max(conf_mat,[],'all') < 400 && max(conf_mat,[],'all') > 100
            caxis([1,150])
        else
            caxis([1,500])
        end
        
        colorList= (colormaps.slanCM('plasma',100));
        colormap(colorList) % redblue
        set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(p_idx, :));
        utils.set_current_fig;
    end
    % Save figure if path provided
        if ~isempty(savepath)
            mkdir(savepath)
            saveas(gcf, fullfile(savepath, ...
                'side_preference_counts.png'));
            saveas(gcf, fullfile(savepath, ...
                 'side_preference_counts.fig'));
            exportgraphics(gcf,'side_preference_counts.pdf', 'ContentType', 'vector');
        end
end