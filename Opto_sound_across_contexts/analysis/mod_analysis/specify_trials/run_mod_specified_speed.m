[speed_params,speed_params_single] = get_speed_params(1); %control_or_opto
speed_params.chosen_mice = [1:25];
plot_info.plot_labels = {'Sounds','Sounds'}; %{'Stim','Ctrl'}; % Alternative could be {'Left Sounds','Right Sounds'}
speed_range = [20,70];
mod_params.mod_type = 'simple';

if any(contains(plot_info.plot_labels,'Stim'))
    stim_info_to_use = stim_info; %stim_info_combined or stim_info
    neural_data_to_use = dff_st; %dff_st_combined or dff_st
    mod_to_use = 'mod'; %'mod_sounds' or 'mod'
    mod_params = params.(mod_to_use); %use 'prespose'/'separate'?
    save_to_use = params.info.savepath; %params.info.savepath or savepath_sounds

else
    stim_info_to_use = stim_info_combined; %stim_info_combined or stim_info
    neural_data_to_use = dff_st_combined; %dff_st_combined or dff_st
    mod_to_use = 'mod_sounds'; %'mod_sounds' or 'mod'
    mod_params = params.(mod_to_use); %use 'prespose'/'separate'?
    save_to_use = params.info.savepath_sounds; %params.info.savepath or savepath_sounds
end

%% Get aligned velocity
mouse_vel_aligned_sounds = run_velocity_opto_code_using_sound(speed_params.chosen_mice,params.info.mouse_date,params.info.serverid,speed_params.frames_before_event, speed_params.frames_after_event,stim_info_to_use); %using ctrl and sound only trials
mouse_vel_context = speed_cdf_across_contexts([],mouse_vel_aligned_sounds,plot_info,stim_trials_context,ctrl_trials_context,speed_params.chosen_mice,50:60); %frames from where to get speed from

%find trials within specified speed_range
[speed_trials_stim,speed_trials_ctrl] = find_speed_trials(mouse_vel_context,speed_range,stim_trials_context,ctrl_trials_context); %finds trials within certain speed range

%% FIND MOD INDEX USING SPECIFIC TRIALS
mod_params = params.(mod_to_use); %use 'prespose'/'separate'?
mod_params.mode = 'simple';

mod_params.savepath = fullfile(save_to_use, 'mod', mod_params.mod_type, mod_params.mode, 'speed2070');

[mod_index_results_specified, sig_mod_boot_specified, mod_indexm_specified] = ...
    wrapper_mod_index_calculation(params.info, neural_data_to_use, mod_params.response_range, mod_params.mod_type, mod_params.mode, stim_trials_context, ctrl_trials_context,mod_params.nShuffles,mod_params.savepath, speed_trials_stim, speed_trials_ctrl);
%% MAKE PLOTS USING NEW MOD INDEX
mod_params.mod_threshold = .1;% 0 is no threshold applied
mod_params.chosen_mice = speed_params.chosen_mice;
params.info.chosen_mice = speed_params.chosen_mice;

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
save_dir = [mod_params.savepath];%

%generates heatmaps, cdf, box plots, scatter of abs(mod _index)
mod_index_stats_specified = plot_context_comparisons(contexts_to_compare,overlap_labels, mod_indexm_specified, sig_mod_boot_thr_specified, all_celltypes, params, save_dir);

%% plot across datasets/mice
plot_info.y_lims = [-.2, .4];

%generates heatmaps, cdf, box plots, scatter of abs(mod _index)
[combined_sig_cells_specified, ~] = union_sig_cells(sig_mod_boot_thr_specified(:,1)', sig_mod_boot_thr_specified(:,2)', mod_indexm_specified);
mod_index_stats_specified_datasets = generate_mod_index_plots_datasets(params.info.chosen_mice, mod_indexm_specified, combined_sig_cells_specified, all_celltypes, params, save_dir);

