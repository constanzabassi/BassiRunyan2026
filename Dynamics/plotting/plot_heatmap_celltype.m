function plot_heatmap_celltype(ax, data_to_plot, plot_info, sorting_id, alignment_event_onset, adjusted_onsets)
% Plots heatmap in given axes, with or without sorting
axes(ax); hold(ax,'on');
if isempty(sorting_id)
    make_heatmap(data_to_plot, plot_info, alignment_event_onset, adjusted_onsets);
else
    make_heatmap_sorted(data_to_plot, plot_info, sorting_id, alignment_event_onset);
end
set(ax,'box','off','xtick',[]);
utils.set_current_fig(7);
% NaN transparency if image exists
hImg = findobj(ax, 'Type', 'Image');
if ~isempty(hImg)
    set(hImg, 'AlphaData', ~isnan(data_to_plot));
end
hold(ax,'off');
end