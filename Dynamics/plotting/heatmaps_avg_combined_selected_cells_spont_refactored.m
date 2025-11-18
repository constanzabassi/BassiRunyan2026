function [mouse_data_conditions, sorting_id_updated_datasets] = ...
    heatmaps_avg_combined_selected_cells_spont_refactored( ...
        context_data, plot_info, alignment, sorting_id, ...
        save_data_directory, bin_size, sig_mod_boot, ...
        avg_across_datasets, do_plot)

% Spontaneous version (context_data already aligned to event)
% Added: do_plot flag (default = true). When false, only computes
% sorting_id_updated_datasets and mouse_data_conditions without plotting.

if nargin < 9 || isempty(do_plot)
    do_plot = true;
end

%% create grand avg plot!
adjusted_event_onsets = 61;   % spont convention
ncelltypes = size(alignment.cells,1);
possible_conditions = fields(context_data.dff{1,1});

% binned_data_all: mean across trials & cells for each dataset/condition/celltype
alignment.original_data_type = alignment.data_type;
alignment.data_type = 'z_dff';
binned_data_all = compute_binned_data_all (context_data,ncelltypes,alignment,sig_mod_boot,possible_conditions);

sorting_id_updated_datasets = {};
mouse_data_conditions       = {};

%% CASE 1: alignment.conditions specified
if ~isempty(alignment.conditions) && length(alignment.conditions) >= 1

    for con = 1:length(alignment.conditions)

        % ===== plotting setup (only if do_plot) =====
        if do_plot
            figure(90); clf;
            hold on; colormap(viridis);

            t = tiledlayout(4,1,"TileSpacing","tight"); %#ok<NASGU>
            set(gcf,'Units','points','Position',[100 100 170 216]);
        end

        mean_mouse_data_celltypes = cell(1,3);

        for ce = 1:ncelltypes
            % Initialize
            celltype = {alignment.cells{ce,:}};
            mouse_data        = {};
            mouse_data_sort   = {};
            mean_mouse_data   = {};
            mean_mouse_sort   = {};

            % ---- collect data per dataset ----
            for dataset = 1:length(sig_mod_boot)
                c = alignment.conditions(con);
                imaging = context_data.dff{3, dataset};
                celltypes_permouse = celltype{dataset};

                sig_idx = find(ismember(sig_mod_boot{dataset}, celltypes_permouse));
                sig_cells_permouse = sig_mod_boot{dataset}(sig_idx);
                if isempty(sig_idx), continue; end

                % Already aligned spont context:
                % trials × sig_cells × time
                aligned_imaging = imaging.(possible_conditions{c+2})(:, sig_cells_permouse, :);

                trials_all = 1:size(aligned_imaging,1);
                n_trials   = length(trials_all);

                rng(1); % reproducible
                perm = randperm(n_trials);
                half = floor(n_trials / 2);

                % split trials into sort vs plot halves
                trials_sort = trials_all(perm(1:half));
                trials_plot = trials_all(perm(half+1:end));
                if isempty(trials_plot)
                    trials_plot = trials_sort;
                end

                mouse_data_sort{dataset,con} = aligned_imaging(trials_sort,:,:);  % for sorting
                mouse_data{dataset,con}      = aligned_imaging(trials_plot,:,:);  % for plotting
                mouse_data_conditions{dataset,con,ce} = mouse_data{dataset,con};
            end

            % ---- average across trials per dataset, then concat ----
            for dataset = 1:length(mouse_data)
                if ~isempty(mouse_data{dataset, con})
                    mean_mouse_data{dataset} = squeeze(mean(mouse_data{dataset, con}, 1, 'omitnan'));  % cells×time
                    mean_mouse_sort{dataset} = squeeze(mean(mouse_data_sort{dataset, con}, 1, 'omitnan'));
                else
                    mean_mouse_data{dataset} = [];
                    mean_mouse_sort{dataset} = [];
                end
            end

            out_data  = concat_neuron_data(mean_mouse_data);  % neurons×time
            sort_data = concat_neuron_data(mean_mouse_sort);  % neurons×time

            % ---- sorting index ----
            if isempty(sort_data)
                sorting_id_updated = [];
            else
                [~, sorting_id_updated] = max(sort_data, [], 2);
                [~, sorting_id_updated] = sort(sorting_id_updated, 'ascend');
            end

            sorting_id_updated_datasets{con, ce} = sorting_id_updated;

            % ---- plotting for this cell type (heatmap) ----
            if do_plot
                ax = nexttile(ce); hold on;

                if isempty(sorting_id)
                    make_heatmap_sorted_task(out_data, plot_info, sorting_id_updated, adjusted_event_onsets);
                else
                    make_heatmap_sorted_task(out_data, plot_info, sorting_id{ce}, adjusted_event_onsets);
                end

                set(gca, 'box', 'off', 'xtick', []);
                set(gca,'fontsize', 7,'FontName','Arial');
                ylabel({alignment.title{ce}});

                % colorbar styling (your original)
                cb = colorbar(ax, 'eastoutside');
                cb.FontSize = 6;

                cb_pos = cb.Position;
                cb_pos(3) = cb_pos(3) * 0.3;
                cb.Position = cb_pos;

                cb_pos(1) = cb_pos(1) + 0.16;
                cb_pos(2) = cb_pos(2) + 0.05;
                cb_pos(4) = cb_pos(4) - 0.05;
                cb.Position = cb_pos;

                % Make NaNs transparent
                hImg = findobj(gca, 'Type', 'Image');
                set(hImg, 'AlphaData', ~isnan(out_data));

                mean_mouse_data_celltypes{ce} = out_data;

            end
            ax.Tag = sprintf('heat_ax_%d', ce);

            
        end % ce loop

        % ---- bottom tile: average trace plot for this condition ----
        if do_plot
            alignment.data_type = alignment.original_data_type;  
            ax = nexttile(4); 
            ax.Tag = sprintf('heat_ax_%d', 4);
            hold on;

            if avg_across_datasets == 0
                for ce = 1:ncelltypes
                     mean_mouse_data_celltypes{ce} = compute_avg_across_neurons(context_data, sig_mod_boot, con,possible_conditions, alignment,  {alignment.cells{ce,:}});
                end
                plot_grand_average(ax, mean_mouse_data_celltypes, plot_info, adjusted_event_onsets, [], [], [1 size(binned_data_all,4)],alignment);
            else
                binned_data_all = compute_binned_data_all (context_data,ncelltypes,alignment,sig_mod_boot,possible_conditions);
                plot_grand_average(ax, binned_data_all, plot_info, adjusted_event_onsets, [], [], [1 size(binned_data_all,4)],alignment);
            end

            set(gca,'xtick', adjusted_event_onsets, ...
                'xticklabel', plot_info.xlabel_events_spont{con}, 'xticklabelrotation', 45);

            set(gcf,'Units','points','Position',plot_info.position);
            addScaleBar(gca, 30, "1 sec")

            %adjust previous plots
            adjust_y_label_position(4,1:3,10);



            if ~isempty(save_data_directory)
                mkdir(save_data_directory);
                image_string = sprintf('heatmaps_spont_avgtrace_condition_%d_avgdatasets%d', ...
                    alignment.conditions(con), avg_across_datasets);
                saveas(90, fullfile(save_data_directory, [image_string '_datasets.fig']));
                exportgraphics(figure(90), fullfile(save_data_directory, [image_string '_datasets.pdf']), ...
                    'ContentType','vector');
            end
        end

    end % con loop

