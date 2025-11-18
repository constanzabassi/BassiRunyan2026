function dataset_props_all = plot_celltype_pies(all_celltypes, pooled_cell_types, plot_mode, save_dir, celltype_colors)
% plot_celltype_pies(all_celltypes, pooled_cell_types, plot_mode, save_dir, celltype_colors)
%
% Compares fields inside all_celltypes with each field in pooled_cell_types.
% For each pooled field, makes a pie chart showing the % of neurons from each cell type.
%
% Inputs:
%   all_celltypes{dataset}.<type> = [ids]
%   pooled_cell_types{dataset}.<group> = [ids]
%   plot_mode: 'vertical' or 'horizontal'
%   save_dir (optional): directory to save figures
%   celltype_colors (optional): struct with fields matching cell types

if nargin < 4
    save_dir = [];
end


% Collect all cell type names
celltype_fields = fieldnames(all_celltypes{1});
% Collect all pooled field names (from first dataset)
pooled_fields = fieldnames(pooled_cell_types{1});
concat_fields = [pooled_fields{:}];

dataset_props_all = {};

% Prepare figure
figure(1); clf;

%total plots
% Get positions
if strcmp(plot_mode, 'vertical')
    positions = utils.calculateFigurePositions(15, 1, .2, .1); %numel(pooled_fields)
    figure_position = [100, 100, 300, 600];
else
    positions = utils.calculateFigurePositions(1, 15, .2, .1);
    figure_position = [100, 100, 600, 300];
end
set(gcf, 'Position', figure_position);
% Store results
proportions_avg = struct();

for p = 1:numel(pooled_fields)
    pooled_name = pooled_fields{p};
    dataset_props = nan(numel(pooled_cell_types), numel(celltype_fields));  % one row per dataset

    % Compute per-dataset proportions
    for d = 1:numel(pooled_cell_types)
        if ~isfield(pooled_cell_types{d}, pooled_name)
            continue;
        end
        if d == 18
            d
        end
        pooled_ids = pooled_cell_types{d}.(pooled_name);
        total = numel(pooled_ids);
        if total == 0, continue; end

        for f = 1:numel(celltype_fields)
            if ~isfield(all_celltypes{d}, celltype_fields{f})
                continue;
            end
            ids = all_celltypes{d}.(celltype_fields{f});
            dataset_props(d, f) = sum(ismember(pooled_ids, ids)) / total;  % fraction within dataset
        end
    end

    % Average across datasets (ignoring NaNs)
    proportions = nanmean(dataset_props, 1);
    proportions(isnan(proportions)) = 0;
    proportions_avg.(pooled_name) = proportions;

    % Create axes and plot pie
    ax = axes('Units', 'inches', 'Position', positions(p+6,:));
    hold(ax, 'on');

    % Plot pie
    if exist('celltype_colors', 'var') && ~isempty(celltype_colors)
        cols = celltype_colors;
        pie(ax, proportions);
        colormap(ax, cols);
    else
        pie(ax, proportions);
    end

    % Remove default text
    delete(findobj(ax, 'Type', 'text'));

    title(ax, upper(pooled_name), 'Interpreter', 'none', ...
          'FontWeight', 'normal', 'FontSize', 7);
    set(ax, 'XColor', 'none', 'YColor', 'none', 'Color', 'none');

    dataset_props_all{p} = dataset_props;
end

% % Loop through each pooled category
% for p = 1:numel(pooled_fields)
%     pooled_name = pooled_fields{p};
%     counts = zeros(1, numel(celltype_fields));
% 
%     % Combine across datasets
%     for d = 1:numel(pooled_cell_types)
%         if ~isfield(pooled_cell_types{d}, pooled_name)
%             continue;
%         end
%         pooled_ids = pooled_cell_types{d}.(pooled_name);
% 
%         for f = 1:numel(celltype_fields)
%             if ~isfield(all_celltypes{d}, celltype_fields{f})
%                 continue;
%             end
%             ids = all_celltypes{d}.(celltype_fields{f});
%             counts(f) = counts(f) + sum(ismember(pooled_ids, ids));
%         end
%     end
% 
%     % Normalize to proportions
%     total = sum(counts);
%     if total > 0
%         proportions = counts / total;
%     else
%         proportions = zeros(size(counts));
%     end
% 
%     % Create new axes for each pie chart
%     ax = axes('Units', 'inches', 'Position', positions(p+3,:));
%     hold(ax, 'on');
% 
%     % Plot pie on this axes
%     if ~isempty(celltype_colors)
% %         cols = zeros(numel(celltype_fields), 3);
%         cols = celltype_colors;
%         pie(ax, proportions);
%         colormap(ax, cols);
%         hText = findobj(ax, 'Type', 'text');  % find all text labels
%         set(hText, 'Color', 'w', ...          % white text
%                    'FontSize', 6, ...         % smaller font
%                    'FontWeight', 'bold');     % optional emphasis
%         
%         % Move them slightly inward toward the center
%         for i = 1:numel(hText)
%             pos = hText(i).Position;
%             hText(i).Position = 0.4 * pos; % scale inward (0.7 = 70% radius)
%         end
%         delete(hText);
% 
%     else
%         pie(ax, proportions);
% 
%         %move text in
%         hText = findobj(ax, 'Type', 'text');  % find all text labels
%         set(hText, 'Color', 'w', ...          % white text
%                    'FontSize', 6, ...         % smaller font
%                    'FontWeight', 'normal');     % optional emphasis
%         
%         % Move them slightly inward toward the center
%         for i = 1:numel(hText)
%             pos = hText(i).Position;
%             hText(i).Position = 0.4 * pos; % scale inward (0.7 = 70% radius)
%         end
% 
%         delete(hText); %delets all text
% 
%     end
% %     title(ax, sprintf('%s (n=%d)', pooled_name, total), 'Interpreter', 'none');
%     title(ax, upper(pooled_name), 'Interpreter', 'none','Fontweight','normal','Fontsize',7);
%     set(ax, 'XColor', 'none', 'YColor', 'none', 'Color', 'none');
% end
pause()
% Save if requested
if ~isempty(save_dir)
    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end
    exportgraphics(figure(1), fullfile(save_dir, ['pie_celltype_' concat_fields '_summary.pdf']), 'ContentType', 'vector');
end
end
