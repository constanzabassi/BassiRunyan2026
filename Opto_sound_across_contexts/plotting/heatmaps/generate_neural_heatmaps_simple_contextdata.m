function generate_neural_heatmaps_simple_contextdata(context_data, sig_mod_boot, chosen_mice, ...
                                         params, type, context_to_plot, x_label, varargin)
% generate_neural_heatmaps_simple(context_data, ...)
%
% Updated to use:
%   context_data.dff{ctx,dataset}.z_stim   [trials x neurons x frames]
%   context_data.dff{ctx,dataset}.z_ctrl   [trials x neurons x frames]
%
% No stim/ctrl trial indexing needed anymore.

nContexts = length(context_to_plot);

% Store data for plotting
data_by_context      = cell(1, nContexts);
data_by_context_ctrl = cell(1, nContexts);

params = get_heatmap_params([], params.savepath);
positions = utils.calculateFigurePositions(1, 7, .5, []);

% Optional color limits
if nargin > 7
    minmax = varargin{1};
else
    minmax = [-0.5, 1];
end

% Optional panel width
if nargin > 8
    positions = utils.calculateFigurePositions(1, varargin{2}, .5, []);
end


% -------------------------
%  BUILD CONTEXT MATRICES
% -------------------------
context_count = 0;
for ctx = context_to_plot
    context_count = context_count + 1;

    temp  = [];
    temp2 = [];

    for dataset = chosen_mice

        zstim = context_data.dff{ctx, dataset}.z_stim;
        zctrl = context_data.dff{ctx, dataset}.z_ctrl;

        cellCount = size(zstim, 2);

        % Select modulated or all cells
        if ~isempty(sig_mod_boot)
            mod_cells = sig_mod_boot{dataset};
            save_name = 'sig_cells';
        else
            mod_cells = 1:cellCount;
            save_name = 'all_cells';
        end

        if isempty(mod_cells)
            warning("Dataset %d has no modulated cells.", dataset);
            continue
        end

        % Mean across trials
        mean_stim = squeeze(mean(zstim(:, mod_cells, :), 1)); % [neurons x frames]
        mean_ctrl = squeeze(mean(zctrl(:, mod_cells, :), 1));

        % Concatenate across datasets
        temp  = [temp;  mean_stim];
        temp2 = [temp2; mean_ctrl];
    end

    data_by_context{context_count}      = temp;
    data_by_context_ctrl{context_count} = temp2;

    % Sorting reference = first context
    if context_count == 1
        [sorted_idx,  ~] = sort_neurons(temp,  params);
        [sorted_idx2, ~] = sort_neurons(temp2, params);
    end
end


% -------------------------
%         PLOT STIM
% -------------------------
figure(1); clf;

for i = 1:nContexts
    subplot(1, nContexts, i)

    ctx = context_to_plot(i);
    plot_single_direction_heatmap(data_by_context{i}, sorted_idx, ...
                                  params.context_labels{ctx}, params);
    
    if ~isempty(x_label)
        xlabel(x_label);
    end
    utils.set_current_fig;
    caxis(minmax);

    if i == nContexts
        cb = colorbar;
        cb.Label.String = 'Z-scored ΔF/F';
        cb.Label.Rotation = 270;
        curr = cb.Label.Position;
        cb.Label.Position = [curr(1)+0.5, curr(2:3)];
        
    end

    set(gca, 'FontSize', 7, 'Units','inches','Position',positions(i,:));
    
    if i == nContexts
        curr = cb.Label.Position;
        shift = 0 + 2*(nargin>8);
        cb.Label.Position = [curr(1)+shift, curr(2:3)];
        cb.Position(1) = cb.Position(1) - 0.02;   % move cb left

    end
    utils.set_current_fig;

end

% Save STIM plots
if isfield(params, 'savepath')
    ctx_str = sprintf('%d', context_to_plot);
%     saveas(gcf, fullfile(params.savepath, sprintf('heatmap_stim_%s_%s_%s.png', type, save_name, ctx_str)));
    exportgraphics(gcf, fullfile(params.savepath, sprintf('heatmap_stim_%s_%s_%s.pdf', type, save_name, ctx_str)), ...
                   'ContentType', 'vector', 'BackgroundColor', 'none');
end


% -------------------------
%         PLOT CTRL
% -------------------------
figure(2); clf;

for i = 1:nContexts
    subplot(1, nContexts, i)

    ctx = context_to_plot(i);
    plot_single_direction_heatmap(data_by_context_ctrl{i}, sorted_idx2, ...
                                  params.context_labels{ctx}, params);

    if ~isempty(x_label)
        xlabel(x_label);
    end

    utils.set_current_fig;
    caxis(minmax);
    colorbar('off');

    if i == nContexts
        cb = colorbar;
        cb.Label.String = 'Z-scored ΔF/F';
        cb.Label.Rotation = 270;
        curr = cb.Label.Position;
        cb.Label.Position = [curr(1)+0.5, curr(2:3)];
    end

    set(gca, 'FontSize', 7, 'Units','inches','Position',positions(i,:));
    
    if i == nContexts
        curr = cb.Label.Position;
        shift = 0 + 2*(nargin>8);
        cb.Label.Position = [curr(1)+shift, curr(2:3)];
        cb.Position(1) = cb.Position(1) - 0.02;   % move cb left
    end
    utils.set_current_fig;
end

% Save CTRL plots
if isfield(params, 'savepath')
    ctx_str = sprintf('%d', context_to_plot);
%     saveas(gcf, fullfile(params.savepath, sprintf('heatmap_ctrl_%s_%s_%s.png', type, save_name, ctx_str)));
    exportgraphics(gcf, fullfile(params.savepath, sprintf('heatmap_ctrl_%s_%s_%s.pdf', type, save_name, ctx_str)), ...
                   'ContentType', 'vector', 'BackgroundColor', 'none');
end

end