%% CASE 2: no alignment.conditions (your original "else" path)
else

    if do_plot
        figure(90); clf;
        colormap(viridis);
        t = tiledlayout(4,1,"TileSpacing","tight"); %#ok<NASGU>
        set(gcf,'Units','points','Position',[100 100 170 216]);
    end

    num_nans = 0; %#ok<NASGU>  % kept for consistency with your original include_nans usage
    nan_insert_positions = []; %#ok<NASGU>

    for ce = 1:ncelltypes
        celltype = {alignment.cells{ce,:}};
        mouse_data      = {};
        mouse_data_sort = {};
        mean_mouse_data = {};
        mean_mouse_sort = {};

        for dataset = 1:length(sig_mod_boot)
            imaging = context_data.dff{3, dataset};
            celltypes_permouse = celltype{dataset};

            sig_idx = find(ismember(sig_mod_boot{dataset},celltypes_permouse));
            sig_cells_permouse = sig_mod_boot{dataset}(sig_idx);
            if isempty(sig_idx), continue; end

            aligned_imaging = [imaging.stim(:,sig_cells_permouse,:); ...
                               imaging.ctrl(:,sig_cells_permouse,:)];

            trials_all = 1:size(aligned_imaging,1);
            n_trials   = length(trials_all);
            rng(1);
            perm = randperm(n_trials);
            half = floor(n_trials / 2);

            trials_sort = trials_all(perm(1:half));
            trials_plot = trials_all(perm(half+1:end));
            if isempty(trials_plot)
                trials_plot = trials_sort;
            end

            mouse_data_sort{dataset} = aligned_imaging(trials_sort,:,:);
            mouse_data{dataset}      = aligned_imaging(trials_plot,:,:);
            mouse_data_conditions{dataset,ce} = mouse_data{dataset};
        end

        mean_mouse_data  = cellfun(@(x) squeeze(mean(x,1)), mouse_data,      'UniformOutput',false);
        mean_mouse_sort  = cellfun(@(x) squeeze(mean(x,1)), mouse_data_sort, 'UniformOutput',false);

        out_data  = concat_neuron_data(mean_mouse_data);
        sort_data = concat_neuron_data(mean_mouse_sort);

        if isempty(sort_data)
            sorting_id_updated = [];
        else
            [~, sorting_id_updated] = max(sort_data, [], 2);
            [~, sorting_id_updated] = sort(sorting_id_updated, 'ascend');
        end
        sorting_id_updated_datasets{1,ce} = sorting_id_updated;

        if do_plot
            ax = nexttile(ce); hold on;

            if isempty(sorting_id)
                make_heatmap_sorted(out_data, plot_info, sorting_id_updated, adjusted_event_onsets);
            else
                make_heatmap_sorted(out_data, plot_info, sorting_id{ce}, adjusted_event_onsets);
            end

            set(gca, 'box','off','xtick',[]);
            set(gca,'fontsize', 7,'FontName','Arial');
            ylabel({alignment.title{ce}});

            cb = colorbar(ax, 'eastoutside');
            cb.FontSize = 6;
            cb_pos = cb.Position;
            cb_pos(3) = cb_pos(3) * 0.3;
            cb.Position = cb_pos;

            cb_pos(1) = cb_pos(1) + 0.16;
            cb_pos(2) = cb_pos(2) + 0.05;
            cb_pos(4) = cb_pos(4) - 0.05;
            cb.Position = cb_pos;

            hImg = findobj(gca, 'Type','Image');
            set(hImg, 'AlphaData', ~isnan(out_data));

            % bottom trace tile
            ax = nexttile(4); hold on;
            alignment.data_type = alignment.original_data_type;  

            if avg_across_datasets == 0
                for ce = 1:ncelltypes
                     mean_mouse_data_celltypes{ce} = compute_avg_across_neurons(context_data, sig_mod_boot, con,possible_conditions, alignment,  {alignment.cells{ce,:}});
                end
                plot_grand_average(ax, mean_mouse_data_celltypes, plot_info, adjusted_event_onsets, [], [], [1 size(binned_data_all,4)]);
            else
                binned_data_all = compute_binned_data_all (context_data,ncelltypes,alignment,sig_mod_boot,possible_conditions);
                plot_grand_average(ax, binned_data_all, plot_info, adjusted_event_onsets, [], [], [1 size(binned_data_all,4)]);
            end
            set(gca,'xtick', adjusted_event_onsets, ...
                'xticklabel', plot_info.xlabel_events_spont{con}, 'xticklabelrotation', 45);

            set(gcf,'Units','points','Position',plot_info.position);
            addScaleBar(gca, 30, "1 sec")

            %adjust previous plots
            adjust_y_label_position(4,1:3,10);
        end
    end

    if do_plot
        hold off;
        set(gcf,'Units','points','Position',plot_info.position);
        set(gca,'xtick',adjusted_event_onsets, ...
                'xticklabel',plot_info.xlabel_events,'xticklabelrotation',45);

        if ~isempty(save_data_directory)
            mkdir(save_data_directory);
            image_string = sprintf('heatmaps_spont_avgtrace_all_conditions_avgdatasets%d', ...
                                   avg_across_datasets);
            saveas(90, fullfile(save_data_directory, [image_string '_datasets.fig']));
            exportgraphics(figure(90), fullfile(save_data_directory, [image_string '_datasets.pdf']), ...
                'ContentType','vector');
        end
    end
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
%     for celltypes = 1:ncelltypes
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
%         for ce = 1:ncelltypes
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
%         for ce = 1:ncelltypes
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