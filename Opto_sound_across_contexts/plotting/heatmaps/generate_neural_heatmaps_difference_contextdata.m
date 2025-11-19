function generate_neural_heatmaps_difference_contextdata(context_data, sig_mod_boot, chosen_mice, params, type, context_to_plot, difference_params, varargin)
% Generate heatmaps from context_data using z-scored data
%
% Inputs:
%   context_data      - Structure with .dff (or .deconv) organized as {context,dataset}
%                       Each element has .stim and .ctrl fields: [trials x neurons x frames]
%   sig_mod_boot      - Optional: significant/modulated neurons per dataset
%   chosen_mice       - Dataset indices to include
%   params            - Plotting parameters
%   type              - String for type of plot
%   context_to_plot   - Array of context indices to plot
%   difference_params - Structure with .type ('stim_sub_ctrl_all', etc.) and optional frame ranges
%
% Optional input:
%   minmax            - Color axis limits

nContexts = length(context_to_plot);

% Store data across contexts
data_by_context = cell(1,nContexts);

if nargin > 7
    minmax = varargin{1};
else
    minmax = [-0.1, 0.5];
end

params = get_heatmap_params([],params.savepath);
positions = utils.calculateFigurePositions(1, 7, .5, []);

context_count = 0;
for context = context_to_plot
    context_count = context_count + 1;

    temp = []; 
    temp2 = [];
    for dataset_index = chosen_mice
        % Number of cells
        cellCount = size(context_data.dff{1,dataset_index}.stim,2);

        % Determine modulated cells
        if ~isempty(sig_mod_boot)
            mod_cells = sig_mod_boot{1,dataset_index};
            save_name = 'sig_cells';
        else
            mod_cells = 1:cellCount;
            save_name = 'all_cells';
        end

        % Use all trials in stim/ctrl (get mean across trials)
        temp = [temp; squeeze(mean(context_data.dff{context,dataset_index}.stim(:, mod_cells, :), 1))];
        temp2 = [temp2; squeeze(mean(context_data.dff{context,dataset_index}.ctrl(:, mod_cells, :), 1))];
    end

    % Compute differences
    switch difference_params.type
        case 'stim_sub_ctrl_all'
            data_diff = temp - mean(temp2,2);
            frames_used = 'all';
        case 'stim_sub_ctrl_post'
            ctrl_post =mean(temp2(:,difference_params.post_frames),2);
            data_diff = temp - ctrl_post;
            frames_used = num2str([difference_params.post_frames(1), difference_params.post_frames(end)]);
        case 'stim_sub_pre'
            stim_pre = mean(temp(:,difference_params.pre_frames),2);
            data_diff = temp - stim_pre;
            frames_used = num2str([difference_params.pre_frames(1), difference_params.pre_frames(end)]);
        case 'ctrl_sub_pre'
            ctrl_pre =  mean(temp2(:,difference_params.pre_frames),2);
            data_diff = temp2 - ctrl_pre;
            frames_used = num2str([difference_params.pre_frames(1), difference_params.pre_frames(end)]);
        otherwise
            error('Unknown difference type specified.');
    end

    data_by_context{context_count} = squeeze(data_diff);

    % Sorting by first context
    if context_count == 1
        sort_data = data_diff;
        [sorted_idx, ~] = sort_neurons(sort_data, params);
    end
end

% Plot heatmaps
figure(1); clf;
for context = 1:nContexts
    subplot(1, nContexts, context)
    plot_single_direction_heatmap(data_by_context{context}, sorted_idx, params.context_labels{context_to_plot(context)}, params);
    
    caxis(minmax);
    colorbar('off');

    if context == nContexts
        cb = colorbar;
        cb.Label.String = 'Difference ΔF/F';
        cb.Label.Rotation = 270;
        curr_position = cb.Label.Position;
        cb.Label.Position = [curr_position(1)+.5, curr_position(2:3)];
        caxis(minmax);
    end
    set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(context, :));
    utils.set_current_fig;

    if context == nContexts
        curr_position = cb.Label.Position;
        if nContexts == 1
            to_add = 6;
        else
            to_add = 4;
        end
        cb.Label.Position = [curr_position(1)+to_add, curr_position(2:3)];
    end
end

% Save figure if path exists
if isfield(params, 'savepath')
    ctx_str = sprintf('%d', context_to_plot);
    save_fname = sprintf('heatmap_difference_%s_%s_%s_%s_%s.png', difference_params.type, frames_used, type, save_name, ctx_str);
    saveas(gcf, fullfile(params.savepath, save_fname));

    save_fname = sprintf('heatmap_difference_%s_%s_%s_%s_%s.pdf', difference_params.type, frames_used, type, save_name, ctx_str);
    exportgraphics(gcf, fullfile(params.savepath, save_fname), 'ContentType', 'vector', 'BackgroundColor', 'none');
end

end
