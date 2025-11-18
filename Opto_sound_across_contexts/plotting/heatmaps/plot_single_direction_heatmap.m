function plot_single_direction_heatmap(data, sorted_idx, title_str, params)
    imagesc(data(sorted_idx,:));
    hold on;
    xline(params.stim_onset, '-w', 'LineWidth', 1.5);
    hold off;
    
    % Format plot
    title(title_str,'FontWeight','normal');
    xlabel('Time (s)');
    ylabel('Neuron #');
    colormap(params.colormap);
    clim(params.clim);
    
    % Add time axis in seconds
    [xticks_in, xticks_lab] = utils.x_axis_sec_aligned(...
        params.stim_onset, size(data,2), 1);
    xticks(xticks_in);
    xticklabels(xticks_lab);
end
