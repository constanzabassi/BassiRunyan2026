function [mouse_data_conditions, sorting_id_updated_datasets] = ...
    heatmaps_avg_combined_selected_cells_refactored(imaging_st, plot_info, alignment, sorting_id, save_data_directory, bin_size, sig_mod_boot, avg_across_datasets, active_passive)
% Selected-cells version:
%   - alignment.cells{ce,m} still gives the "pool" per cell type × mouse,
%     but we additionally filter by sig_mod_boot{m} to pick the selected neurons.
%   - Supports active (1) or passive (else) alignment via find_align_info_updated(..., 30 [, 2]).
%
% Behavior:
%   - Heatmaps use mean across trials_plot for each mouse, concatenate across mice
%   - Bottom tile: average trace (either across datasets avg or per-mouse SEM)
%
% Dependencies: concat_neuron_data for joining per-mouse matrices.
if nargin < 9, active_passive = 1; end
% Derive bins + event onsets from one dataset in the chosen mode
if active_passive == 1
    [ai0, af0, lp0, rp0] = find_align_info_updated(imaging_st{1,1}, 30);
else
    [ai0, af0, lp0, rp0] = find_align_info_updated(imaging_st{1,1}, 30, 2);
end
aligned0 = align_behavior_data(imaging_st{1,1}, ai0, af0, lp0, rp0, alignment, 1:10);
binss = 1:bin_size:(size(aligned0,3)-bin_size);
event_onsets = determine_onsets(lp0, rp0, alignment.number);
num_nans = 2;
if numel(event_onsets) > 4
    adjusted_event_onsets = find(histcounts(event_onsets, binss));
    nan_insert_positions  = find(histcounts(101, binss));
    for i = 1:length(nan_insert_positions)
        adjusted_event_onsets(adjusted_event_onsets >= nan_insert_positions(i)) = ...
            adjusted_event_onsets(adjusted_event_onsets >= nan_insert_positions(i)) + num_nans - 1;
    end
else
    adjusted_event_onsets = find(histcounts(event_onsets, binss));
    nan_insert_positions  = [];
