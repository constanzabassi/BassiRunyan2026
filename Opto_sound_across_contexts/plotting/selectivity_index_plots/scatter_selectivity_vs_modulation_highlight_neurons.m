function scatter_selectivity_vs_modulation_highligh_neurons(selectivity_indexm, mod_index_results, neurons_of_interest, cells_cumsum)
    % Add neurons_of_interest parameter - global indices of neurons to highlight
    % Add cells_cumsum parameter - cumulative sum of cells per dataset for indexing
    
    nDatasets = length(mod_index_results);
    figure('Position', [100 100 600 250]);
    contexts = {'Active', 'Passive'};
    dummy_h = zeros(1,4); % Added one more for highlighted points
    
    right_color = [.39,.56,1];
    left_color = [.86,.15,.49];
    highlight_color = [0.2 0.2 0.2]; % Color for highlighting neurons of interest
    
    % Loop through contexts
    for ctx = 1:2
        subplot(1, 2, ctx);
        hold on;
        
        % Store all points to highlight across datasets
        highlight_left_mod = [];
        highlight_right_mod = [];
        
        % Loop through datasets
        for d = 1:nDatasets
            mod_data = mod_index_results(d).context(ctx).cv_mod_index_separate;
            sel_idx = selectivity_indexm{d,ctx};
            
            % Get raw modulation values
            left_mod = mod_data.left;
            right_mod = mod_data.right;
            
            % Find neurons of interest in current dataset
            if d == 1
                dataset_start = 1;
            else
                dataset_start = cells_cumsum(d-1) + 1;
            end
            dataset_end = cells_cumsum(d);
            dataset_neurons = neurons_of_interest(...
                neurons_of_interest >= dataset_start & ...
                neurons_of_interest <= dataset_end);
            local_indices = dataset_neurons - dataset_start + 1;
            
            % Store points to highlight
            highlight_left_mod = [highlight_left_mod; left_mod(local_indices)'];
            highlight_right_mod = [highlight_right_mod; right_mod(local_indices)'];
            
            % Original plotting code...
            left_selective = sel_idx > 0.1;
            right_selective = sel_idx < -0.1;
            nonsel = abs(sel_idx) <= 0.1;

%             [left_selective, right_selective , nonsel ] = categorize_selectivity_context(sel_idx, 0.1, 1:length(sel_idx));
            
            % Plot regular points (excluding highlighted ones)
            mask_non_highlight = ~ismember(1:length(left_mod), local_indices);
            
            scatter(left_mod(nonsel & mask_non_highlight), ...
                right_mod(nonsel & mask_non_highlight), 50, ...
                'o', 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor', 'none', ...
                'MarkerFaceAlpha', 0.4);
            
            scatter(left_mod(left_selective & mask_non_highlight), ...
                right_mod(left_selective & mask_non_highlight), 50, ...
                'o', 'MarkerFaceColor', left_color, 'MarkerEdgeColor', 'none', ...
                'MarkerFaceAlpha', 0.4);
            
            scatter(left_mod(right_selective & mask_non_highlight), ...
                right_mod(right_selective & mask_non_highlight), 50, ...
                'o', 'MarkerFaceColor', right_color, 'MarkerEdgeColor', 'none', ...
                'MarkerFaceAlpha', 0.4, 'MarkerEdgeAlpha', 0.5);
        end
        
        % Plot highlighted points last so they're on top
        scatter(highlight_left_mod, highlight_right_mod, 50, ...
            'o', 'MarkerFaceColor', 'none', 'MarkerEdgeColor', highlight_color, ...
            'LineWidth', 1);
            
        % Rest of plotting code...
        % Create legend entries
        if d == 1 && ctx == 2
            dummy_h(3) = scatter(nan, nan, 50, 'o', 'MarkerFaceColor', [0.5 0.5 0.5], ...
                'MarkerEdgeColor', 'none', 'DisplayName', 'Non-Selective');
            dummy_h(1) = scatter(nan, nan, 50, 'o', 'MarkerFaceColor', left_color, ...
                'MarkerEdgeColor', 'none', 'DisplayName', 'Left Selective');
            dummy_h(2) = scatter(nan, nan, 50, 'o', 'MarkerFaceColor', right_color, ...
                'MarkerEdgeColor', 'none', 'DisplayName', 'Right Selective');
            dummy_h(4) = scatter(nan, nan, 50, 'o', 'MarkerFaceColor', 'none', ...
                'MarkerEdgeColor', highlight_color, 'LineWidth', 1, ...
                'DisplayName', 'Neurons of Interest');
            
            legend('Location', 'southeast', 'box', 'off', 'FontSize', 8);
        end
        % Add unity line
        plot([-1 1], [-1 1], 'k--', 'HandleVisibility', 'off');

        % Format plot
        xlabel('Left trial modulation');
        ylabel('Right trial modulation');
        title([contexts{ctx} ' Context'],'FontWeight','normal');
        axis square;
        grid on;
        xlim([-1 1]);
        ylim([-1 1]);
        utils.set_current_fig;
%         
    end
end
% function scatter_selectivity_vs_modulation(selectivity_indexm, mod_index_results)
%     % Create figure with subplots for each context
%     nDatasets = length(mod_index_results);
%     figure('Position', [100 100 600 250]);
%     
%     contexts = {'Active', 'Passive'};
% 
% %     positions = utils.calculateFigurePositions(1,3,0.5,[]);
%     
%     % Create dummy points for legend
%     dummy_h = zeros(1,3);
% 
%     %left and right colors
%     right_color = [.39,.56,1];%light blue %colors for right sound trials
%     left_color = [.86,.15,.49]
%     
%     % Loop through contexts
%     for ctx = 1:2
%         subplot(1, 2, ctx);
%         hold on;
%         
%         % Loop through datasets
%         for d = 1:nDatasets
%             % Get modulation and selectivity data
%             mod_data = mod_index_results(d).context(ctx).cv_mod_index_separate;
%             sel_idx = selectivity_indexm{d,ctx};
%             
%             % Get raw modulation values
%             left_mod = mod_data.left;
%             right_mod = mod_data.right;
%             
%             % Categorize by selectivity
%             left_selective = sel_idx > 0.1;
%             right_selective = sel_idx < -0.1;
%             nonsel = abs(sel_idx) <= 0.1;
%             
%             % Plot each selectivity group (without DisplayName to avoid multiple legend entries)
%             %non selective
%             scatter(left_mod(nonsel), right_mod(nonsel), 50, ...
%                 'o', 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor', 'none', ...
%                 'MarkerFaceAlpha', 0.4);
% 
%             %left selective
%             scatter(left_mod(left_selective), right_mod(left_selective), 50, ...
%                 'o', 'MarkerFaceColor', left_color, 'MarkerEdgeColor', 'none', ...
%                 'MarkerFaceAlpha', 0.4);
% 
%             %right selective
%             scatter(left_mod(right_selective), right_mod(right_selective), 50, ...
%                 'o', 'MarkerFaceColor', right_color, 'MarkerEdgeColor', 'none', ...
%                 'MarkerFaceAlpha', 0.4);
%             
%             
%             % Create dummy points for legend only in first iteration
%             if d == 1 && ctx == 2
%                 dummy_h(3) = scatter(nan, nan, 50, 'o', 'MarkerFaceColor', [0.5 0.5 0.5], ...
%                     'MarkerEdgeColor', 'none', 'DisplayName', 'Non-Selective');
%                 dummy_h(1) = scatter(nan, nan, 50, 'o', 'MarkerFaceColor', left_color, ...
%                     'MarkerEdgeColor', 'none', 'DisplayName', 'Left Selective');
%                 dummy_h(2) = scatter(nan, nan, 50, 'o', 'MarkerFaceColor', right_color, ...
%                     'MarkerEdgeColor', 'none', 'DisplayName', 'Right Selective');
%                 
% 
%                 legend('Location', 'southeast','box','off','FontSize',8);
%             end
%             
%         end
%         
%         % Add unity line
%         plot([-1 1], [-1 1], 'k--', 'HandleVisibility', 'off');
%         
%         % Format plot
%         xlabel('Left trial modulation');
%         ylabel('Right trial modulation');
%         title([contexts{ctx} ' Context'],'FontWeight','normal');
%         axis square;
%         grid on;
%         xlim([-1 1]);
%         ylim([-1 1]);
%         utils.set_current_fig;
%         
%     end
%     
%     % Add single legend to the figure
%     legend(dummy_h, 'Location', 'eastoutside');
%     sgtitle('Modulation Index by Sound Direction and Selectivity');
% end