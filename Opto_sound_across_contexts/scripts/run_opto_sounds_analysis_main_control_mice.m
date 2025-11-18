addpath(genpath('C:\Code\Github\Opto_sounds_analysis'))
% Setup analysis parameters
%includes all datasets being analyzed, frame parameters, mod index
%parameters
params = experiment_config(); 
plot_info = plotting_config(); %plotting params
params.plot_info = plot_info;

%% Pool activity across mice
[all_celltypes, dff_st, deconv_st, stim_info, ...
 mouse_context_tr, deconv_st_interp, alignment_frames] = ...
    pool_activity(params.info_ctrl.mouse_date, params.info_ctrl.serverid, 'spont_stim\60', [], [60,60],0);

% Save basic information
% Save variables with consistent paths
filename = fullfile(params.info_ctrl.savepath, 'data_info');
save(fullfile(filename, 'info.mat'), 'params');
save(fullfile(filename, 'alignment_frames.mat'), 'alignment_frames');
save(fullfile(filename, 'mouse_context_tr.mat'), 'mouse_context_tr');
save(fullfile(filename, 'stim_info.mat'), 'stim_info');

% % Process cell types
[num_cells, sorted_cells] = organize_pooled_celltypes_updated(dff_st, all_celltypes);
% [num_cells, sorted_cells] = organize_pooled_celltypes(dff_st, all_celltypes); %gives index relative to all datasets
% save(fullfile(filename, 'sorted_cells.mat'), 'sorted_cells');

% Separate neural data into contexts (organizes original _st into cell arrays separated by
% context using mouse_context_trials)
%organized context.dff{context,mouse};
[context_data.dff,stim_trials_context,ctrl_trials_context] = separate_structure_singlecontext(dff_st);
% [context_data.dff,stim_trials_context,ctrl_trials_context] = separate_structure_2context(dff_st,mouse_context_tr,stim_info);%  context.dff{context,mouse}
% [context_data.deconv] = separate_structure_2context(deconv_st,mouse_context_tr,stim_info);%  context.dff{context,mouse}
% [context_data.deconv_interp] = separate_structure_2context(deconv_st_interp,mouse_context_tr,stim_info);%  context.dff{context,mouse}
% save(fullfile(filename, "ctrl_trials_context.mat"),"ctrl_trials_context");
% save(fullfile(filename, "stim_trials_context.mat"),"stim_trials_context");
% save(fullfile(filename, "context_data.mat"),"context_data",'-v7.3');
%% Get average responses
% % Setup parameters
% avg_params = struct(...
%     'response_window', 1:122, ...
%     'trial_type', 'stim', ...
%     'mode', 'separate');
% 
% % Get averages
% [avg_results_stim ,avg_results_by_dataset_stim,avg_results_ctrl, avg_results_by_dataset_ctrl] = wrapper_trial_averaging(params.info, dff_st,stim_trials_context,ctrl_trials_context, avg_params, [params.info.savepath '/avg/'],1);
% % generate_heatmaps(context_data, sorted_cells, info);
% generate_neural_heatmaps(dff_st, stim_trials_context, ctrl_trials_context,[],[1:8], params, 'opto');


%% Calculate modulation indices
mod_params = params.mod;
mod_params.mode = 'simple';
mod_params.mod_type = 'prepost';
mod_params.savepath = fullfile(params.info_ctrl.savepath, mod_params.mod_type,  mod_params.mode)

[mod_index_results, sig_mod_boot, mod_indexm] = ...
    wrapper_mod_index_calculation_single_context(params.info_ctrl, dff_st, mod_params.response_range, mod_params.mod_type, mod_params.mode, stim_trials_context, ctrl_trials_context,mod_params.nShuffles, mod_params.savepath);
