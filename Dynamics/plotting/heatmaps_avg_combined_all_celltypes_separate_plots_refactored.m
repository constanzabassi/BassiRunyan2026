function mouse_data_conditions = heatmaps_avg_combined_all_celltypes_separate_plots_refactored( ...
        imaging_st, plot_info, alignment, sorting_id, save_data_directory, bin_size)
% Two separate figures:
%   - Figure 90: 3 heatmaps (z_dff), tiled 3×1
%   - Figure 91: grand-average trace per cell type (alignment.data_type)
%
% Dependencies: same as combined version.
% ---------- Heatmaps figure ----------
figure(90); clf; colormap(viridis);
t = tiledlayout(3,1,"TileSpacing","tight");
set(gcf,'Units','points','Position',[100 100 170 216]);
set(gcf,'Units','inches', 'Position', [1,1,2.3,1.9]) %[1,1,3,2.4]);
alignment_data_type_original = alignment.data_type;
alignment.data_type = 'z_dff';
num_celltypes = 3;
num_mice = size(imaging_st,2);
num_nans = 2;
last_left_pad = []; last_right_pad = [];
for ce = 1:num_celltypes
    celltype_list = alignment.cells(ce,:);
    all_plot_data = cell(num_mice,1);
    all_sort_data = cell(num_mice,1);
    for m = 1:num_mice
        cell_ids = celltype_list{m};
        out = process_mouse_data(imaging_st{m}, alignment, cell_ids, alignment.conditions);
        all_plot_data{m} = out.plot_data;
        all_sort_data{m} = out.sort_data;
        last_left_pad  = out.left_pad;
        last_right_pad = out.right_pad;
    end
    sorting_id = compute_sorting_id(all_sort_data);
    data_to_plot = cat(1, all_plot_data{:});
    [data_to_plot, adjusted_onsets] = prepare_heatmap_data(data_to_plot, last_left_pad, last_right_pad, alignment.number);
    event_onsets = determine_onsets(last_left_pad, last_right_pad, alignment.number);
    if isempty(event_onsets), alignment_event_onset = 1; else, alignment_event_onset = adjusted_onsets; end
    ax = nexttile(ce);
    plot_heatmap_celltype(ax, data_to_plot, plot_info, sorting_id, alignment_event_onset, adjusted_onsets);
    if length(alignment_event_onset)>4
        add_vertical_line_reward(ax,[alignment_event_onset(5)-1,alignment_event_onset(5)]);
    end
    ylabel(alignment.title{ce});
    %add color bar
    cb = add_skinny_colorbar(ax, 6, 0.3,0.15,0.05);
    ylabel(alignment.title{ce});

    %move y label to be aligned with first label
    if ce == 1; yposition = ax.YLabel.Position(1);end %assuming pyr first!
    if size(data_to_plot,1) < plot_info.max_decimal_value %adjust plots so they align to the ylabel of the one showing most decimal
        current_y_pos = ax.YLabel.Position;
        ax.YLabel.Position = [yposition, current_y_pos(2), current_y_pos(3)];
    end
    utils.set_current_fig(7);
end
alignment_event_onset(4) = alignment_event_onset(4)-5; %-5 bc plot is narrow and it makes it hard to read!
set(gca,'xtick',alignment_event_onset,'xticklabel',plot_info.xlabel_events,'xticklabelrotation',45);
addScaleBar(gca, 30, "1 sec")

% addScaleBar(gca, 30, "1 sec")
% ---------- Grand-average figure ----------
alignment.data_type = alignment_data_type_original;
[binned_data_all, adjusted_onsets_bin, nan_pos_bin, num_nans, binss] = ...
    compute_grand_average_bins(imaging_st, alignment, bin_size, []);
figure(91); clf;
ax = axes;
plot_grand_average(ax, binned_data_all, plot_info, adjusted_onsets_bin, nan_pos_bin, num_nans, [1 length(binss)]);
if strcmp(alignment.data_type,'z_dff')
    ylabel({'Mean activity (z-scored)'},'FontSize', 7);
end
% set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', [1,1,1.25,1.2]);
adjusted_onsets_bin(4) = adjusted_onsets_bin(4)-5; %-5 bc plot is narrow and it makes it hard to read!
set(gca,'xtick', adjusted_onsets_bin, 'xticklabel', plot_info.xlabel_events, 'xticklabelrotation', 45);
set(gca, 'Units', 'inches', 'Position', [1,1,1.55,1.2]);
addScaleBar(gca, 30, "1 sec")

% addScaleBar(gca, 30, "1 sec")

utils.set_current_fig(7);
% save both if path provided
if ~isempty(save_data_directory)
    mkdir(save_data_directory);
    image_string1 = sprintf('heatmaps_only_condition_%s', mat2str(alignment.conditions));
    image_string2 = sprintf('avgtrace_condition_%s_type_%s', mat2str(alignment.conditions), alignment.data_type);
%     exportgraphics(figure(90), fullfile(save_data_directory, [image_string1 '_datasets.pdf']), 'ContentType','vector');
%     exportgraphics(figure(91), fullfile(save_data_directory, [image_string2 '_datasets.pdf']), 'ContentType','vector');

    %size 2
    exportgraphics(figure(90),fullfile([save_data_directory '/' image_string1 'sizing2_datasets.pdf']), 'ContentType', 'vector');
    
    exportgraphics(figure(91),fullfile([save_data_directory '/' image_string2 'sizing2_datasets.pdf']), 'ContentType', 'vector');
end
end