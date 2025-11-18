function params = get_heatmap_params(context_labels,savepath)
    params = struct();
    params.sort_method = 'peak';
    params.response_window = 62:122%92;  % 1s after stim onset
    params.clim = [-.5 1];           % Typical range for z-scores
    params.stim_onset = 61;
    params.colormap = 'viridis';
    params.sort_method = 'peak'; %'latency'/'peak'
    if ~isempty(context_labels)
        params.context_labels = context_labels;
    else
        params.context_labels = {'Active','Passive','Spont'};
    end
    if ~isempty(savepath)
        params.savepath = savepath;
    else
        params.savepath = 'V:\Connie\results\opto_sound_2025\context\heatmaps';
    end
end