end
% ==== Build the heatmaps per condition ====
sorting_id_updated_datasets = {};
mouse_data_conditions = {};
if ~isempty(alignment.conditions) && length(alignment.conditions) >= 1
    for con = 1:length(alignment.conditions)
        figure(90); clf; hold on; colormap(viridis);
        t = tiledlayout(4,1,"TileSpacing","tight");
        set(gcf,'Units','points','Position',[100 100 170 216]);
        for ce = 1:3
            celltype_all = alignment.cells(ce,:);
            mouse_data     = {};
            mouse_data_sort= {};
            mean_mouse_data = {};
            mean_mouse_sort = {};
            for m = 1:length(sig_mod_boot)
                imaging = imaging_st{1,m};
                [all_conditions, ~] = divide_trials_updated(imaging, alignment.field_to_separate);
                % selected cells = intersection of sig_mod_boot with pool for this celltype/mouse
                pool_ids = celltype_all{m};
                sel_in_pool = find(ismember(sig_mod_boot{m}, pool_ids));
                sel_cells   = sig_mod_boot{m}(sel_in_pool);
                if isempty(sel_cells), continue; end
                if active_passive == 1
                    [ai, af, lp, rp] = find_align_info_updated(imaging, 30);
                else
                    [ai, af, lp, rp] = find_align_info_updated(imaging, 30, 2);
                end
                aligned = align_behavior_data(imaging, ai, af, lp, rp, alignment, sel_cells);
                c_trials_all = all_conditions{alignment.conditions(con),1};
                if isempty(c_trials_all), continue; end
                rng(1);
                perm = randperm(length(c_trials_all));
                half = floor(length(c_trials_all)/2);
                if half == 0, half = max(1, floor(length(c_trials_all)/2)); end
                trials_sort = c_trials_all(perm(1:half));
                trials_plot = c_trials_all(perm(half+1:end));
                if isempty(trials_plot), trials_plot = c_trials_all(perm(1:half)); end
                mouse_data{m,con}      = aligned(trials_plot,:,:);
                mouse_data_sort{m,con} = aligned(trials_sort,:,:);
            end
            % per-mouse mean → concat across mice (neurons × time)
            for m = 1:length(mouse_data)
                if ~isempty(mouse_data{m, con})
                    mean_mouse_data{m} = squeeze(mean(mouse_data{m, con}, 1, 'omitnan'));
                    mean_mouse_sort{m} = squeeze(mean(mouse_data_sort{m, con}, 1, 'omitnan'));
                else
                    mean_mouse_data{m} = [];
                    mean_mouse_sort{m} = [];
                end
            end
            out_plot = concat_neuron_data(mean_mouse_data);
            out_sort = concat_neuron_data(mean_mouse_sort);
            % sorting index
            if isempty(out_sort)
                sorting_id_updated = [];
            else
                [~, pk] = max(out_sort, [], 2);
                [~, sorting_id_updated] = sort(pk, 'ascend');
            end
            sorting_id_updated_datasets{con, ce} = sorting_id_updated;
            ax = nexttile(ce); hold on;
            if isempty(sorting_id)
                make_heatmap_sorted(out_plot, plot_info, sorting_id_updated, adjusted_event_onsets); % using adjusted onsets from binned space
            else
                make_heatmap_sorted(out_plot, plot_info, sorting_id{ce}, adjusted_event_onsets);
            end
            if length(alignment_event_onset)>4
                add_vertical_line_reward(ax,[adjusted_event_onsets(5)-1,adjusted_event_onsets(5)]);
            end
            set(gca, 'box','off','xtick',[]);
            ylabel(alignment.title{ce});
            %add color bar
            cb = add_skinny_colorbar(ax, 6, 0.3,0.05);
            ylabel(alignment.title{ce});
            %move y label to be aligned with first label
            if size(data_to_plot,1) < plot_info.max_decimal_value
                current_y_pos = ax.YLabel.Position;
                ax.YLabel.Position = [-25.304563660938243, current_y_pos(2), current_y_pos(3)];
            end
            utils.set_current_fig(7);
        end
        % bottom tile: average trace for this condition
        ax = nexttile(4); hold on;
        for ce = 1:3
            if avg_across_datasets == 0
                data = mean_mouse_data_celltypes{ce}; % neurons×time concatenated across mice
                % If you want mice×time, you’d need to stack per-mouse means separately.
                % Here we just treat neurons as samples for visualization (same as your spont file’s approach).
                mu  = mean(data, 1, 'omitnan');
                sem = std(data, 0, 1, 'omitnan') ./ sqrt(size(data,1));
                shadedErrorBar(1:size(data,2), mu, sem, ...
                    'lineProps', {'color', plot_info.colors_celltype(ce,:), 'LineWidth',1.2});
            else
                % if you want strict mice×time SEM, compute via compute_grand_average_bins with selected-cells logic
                warning('avg_across_datasets==1 path not implemented here; set to 0 or add a compute_grand_average_bins_selected.');
            end
        end
        set(gca,'xtick', adjusted_event_onsets, 'xticklabel', plot_info.xlabel_events, 'xticklabelrotation',45);
        ylabel({'Mean';'activity'}); set(gca,'box','off'); utils.set_current_fig(7);
        addScaleBar(gca, 30, "1 sec")
        hold off;
        if ~isempty(save_data_directory)
            mkdir(save_data_directory);
            image_string = sprintf('heatmaps_avgtrace_condition_%d_selectedcells', alignment.conditions(con));
            exportgraphics(figure(90), fullfile(save_data_directory, [image_string '.pdf']), 'ContentType','vector');
        end
    end
else
    % no-conditions path can mirror above but concatenating all trials; omitted for brevity
    warning('No-conditions path in selected-cells refactor is not implemented in this snippet.');
