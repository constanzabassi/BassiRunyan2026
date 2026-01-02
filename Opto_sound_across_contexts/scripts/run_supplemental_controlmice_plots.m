% Code to make figures related to S4
%% Compare modulation indices across contexts and cell types
load('opto_control.mat'); load('all_celltypes_control');load('all_celltypes.mat'); load('opto.mat');load('context_data_control');
save_dir = [];
mod_params.mod_threshold = .1;% 0 is no threshold applied
mod_params.chosen_mice = [1:length(dff_st)];
mod_params.min_cells = 0;
%plot % modulated cells per context
mod_params.threshold_single_side = 0;

%PLOT MODULATED NEURONS in the spontaneous context
context_num = 1;
[percentage_stats] = plot_sig_mod_pie(mod_params, opto_control.mod, opto_control.sig_mod_boot_thr, context_num, save_dir , 'vertical',all_celltypes_control);
S = unwrap_cells_in_struct(percentage_stats)
table_1 = struct2table_recursive(S,'',{'bootstat','ci'});

% HEATMAP
params.savepath = save_dir;
params.context_labels = {'Spont'};
generate_neural_heatmaps_simple(dff_st, stim_trials_context, ctrl_trials_context,[],[1:length(dff_st)], params, 'opto',context_num,[-.5,1],5); %sig_mod_boot_thr'

% MAKE AVG PLOTS OF TRACES (DOES NOT SEPARATE LEFT VS RIGHT AVG ACROSS ALL)
context_num = 1; %only one context
plot_info.type = 'opto';
sig_all_cells = cellfun(@(x) x.all_cells , all_celltypes_control , 'UniformOutput' , false)'; %getting all neurons
wrapper_avg_cell_type_traces_single_context(context_data_control.dff,all_celltypes_control,context_num,opto_control.mod,sig_all_cells,mod_params,save_dir,'opto_dff',plot_info);
% wrapper_avg_cell_type_traces(context_data.dff,all_celltypes,mod_indexm,[],mod_params,[],'opto_dff',plot_info,mod_indexm);
%% comparing with real photostim mice!
[context_mod_all, ~, ~, ~, ~] = organize_sig_mod_index_contexts_celltypes(...
        [1:8], opto_control.mod, [], all_celltypes_control,params.plot_info.celltype_names);

[context_mod_stim_datasets, ~, ~, ~, ~] = organize_sig_mod_index_contexts_celltypes(...
        [1:24], opto.mod, [], all_celltypes,params.plot_info.celltype_names);


%load experimental stim mice!
plot_info.behavioral_contexts = {'Spont'};
params.plot_info = plot_info;
mod_index_stim = opto.mod;
%do CDF comparisons experimental vs control mice
[cdf_stats, KW_Test] = cdf_mod_index_stim_vs_ctrl_datasets(save_dir,  context_mod_stim_datasets(:,3), context_mod_all, ...
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
plot_info.plot_labels = {'Stim','Ctrl'}; % Alternative could be {'Left Sounds','Right Sounds'}
plot_info.behavioral_contexts = {'Spont'}; %decide which contexts to plot
plot_info.y_lims = [-.4, .4];
params.plot_info = plot_info;

%generates heatmaps, cdf, box plots, scatter of abs(mod _index)
all_cells_mod = cellfun(@(x) x.all_cells, all_celltypes_control, 'UniformOutput', false); %including all cells
params.plot_info.colors_celltypes = [0.5,0.5,0.5];
params.plot_info.celltype_names = {'All Cells'};
mod_index_stats_datasets_control = generate_engagement_index_plots_datasets([1:8], opto_control.mod, all_cells_mod', all_celltypes_control, params, [save_dir], [],plot_info.y_lims);