% %% Generate single cell plots
% dataset_to_plot = 9;
% context_to_plot = [1:2];
% sig_neurons_to_plot = [];
% modulation_type = 1; %positive or negative
%  plot_info = params.plot_info;
%  plot_info.plot_mode = 'both';% stim ctrl or both
%  plot_info.plot_avg = 0;
%  plot_info.caxis = 0;
% 
%  wrapper_mod_index_single_plots(params.info, dff_st, stim_trials_context, ctrl_trials_context, mod_index_results,...
%      dataset_to_plot, context_to_plot,sig_neurons_to_plot,modulation_type, 'opto',plot_info);
%  %single trial plots
%  dataset_to_plot = 9;
% context_to_plot = [3]; %spont
% modulation_type = 1; %positive or negative
% plot_info.plot_mode = 'stim';% stim ctrl or both
% plot_info.avg_traces = 1;
% 
%  wrapper_mod_index_single_plots(params.info, dff_st, stim_trials_context, ctrl_trials_context, mod_index_results,...
%      dataset_to_plot, context_to_plot,sig_neurons_to_plot,modulation_type, 'opto',plot_info);
% 
%  modulation_type = -1;
%   wrapper_mod_index_single_plots(params.info, dff_st, stim_trials_context, ctrl_trials_context, mod_index_results,...
%      dataset_to_plot, context_to_plot,sig_neurons_to_plot,modulation_type, 'opto',plot_info);
% 
% plot_info.line_colors = [0.3,0.2,0.6 ; 1,0.7,0];
% plot_info.plot_mode = 'both';% stim ctrl or both
% context_to_plot = [1];
%  wrapper_mod_index_single_plots(params.info, dff_st, stim_trials_context, ctrl_trials_context, mod_index_results,...
%      dataset_to_plot, context_to_plot,sig_neurons_to_plot,1, 'opto',plot_info);

%% Compare modulation indices across contexts and cell types
mod_params.mod_threshold = .1;% 0 is no threshold applied
mod_params.chosen_mice = [1:length(dff_st)];

%plot % modulated cells per context
mod_params.threshold_single_side = 0;
sig_mod_boot_thr = get_thresholded_sig_cells(params.info_ctrl, mod_params, mod_indexm, sig_mod_boot, sorted_cells, all_celltypes, [],0);

