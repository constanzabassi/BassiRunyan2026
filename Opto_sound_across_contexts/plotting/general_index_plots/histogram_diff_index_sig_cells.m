function [p_val_mod] = histogram_diff_index_sig_cells(chosen_cells, all_celltypes, index, plot_info, save_path, string,horizontalmode, varargin)
    % originally called histogram_mod_opto_cells
    % This function generates histograms of the absolute differences in index values 
    % for different cell types. It also performs a permutation test to determine
    % the significance of the observed differences.

    figure(2325); clf; % Create and clear figure
    

    if ~isempty(chosen_cells) % Check if chosen_cells is not empty
        fieldss = fields(all_celltypes{1,1}); % Extract field names from first cell type structure
        for cell_type = 1:length(fieldss) % Loop over all cell types
            difference = []; % Initialize difference array
            if horizontalmode == 1
                positions = utils.calculateFigurePositions(1, 5, .5, []);
                subplot(1, length(fieldss),  cell_type) % Create subplot for each cell type
            else
                positions = utils.calculateFigurePositions(5,1 , .5, []);
                subplot(length(fieldss), 1, cell_type) % Create subplot for each cell type
            end
            
            for dataset_index = 1:length(chosen_cells)
                % Find cells belonging to the current cell type
                chosen_cells2{cell_type} = chosen_cells{1,dataset_index}(ismember(chosen_cells{1,dataset_index}, all_celltypes{1,dataset_index}.(fieldss{cell_type})));
                
                % Compute absolute difference in index values
                difference = [difference, abs(index{dataset_index,1}(chosen_cells2{cell_type})) - abs(index{dataset_index,2}(chosen_cells2{cell_type}))];
            end
            
            hold on
            % Plot histogram of differences
            histogram(difference, 'BinWidth', 0.05, 'normalization', 'probability', 'FaceColor', plot_info.colors_celltypes(cell_type,:), ...
                'EdgeColor', plot_info.colors_celltypes(cell_type,:), 'FaceAlpha', 0.9, 'Normalization', 'count');
            xline(0, '--k', 'LineWidth', 2);
            
            % Calculate and plot the mean difference as an inverted triangle
            mean_diff = mean(difference, 'omitnan');
            y_limits = ylim;
            xlim([-.5 .5]);
            plot(mean_diff, y_limits(2), 'v', 'MarkerSize', 6, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
            set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(cell_type, :));
            if cell_type == 2
                xlabel(string,'FontSize',7);
            end
            utils.set_current_fig; % Apply figure settings
            box off;
            
            % Perform a permutation test to compare differences against zero
            possible_tests = nchoosek(1:length(fieldss), 2);
            [p_val_mod(cell_type), ~, ~] = permutationTest_updatedcb(difference, zeros(length(difference), 1), 10000, 'paired', 1);
            
            % Apply Bonferroni correction
            if p_val_mod(cell_type) >= 0.05 / size(possible_tests, 1)
                p_val_mod(cell_type) = 1;
            end
        end
    else % If chosen_cells is empty, process all cells
        fieldss = fields(all_celltypes{1,1});
        for cell_type = 1:length(fieldss)
            if horizontalmode == 1
                subplot(1, length(fieldss),  cell_type) % Create subplot for each cell type
            else
                subplot(length(fieldss), 1, cell_type) % Create subplot for each cell type
            end
            difference = [];
            
            for dataset_index = 1:length(all_celltypes)
                difference = [difference, abs(index{dataset_index,1}(all_celltypes{1,dataset_index}.(fieldss{cell_type}))) - abs(index{dataset_index,2}(all_celltypes{1,dataset_index}.(fieldss{cell_type})))];
            end
            
            hold on
            histogram(difference, 'BinWidth', 0.1, 'normalization', 'probability', 'FaceColor', plot_info.colors_celltypes(cell_type,:), ...
                'EdgeColor', plot_info.colors_celltypes(cell_type,:), 'FaceAlpha', 0.9, 'Normalization', 'count');
            xline(0, '--k', 'LineWidth', 2);
            
            % Calculate and plot the mean difference
            mean_diff = mean(difference);
            y_limits = ylim;
            plot(mean_diff, y_limits(2), 'v', 'MarkerSize', 6, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
            set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(cell_type, :));
            utils.set_current_fig;
            if nargin > 7
                xlim(varargin{1,1});
            else
                xlim([-1 1]);
            end
            box off;
            
            % Perform statistical test
            possible_tests = nchoosek(1:length(fieldss), 2);
            [p_val_mod(cell_type), ~, ~] = permutationTest_updatedcb(difference, zeros(length(difference), 1), 10000, 'paired', 1);
            
            % Apply Bonferroni correction
            if p_val_mod(cell_type) >= 0.05 / size(possible_tests, 1)
                p_val_mod(cell_type) = 1;
            end
        end
    end
    
    
    hold off;
    
%     % Set figure size
%     if horizontalmode == 1
%         % Create invisible axes for shared label
% %         % Set figure height higher to leave space for label
% %         set(gcf, 'units', 'points', 'position', [10, 100, 400, 320]);
% %         
% %         % Create invisible axes for global x-label
% %         han = axes('units', 'points', 'Position', [10, 30, 400, 100], 'Visible', 'off');
% %         han.XLabel.Visible = 'on';
% %         xlabel(han, string, 'FontSize', 7);
% 
% 
%     else
% %         set(gcf, 'units', 'points', 'position', [15, 100, 176, 400]);
% %         han = axes('units', 'points', 'Position',[15, 40, 138, 400],'Visible','off');
% %           xlabel(han, string, 'FontSize', 7);
%     end
    
    % Save figure if save_path is provided
    if ~isempty(save_path)
        mkdir(save_path); % Create directory if it doesn't exist
        cd(save_path);
        safe_string = regexprep(string, '[^\w\d_-]', '_');

        saveas(gcf, ['histogram_diff_index_sig_cells_' safe_string '.png']);
%         saveas(gcf, ['histogram_diff_index_sig_cells_' safe_string '.svg']);
        exportgraphics(gcf, ['histogram_diff_index_sig_cells_' safe_string '.pdf'], 'ContentType', 'vector'); % Save as PDF
    end
end
