%COMPARING TO CONTROL MICE!
mod_params = params.mod;
mod_params.savepath = fullfile(params.info.savepath, 'mod', mod_params.mod_type, mod_params.mode)

mod_params.mod_threshold = .1;% 0 is no threshold applied
mod_params.threshold_single_side = 0;% 0 is no threshold applied
mod_params.chosen_mice = 1:25;

%'V:\Connie\results\opto_sound_2025\context\test'
sig_mod_boot_thr_all = get_thresholded_sig_cells(params.info, mod_params, mod_indexm, sig_mod_boot, sorted_cells,all_celltypes, [],1);

%%
% opto_only_cells = separate_sig_mod_boot_thr(:,3); %og_mod_sig_mod_boot_thr'; %sig_mod_boot_thr(:,3); %use spontaneously defined photostim neurons
chosen_mice = [1:24];
save_dir = ['V:\Connie\results\opto_sound_2025\context\mod\ctrl_num\separate/prepost_spont_sig_cells']; %['V:\Connie\results\opto_sound_2025\context\mod\prepost\simple/opto_only/'];% [mod_params.savepath '/opto_only/']; % '/spont_sig'];% '/spont_sig']; %[info.savepath '/mod/' mod_params.mod_type '/spont_sig']; % Set directory to save figures.
mod_index_to_test = mod_indexm; %separate_mod_indexm;

[context_mod_all, ~, ~, ~, celltypes_ids] = ...
    organize_sig_mod_index_contexts_celltypes(chosen_mice, mod_index_to_test, sig_mod_boot_thr(:,3), all_celltypes,plot_info.celltype_names);

plot_info.y_lims = [-.5, .5];
% Set labels for plots.
plot_info.plot_labels = {'Stim','Ctrl'}; % Alternative could be {'Left Sounds','Right Sounds'}
plot_info.behavioral_contexts = {'Active','Passive'}; %decide which contexts to plot
overlap_labels = {'Active', 'Passive','Both'}; %{'Active', 'Passive','Both'}; % {'Active', 'Passive','Both'}; %{'Active', 'Passive','Spont','Both'}; %
params.plot_info = plot_info;
params.info.chosen_mice = [3];

%save directory

% Generate visualization suite
[mod_index_stats] = generate_mod_index_plots(context_mod_all, celltypes_ids, params, save_dir);

plot_info.y_lims = [-.2, .4];
mod_index_stats_datasets = generate_mod_index_plots_datasets(chosen_mice, mod_index_to_test, sig_mod_boot_thr(:,3)', all_celltypes, params, save_dir);

%%
modl_fit = scatter_index_sigcells(opto_only_cells, all_celltypes, [{ctrl_separate_mod_indexm{:,1}}',{separate_mod_indexm{:,1}}'], plot_info, [], 'Stim - Sound Separate', 'Prepost Separate',[-.5,1]);
%%
opto_only_cells_global = convert_indices_local_to_global(opto_only_cells,num_cells);
curr_context = 1;
diff_mod_comparison = [[ctrl_separate_mod_indexm{:,curr_context}] - [separate_mod_indexm{:,curr_context}]];
diff_mod_comparison_opto_only = diff_mod_comparison(opto_only_cells_global);
[a,sorted_opto_n] = sort(abs(diff_mod_comparison_opto_only));
sorted_opto_n = sorted_opto_n(end:-1:1);

%% plot example cells to see why the indices are so different!
[local_indices, dataset_ids] = convert_indices_global_to_local(opto_only_cells_global, num_cells);

context_to_plot = [1:3];
ex_n = 9;
dataset_to_plot = dataset_ids(sorted_opto_n(ex_n));
sig_neurons_to_plot = local_indices(sorted_opto_n(ex_n));
save_string = ['opto_only_ctrl_prepost_comparison'];
modulation_type = 1; %positive or negative

plot_info.plot_mode= 'both'; %'stim or ctrl
plot_info.plot_avg = 1;
wrapper_mod_index_single_plots(params.info, dff_st, stim_trials_context, ctrl_trials_context, mod_index_results, dataset_to_plot,context_to_plot , sig_neurons_to_plot, modulation_type, save_string, plot_info);