%PLOT MODULATED NEURONS in the spontaneous context
context_num = 1;
[percentage_stats] = plot_sig_mod_pie(mod_params, mod_indexm, sig_mod_boot_thr, context_num, 'W:\Connie\results\Bassi2025\fig3\control_mice\', 'vertical',all_celltypes);
S = unwrap_cells_in_struct(percentage_stats)
table_1 = struct2table_recursive(S,'',{'bootstat','ci'});

%heatmap of mean
params.savepath = 'W:\Connie\results\Bassi2025\fig3\control_mice\';
params.context_labels = {'Spont'};
generate_neural_heatmaps_simple(dff_st, stim_trials_context, ctrl_trials_context,[],[1:length(dff_st)], params, 'opto',context_num,[-.5,1],5); %sig_mod_boot_thr'
% MAKE AVG PLOTS OF TRACES (DOES NOT SEPARATE LEFT VS RIGHT AVG ACROSS ALL)
savepath = 'W:\Connie\results\Bassi2025\fig3\control_mice\avg_traces\';

context_num = 1; %only one context
sig_all_cells = cellfun(@(x) x.all_cells , all_celltypes , 'UniformOutput' , false)'; %getting all neurons
wrapper_avg_cell_type_traces_single_context(context_data.dff,all_celltypes,context_num,mod_indexm,sig_all_cells,mod_params,savepath,'opto_dff',plot_info,mod_indexm);
% wrapper_avg_cell_type_traces(context_data.dff,all_celltypes,mod_indexm,[],mod_params,[],'opto_dff',plot_info,mod_indexm);
%%
%plot % overlap of modulated cells across contexts!
% ORGANIZE MODULATION INDICES AND CELL TYPE INDICES ACROSS DATASETS
[context_mod_all, chosen_pyr, chosen_mcherry, chosen_tdtom, celltypes_ids] = ...
    organize_sig_mod_index_contexts_celltypes([1:length(dff_st)], mod_indexm, [], all_celltypes,{'All'});
%% comparing with real photostim mice!
[context_mod_all, ~, ~, ~, ~] = organize_sig_mod_index_contexts_celltypes(...
        [1:8], mod_indexm, [], all_celltypes,params.plot_info.celltype_names);

%load experimental stim mice!
context_mod_stim_datasets = load('W:\Connie\results\Bassi2025\fig3\mod\prepost\separate\all_neurons\mod_index_data.mat').context_mod_all;
mod_index_stim = load('V:\Connie\results\opto_sound_2025\context\mod\prepost\separate\mod_indexm.mat').mod_indexm;
save_dir1 = 'W:\Connie\results\Bassi2025\fig3\control_mice';
mod_index_heatmap(save_dir1, context_mod_stim_datasets(:,3), params.plot_info, ...
        [1:24], [-.4,.4]);
[percentage_stats] = plot_sig_mod_pie(mod_params, mod_index_stim(:,3), [], 1, 'W:\Connie\results\Bassi2025\fig3\control_mice\', 'vertical',all_celltypes);
%do CDF comparisons?
[cdf_stats, KW_Test] = cdf_mod_index_stim_vs_ctrl_datasets(save_dir1,  context_mod_stim_datasets(:,3), context_mod_all, ...
                       {'Spont'}, params.plot_info.colors_stimctrl, {'-','--'}, {'Photostim','Control'}, 'all',[-.2,.2]);
save(fullfile(save_dir, 'stim_ctrl_cdf_stats.mat'), 'cdf_stats');

%save stats into table
S = unwrap_cells_in_struct(cdf_stats);
table_2 = struct2table_recursive(S,'stim_ctr_cdf',{'bootstat','ci'});

supplementary_table_3_stim_ctrl_mice = [table_1; table_2];
save(fullfile(save_dir, strcat('supplementary_table_3_stim_ctrl_mice.mat')), 'supplementary_table_3_stim_ctrl_mice');
writetable(supplementary_table_3_stim_ctrl_mice, fullfile(save_dir, strcat('supplementary_table_3_stim_ctrl_mice.csv')));

%% Make plots of modulation index across contexts/cell types (separating into datasets or mice) 
%USING ALL CELLS
% Set y-axis limits for the plots.
params.info_ctrl.chosen_mice = 1:length(dff_st);
% Set labels for plots.
plot_info.plot_labels = {'Stim','Ctrl'}; % Alternative could be {'Left Sounds','Right Sounds'}
plot_info.behavioral_contexts = {'Spont'}; %decide which contexts to plot
plot_info.y_lims = [-.2, .4];
params.plot_info = plot_info;
save_dir = 'W:\Connie\results\Bassi2025\fig3\control_mice\';

%generates heatmaps, cdf, box plots, scatter of abs(mod _index)
all_cells_mod = cellfun(@(x) x.all_cells, all_celltypes, 'UniformOutput', false); %including all cells
params.plot_info.colors_celltypes = [0.5,0.5,0.5];
params.plot_info.celltype_names = {'All Cells'};
mod_index_stats_datasets_control = generate_engagement_index_plots_datasets(params.info_ctrl.chosen_mice, mod_indexm, all_cells_mod, all_celltypes, params, [save_dir], [],plot_info.y_lims);
% mod_index_stats_datasets = generate_mod_index_plots_datasets(params.info_ctrl.chosen_mice, mod_indexm,  [], all_celltypes, params, save_dir);
save(fullfile(save_dir, 'mod_index_stats_datasets.mat'), 'mod_index_stats_datasets');

%% Save Results- save your modulation index data.
save(fullfile(save_dir, 'mod_index_stats_datasets_control.mat'), 'mod_index_stats_datasets_control');
