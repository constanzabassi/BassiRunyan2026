chosen_mice = [1:25];
plot_info.plot_labels = {'Sounds','Sounds'}; %{'Stim','Ctrl'}; 
string_save = 'first_half'; %correct second half etc

if any(contains(plot_info.plot_labels,'Stim'))
    stim_info_to_use = stim_info; %stim_info_combined or stim_info
    neural_data_to_use = dff_st; %dff_st_combined or dff_st
    mod_to_use = 'mod'; %'mod_sounds' or 'mod'
    mod_params = params.(mod_to_use); %use 'prepost'/'ctrl'?
    save_to_use = params.info.savepath; %params.info.savepath or savepath_sounds

else
    stim_info_to_use = stim_info_combined; %stim_info_combined or stim_info
    neural_data_to_use = dff_st_combined; %dff_st_combined or dff_st
    mod_to_use = 'mod_sounds'; %'mod_sounds' or 'mod'
    mod_params = params.(mod_to_use); %use 'prepost'/'ctrl'?
    save_to_use = params.info.savepath_sounds; %params.info.savepath or savepath_sounds
end

%% Get SPECIFIED TRIALS!! (decide whether to plot correct/left turns/halves?
[divided_trials_stim, divided_trials_ctrl] = find_condition_context_trials(stim_trials_context, ctrl_trials_context,'correct'); %can be 'condition'/ 'correct' / 'left_turn'
%where divided_trials_stim{1} is any trials that are == 1 for whatever
%condition (if not applicable in passive/spont uses all trials)

num_divisions = 2;
[divided_trials_stim, divided_trials_ctrl] = divide_context_trials(stim_trials_context, ctrl_trials_context, num_divisions); %divides into halves where divided_trials_stim{1} is first division

%% FIND MOD INDEX USING SPECIFIC TRIALS
mod_params = params.(mod_to_use); %use 'prepost'/'ctrl'?
mod_params.mode = 'simple'; %because we are selecting trials (using all no balancing)

mod_params.savepath = fullfile(save_to_use, 'mod', mod_params.mod_type, mod_params.mode, string_save);

[mod_index_results_specified, sig_mod_boot_specified, mod_indexm_specified] = ...
    wrapper_mod_index_calculation(params.info, neural_data_to_use, mod_params.response_range, mod_params.mod_type, mod_params.mode, stim_trials_context, ctrl_trials_context,mod_params.nShuffles,mod_params.savepath, speed_trials_stim, speed_trials_ctrl);
%% MAKE PLOTS USING NEW MOD INDEX
mod_params.mod_threshold = .1;% 0 is no threshold applied
mod_params.chosen_mice = chosen_mice;
params.info.chosen_mice = chosen_mice;

%plot % modulated cells per context
sig_mod_boot_thr_specified = plot_pie_thresholded_mod_index(params.info, mod_params, mod_indexm_specified, sig_mod_boot_specified, sorted_cells,mod_params.savepath);

% Make plots of modulation index across contexts/cell types
% Set y-axis limits for the plots.
plot_info.y_lims = [-.4, .4];
% Set labels for plots.
plot_info.behavioral_contexts = {'Active','Passive'}; %decide which contexts to plot
overlap_labels = {'Active', 'Passive','Both'}; 
params.plot_info = plot_info;

%save directory
save_dir = [mod_params.savepath];

%generates heatmaps, cdf, box plots, scatter of abs(mod _index)
mod_index_stats_specified = plot_context_comparisons(contexts_to_compare,overlap_labels, mod_indexm_specified, sig_mod_boot_thr_specified, all_celltypes, params, save_dir);

% plot across datasets/mice
plot_info.y_lims = [-.2, .4];

%generates heatmaps, cdf, box plots, scatter of abs(mod _index)
[combined_sig_cells_specified, ~] = union_sig_cells(sig_mod_boot_thr_specified(:,1)', sig_mod_boot_thr_specified(:,2)', mod_indexm_specified);
mod_index_stats_specified_datasets = generate_mod_index_plots_datasets(params.info.chosen_mice, mod_indexm_specified, combined_sig_cells_specified, all_celltypes, params, save_dir);

