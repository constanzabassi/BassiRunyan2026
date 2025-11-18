function mouse_data_conditions = heatmaps_avg_combined_all_celltypes_refactored( ...
        imaging_st, plot_info, alignment, sorting_id, save_data_directory, bin_size)
% Combined figure: 3 heatmaps (z_dff) + 1 grand-average trace (alignment.data_type)
% Dependencies: divide_trials_updated, find_align_info_updated, align_behavior_data,
%               determine_onsets, include_nans, make_heatmap(_sorted), shadedErrorBar
figure(90); clf; colormap(viridis);
t = tiledlayout(4,1,"TileSpacing","tight");
set(gcf,'Units','points','Position',[100 100 170 216]);
set(gcf,'Units','inches','Position',[1,1,3.32,2.25]);
alignment_data_type_original = alignment.data_type;
% Heatmaps always z_dff
alignment.data_type = 'z_dff';
num_celltypes = 3;
num_mice = size(imaging_st,2);
num_nans = 2;
mouse_data_conditions = cell(num_mice, max(1,length(alignment.conditions)));
last_left_pad = []; last_right_pad = [];
last_aligned_framesize = [];
for ce = 1:num_celltypes
    celltype_list = alignment.cells(ce,:);
    all_plot_data = cell(num_mice,1);
    all_sort_data = cell(num_mice,1);
    for m = 1:num_mice
        cell_ids = celltype_list{m};
        out = process_mouse_data(imaging_st{m}, alignment, cell_ids, alignment.conditions);
        all_plot_data{m} = out.plot_data;     % neurons × time
        all_sort_data{m} = out.sort_data;     % trials × neurons × time
        mouse_data_conditions{m,:} = out.plot_data_per_condition;
        last_left_pad  = out.left_pad;
        last_right_pad = out.right_pad;
        last_aligned_framesize = size(out.plot_data, 2);
    end
    % sorting order
    sorting_id = compute_sorting_id(all_sort_data);
    % concatenate across mice
    data_to_plot = cat(1, all_plot_data{:}); % neurons_all × time
    % prepare heatmap (NaN gaps + onsets)
    [data_to_plot, adjusted_onsets] = prepare_heatmap_data( ...
        data_to_plot, last_left_pad, last_right_pad, alignment.number);
    event_onsets = determine_onsets(last_left_pad, last_right_pad, alignment.number);
    if isempty(event_onsets), alignment_event_onset = 1; else, alignment_event_onset = adjusted_onsets; end

    % plot tile
    ax = nexttile(ce);
    plot_heatmap_celltype(ax, data_to_plot, plot_info, sorting_id, alignment_event_onset, adjusted_onsets);
    %add color bar
    cb = add_skinny_colorbar(ax, 6, 0.3,0.05);
    if length(alignment_event_onset)>4
        add_vertical_line_reward(ax,[alignment_event_onset(5)-1,alignment_event_onset(5)]);
    end
    ylabel(alignment.title{ce});
    %move y label to be aligned with first label
    if size(data_to_plot,1) < plot_info.max_decimal_value
        current_y_pos = ax.YLabel.Position;
        ax.YLabel.Position = [-25.304563660938243, current_y_pos(2), current_y_pos(3)];
    end
    utils.set_current_fig(7);
end
% ==== Grand-average bottom tile: switch back to original data_type ====
alignment.data_type = alignment_data_type_original;
% Compute binned grand average (mice × celltype × time)
[binned_data_all, adjusted_onsets_bin, nan_pos_bin, num_nans, binss] = ...
    compute_grand_average_bins(imaging_st, alignment, bin_size, []);
ax = nexttile(4);
plot_grand_average(ax, binned_data_all, plot_info, adjusted_onsets_bin, nan_pos_bin, num_nans, [1 length(binss)],alignment);
set(gca,'xtick',adjusted_onsets_bin,'xticklabel',plot_info.xlabel_events,'xticklabelrotation',45);
utils.set_current_fig(7);
addScaleBar(gca, 30, "1 sec")
% save if path provided
if ~isempty(save_data_directory)
    mkdir(save_data_directory);
    image_string = sprintf('heatmaps_condition_%s', mat2str(alignment.conditions));
    exportgraphics(figure(90), fullfile(save_data_directory, [image_string '_datasets.pdf']), 'ContentType','vector');
end
end