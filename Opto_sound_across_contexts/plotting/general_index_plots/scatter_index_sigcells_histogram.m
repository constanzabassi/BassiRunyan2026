function modl_fit = scatter_index_sigcells_histogram(sig_mod_boot, all_celltypes, index, plot_info, save_path, string1, string2, varargin)
    if nargin > 7
        minmax = varargin{1,1};
    else
        minmax = [-1, 1];
    end

    % Create figure
    figure(2324); clf;
    
    % Define main axes
    mainAx = axes('Position', [0.22 0.25 0.60 0.60]);
    hold(mainAx, 'on');
    plot(mainAx, [minmax(1), minmax(2)], [minmax(1), minmax(2)], '--', 'Color', [0.5 0.5 0.5]);
%     xline(0.1,'--k')
%         xline(-0.1,'--k')
%         yline(0.1,'--k')
%         yline(-0.1,'--k')

    % Axes for histograms
    topAx = axes('Position', [0.15 0.81 0.65 0.15]); % X-axis histogram
    rightAx = axes('Position', [0.81 0.15 0.15 0.65]); % Y-axis histogram
    % Adjust histogram axes accordingly
    topAx.Position = [mainAx.Position(1), ...
                      mainAx.Position(2) + mainAx.Position(4) + 0.01, ...
                      mainAx.Position(3), 0.13];
    
    rightAx.Position = [mainAx.Position(1) + mainAx.Position(3) + 0.01, ...
                        mainAx.Position(2), ...
                        0.13, mainAx.Position(4)];

    hold(topAx, 'on'); hold(rightAx, 'on');
    axis(topAx, 'tight'); axis(rightAx, 'tight');
    topAx.XTick = []; rightAx.YTick = [];
    set(topAx, 'XLim', minmax, 'YTick', []);
    set(rightAx, 'YLim', minmax, 'XTick', []);

    modl_fit = cell(1, 3);
    celltype_fields = fields(all_celltypes{1});
    n_celltypes = length(celltype_fields);

    for cell_type = 1:n_celltypes
        all_x = []; all_y = [];
        for dataset_index = 1:length(all_celltypes)
            if ~isempty(sig_mod_boot)
                selected_cells = sig_mod_boot{dataset_index}(ismember(sig_mod_boot{dataset_index}, ...
                    all_celltypes{dataset_index}.(celltype_fields{cell_type})));
            else
                selected_cells = all_celltypes{dataset_index}.(celltype_fields{cell_type});
            end
            x = index{dataset_index,1}(selected_cells);
            y = index{dataset_index,2}(selected_cells);

            % Scatter plot
            scatter(mainAx, x, y, 'MarkerEdgeColor', plot_info.colors_celltypes(cell_type, :), ...
                'MarkerEdgeAlpha', .7, 'LineWidth', 1.5, 'SizeData',20);

            % Collect data for fitting and histograms
            all_x = [all_x; x(:)];
            all_y = [all_y; y(:)];

        end
        


        if ~isempty(all_x)
            modl_fit{cell_type} = fitlm(all_x, all_y);
            text(mainAx, minmax(1)+0.05, minmax(2) +0.05 - 0.1 * cell_type, ...
                sprintf('R² = %.3f', modl_fit{cell_type}.Rsquared.Ordinary), ...
                'Color', plot_info.colors_celltypes(cell_type, :), 'FontSize', 6);

            % Plot histograms
%             histogram(topAx, all_x,'Normalization','probability','BinWidth', 0.05, 'BinLimits', minmax, 'FaceColor', plot_info.colors_celltypes(cell_type, :), ...
%                 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'Orientation', 'vertical');
% 
%             histogram(rightAx, all_y,'Normalization','probability','BinWidth', 0.05, 'BinLimits', minmax, 'FaceColor', plot_info.colors_celltypes(cell_type, :), ...
%                 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'Orientation', 'horizontal');

            histogram(topAx, all_x, 'Normalization','probability','BinWidth', 0.1,'BinWidth', 0.05,'BinLimits', minmax, 'EdgeColor', plot_info.colors_celltypes(cell_type, :), ...
                'Orientation', 'vertical','DisplayStyle','stairs', 'LineWidth',1.2);
            histogram(rightAx, all_y,'Normalization','probability','BinWidth', 0.1, 'BinWidth', 0.05,'BinLimits', minmax, 'EdgeColor', plot_info.colors_celltypes(cell_type, :), ...
                'Orientation', 'horizontal','DisplayStyle','stairs', 'LineWidth',1.2);
        end
    end


    % Finalize plot
    xlabel(mainAx, string1);
    ylabel(mainAx, string2);
    xlim(mainAx, minmax);
    ylim(mainAx, minmax);
    box(mainAx, 'off');
    % Remove x and y axis for topAx (X-axis histogram)
    topAx.XTick = [];
    topAx.YTick = [];
    topAx.Visible = 'off';
    % Remove x and y axis for rightAx (Y-axis histogram)
    rightAx.XTick = [];
    rightAx.YTick = [];
    rightAx.Visible = 'off';

    box(rightAx, 'off');
    set(mainAx, 'FontSize', 8)
    set(gcf, 'Position', [100, 100, 200, 200]);  % [left bottom width height]
    


    % Save figure
    sig_cel_string = ~isempty(sig_mod_boot);
    if ~isempty(save_path)
        if ~exist(save_path, 'dir')
            mkdir(save_path);
        end
        saveas(gcf, fullfile(save_path, ['scatter_index_sigcells_histogram' num2str(sig_cel_string) '_' string1 '_' string2 '.png']));
        saveas(gcf, fullfile(save_path, ['scatter_index_sigcells_histogram' num2str(sig_cel_string) '_' string1 '_' string2 '.svg']));
        exportgraphics(gcf, fullfile(save_path, ['scatter_index_sigcells_histogram' num2str(sig_cel_string) '_' string1 '_' string2 '.pdf']), 'ContentType', 'vector');
    end
end
