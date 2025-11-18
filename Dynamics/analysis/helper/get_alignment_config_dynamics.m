function [info, alignment, plot_info, bin_size,imaging_st,all_celltypes,imaging_passive] = get_alignment_config_dynamics(save_path, original_base_path, plot_info, passive_path)
%GET_ALIGNMENT_CONFIG  Configuration setup for alignment and plotting.
%
%   [info, alignment, plot_info, bin_size] = GET_ALIGNMENT_CONFIG()
%
%   Loads data info, imaging data, and cell type definitions, then
%   defines alignment and plotting parameters for analysis.

    imaging_passive = [];
    % ---------- Load Data ----------
    load(strcat(original_base_path,'\info.mat'), 'info');
    load(strcat(original_base_path,'\imaging_st.mat'), 'imaging_st');
    load(strcat(original_base_path,'\all_celltypes.mat'), 'all_celltypes');

    if ~isempty(passive_path)
        imaging_passive = load(strcat(passive_path,'\imaging_st.mat'), 'imaging_st').imaging_st;
    end

    % ---------- General Save Path ----------
    info.savepath = save_path;

    % ---------- Alignment Settings ----------
    alignment.conditions = [];                   % Empty = run all conditions [5:8]
    alignment.data_type = 'z_dff';               % 'dff', 'z_dff', or deconvolved
    alignment.type = 'all';                      % 'reward','turn','stimulus','ITI'
    alignment.field_to_separate = {'correct'};   % Separate trials by field
    alignment.number = 1:6;                      % 'reward','turn','stimulus'
    
    % Cell selections (PYR, SOM, PV)
    alignment.cells = [
        cellfun(@(x) x.pyr_cells, all_celltypes, 'UniformOutput', false);
        cellfun(@(x) x.som_cells, all_celltypes, 'UniformOutput', false);
        cellfun(@(x) x.pv_cells,  all_celltypes, 'UniformOutput', false)
    ];
    alignment.title = {'PYR', 'SOM', 'PV'};

    % ---------- Plot Info ----------
    plot_info.min_max = [-0.25, 1];              % [min max] for plotting
    plot_info.xlabel = [];
    plot_info.sorting_type = 1;
    plot_info.ylabel = 'Frames';
    plot_info.xlabel_events = {'S1  ','S2  ','S3  ','turn','reward','ITI'};
    plot_info.xlabel_events_stim_sound = {'S1 + Stim','S2','S3','turn','reward','ITI'};
    plot_info.xlabel_events_spont = {'Stim ','No Stim'}; 
    plot_info.max_decimal_value = 1000; %largest decimal showing to align y labels by
    
    % Note: define plot_info.colors_celltypes before using this function
    % (otherwise this line should be updated or commented)
    if isfield(plot_info, 'colors_celltypes')
        plot_info.colors_celltype = plot_info.colors_celltypes;
    else
        plot_info.colors_celltype = [];
    end

    % ---------- Other Parameters ----------
    bin_size = 1;

end