end
end
% function [mouse_data_conditions, sorting_id_updated_datasets] = ...
%     heatmaps_avg_combined_selected_cells_spont_refactored(context_data, plot_info, alignment, sorting_id, save_data_directory, bin_size, sig_mod_boot, avg_across_datasets)
% % Spontaneous alignment version (using context_data structs)
% % Mirrors your spont file: conditions pulled from context_data.dff fields
% adjusted_event_onsets = 61;  % your convention for spont
% mouse_data_conditions = {};
% sorting_id_updated_datasets = {};
% possible_conditions = fields(context_data.dff{1,1}); % expect: stim/ctrl/etc.
% for conditions = 1:2
%     for celltypes = 1:3
%         for dataset = 1:length(sig_mod_boot)
%             % compute per dataset binned_data_all like your original, if desired
%             % omitted for brevity (you had a mean over dims already)
%         end
%     end
% end
% if ~isempty(alignment.conditions) && length(alignment.conditions) >= 1
%     for con = 1:length(alignment.conditions)
%         figure(90); clf; hold on; colormap(viridis);
%         t = tiledlayout(4,1,"TileSpacing","tight");
%         set(gcf,'Units','points','Position',[100 100 170 216]);
%         for ce = 1:3
%             celltype_all = alignment.cells(ce,:);
%             mouse_data = {}; mouse_data_sort = {};
%             mean_mouse_data = {}; mean_mouse_sort = {};
%             for dataset = 1:length(sig_mod_boot)
%                 sel_pool = celltype_all{dataset};
%                 sel_in_pool = find(ismember(sig_mod_boot{dataset}, sel_pool));
%                 sel_cells   = sig_mod_boot{dataset}(sel_in_pool);
%                 if isempty(sel_cells), continue; end
%                 imaging = context_data.dff{3, dataset};
%                 aligned = imaging.(possible_conditions{con+2})(:, sel_cells, :); % use precomputed aligned spont context
%                 trials_all = 1:size(aligned,1);
%                 rng(1);
%                 perm = randperm(length(trials_all));
%                 half = floor(length(trials_all)/2);
%                 if half == 0, half = max(1, floor(length(trials_all)/2)); end
%                 trials_sort = trials_all(perm(1:half));
%                 trials_plot = trials_all(perm(half+1:end));
%                 if isempty(trials_plot), trials_plot = trials_all(perm(1:half)); end
%                 mouse_data_sort{dataset,con} = aligned(trials_sort,:,:);
%                 mouse_data{dataset,con}      = aligned(trials_plot,:,:);
%             end
%             for d = 1:length(mouse_data)
%                 if ~isempty(mouse_data{d, con})
%                     mean_mouse_data{d} = squeeze(mean(mouse_data{d, con}, 1, 'omitnan'));
%                     mean_mouse_sort{d} = squeeze(mean(mouse_data_sort{d, con}, 1, 'omitnan'));
%                 else
%                     mean_mouse_data{d} = [];
%                     mean_mouse_sort{d} = [];
%                 end
%             end
%             data_to_plot = concat_neuron_data(mean_mouse_data);
%             sorting_src  = concat_neuron_data(mean_mouse_sort);
%             if isempty(sorting_src)
%                 sorting_id_updated = [];
%             else
%                 [~, pk] = max(sorting_src, [], 2);
%                 [~, sorting_id_updated] = sort(pk, 'ascend');
%             end
%             sorting_id_updated_datasets{con, ce} = sorting_id_updated;
%             ax = nexttile(ce); hold on;
%             if isempty(sorting_id)
%                 make_heatmap_sorted(data_to_plot, plot_info, sorting_id_updated, adjusted_event_onsets);
%             else
%                 make_heatmap_sorted(data_to_plot, plot_info, sorting_id{ce}, adjusted_event_onsets);
%             end
%             set(gca, 'box','off','xtick',[]);
%             ylabel(alignment.title{ce}); utils.set_current_fig(7);
%             %add color bar
%             cb = add_skinny_colorbar(ax, 6, 0.3,0.05);
%             ylabel(alignment.title{ce});
%             %move y label to be aligned with first label
%             if size(data_to_plot,1) < plot_info.max_decimal_value
%                 current_y_pos = ax.YLabel.Position;
%                 ax.YLabel.Position = [-25.304563660938243, current_y_pos(2), current_y_pos(3)];
%             end
%             utils.set_current_fig(7);
%             mean_mouse_data_celltypes{ce} = data_to_plot; %#ok<AGROW>
%         end
%         % bottom tile average trace for this spont condition
%         ax = nexttile(4); hold on;
%         for ce = 1:3
%             data = mean_mouse_data_celltypes{ce}; % neurons × time
%             mu   = mean(data, 1, 'omitnan');
%             sem  = std(data, 0, 1, 'omitnan') ./ sqrt(size(data,1));
%             shadedErrorBar(1:size(data,2), mu, sem, ...
%                 'lineProps', {'color', plot_info.colors_celltype(ce,:), 'LineWidth',1.2});
%         end
%         set(gca,'xtick', adjusted_event_onsets, 'xticklabel', plot_info.xlabel_events, 'xticklabelrotation',45);
%         ylabel({'Mean';'activity'});
%         set(gca,'box','off'); utils.set_current_fig(7);
%         hold off;
%         if ~isempty(save_data_directory)
%             mkdir(save_data_directory);
%             image_string = sprintf('heatmaps_spont_avgtrace_condition_%d', alignment.conditions(con));
%             exportgraphics(figure(90), fullfile(save_data_directory, [image_string '_datasets.pdf']), 'ContentType','vector');
%         end
%     end
% else
%     % No-conditions spont path (mirroring your original) could be added if needed
%     warning('No-conditions path for spont not implemented in this refactor.');
% end
% end