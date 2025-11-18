%includes all datasets being analyzed, frame parameters, mod index
%parameters
params = experiment_config(); 
plot_info = plotting_config(); %plotting params
params.plot_info = plot_info;
plot_info.plot_labels = {'Sounds','Sounds'}; %{'Stim','Ctrl'}; % Alternative could be {'Sounds','Sounds'}


if contains(plot_info.plot_labels,'Stim')
    stim_info_to_use = stim_info; %stim_info_combined or stim_info
    neural_data_to_use = dff_st; %dff_st_combined or dff_st
    mod_to_use = 'mod'; %'mod_sounds' or 'mod'
    mod_params = params.(mod_to_use); %use 'prespose'/'separate'?
    save_to_use = params.info.savepath; %params.info.savepath or savepath_sounds
    mod_params.mod_type = 'ctrl_num';
else
    stim_info_to_use = stim_info_combined; %stim_info_combined or stim_info
    neural_data_to_use = dff_st_combined; %dff_st_combined or dff_st
    mod_to_use = 'mod_sounds'; %'mod_sounds' or 'mod'
    mod_params = params.(mod_to_use); %use 'prespose'/'separate'?
    save_to_use = params.info.savepath_sounds; %params.info.savepath or savepath_sounds
    mod_params.mod_type = 'prepost_num';
end

%% FIND MOD INDEX USING SPECIFIC TRIALS
mod_params.mode = 'separate';
mod_params.savepath = fullfile(save_to_use, 'mod', mod_params.mod_type, mod_params.mode);

[mod_index_results_specified, sig_mod_boot_specified, mod_indexm_specified] = ...
    wrapper_mod_index_calculation(params.info, neural_data_to_use, mod_params.response_range, mod_params.mod_type, mod_params.mode, stim_trials_context, ctrl_trials_context,mod_params.nShuffles,mod_params.savepath);
%% MAKE PLOTS USING NEW MOD INDEX
mod_params.mod_threshold = 0;% 0 is no threshold applied
mod_params.chosen_mice = speed_params.chosen_mice;

%plot % modulated cells per context
sig_mod_boot_thr_specified = plot_pie_thresholded_mod_index(params.info, mod_params, mod_indexm_specified, sig_mod_boot_specified, sorted_cells,mod_params.savepath);
% sig_mod_boot_thr_spont = plot_pie_thresholded_mod_index(info, mod_params, mod_indexm(:,3), sig_mod_boot(:,3), sorted_cells,fullfile(mod_params.savepath,'spont_sig'));

% Make plots of modulation index across contexts/cell types
% Set y-axis limits for the plots.
plot_info.y_lims = [-.4, .4];
% Set labels for plots.
plot_info.behavioral_contexts = {'Active','Passive'}; %decide which contexts to plot
overlap_labels = {'Active', 'Passive','Both'}; %{'Active', 'Passive','Both'}; % {'Active', 'Passive','Both'}; %{'Active', 'Passive','Spont','Both'}; %
params.plot_info = plot_info;
params.info.chosen_mice = [1:25];

%save directory
save_dir = [mod_params.savepath];% '/spont_sig'];% '/spont_sig']; %[info.savepath '/mod/' mod_params.mod_type '/spont_sig']; % Set directory to save figures.

%generates heatmaps, cdf, box plots, scatter of abs(mod _index)
mod_index_stats_specified = plot_context_comparisons(contexts_to_compare,overlap_labels, mod_indexm, sig_mod_boot_thr_specified, all_celltypes, params, save_dir);
