addpath(genpath('C:\Code\Github\BassiRunyan2025'))
% Setup analysis parameters
%includes all datasets being analyzed, frame parameters, mod index
%parameters
params = experiment_config(); 
plot_info = plotting_config(); %plotting params
params.plot_info = plot_info;

% load mod indices/ significant neurons
[sound,opto,sorted_cells,all_celltypes,context_data,ctrl_trials_context,stim_trials_context, context_data_sounds] = load_processed_opto_sound_data(params,{'separate','separate'});

%% set up colors and different pools of cells
%within context use below
% [pooled_cell_types,plot_info.celltype_names,plot_info.colors_celltypes] = organize_functional_groups(all_celltypes, sound.sig_mod_boot_thr, opto.sig_mod_boot_thr_ctrl, opto.mod(1:24,:), {'unmodulated','both','opto','sound'},[1:24],plot_info, 2);

% % below is using previous code (with previous significance definitions of
% % union active/passive for sound, spontaneous for stim
% [pooled_cell_types,plot_info.celltype_names,plot_info.colors_celltypes] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'unmodulated','both','opto','sound'},[1:24],plot_info, 1);

% set up plotting labels
plot_info.y_lims = [-.2, .4];
% Set labels for plots.
plot_info.behavioral_contexts = {'Active','Passive'}; %decide which contexts to plot
params.plot_info = plot_info;

% set up save directory!
current_save_dir = 'W:\Connie\results\Bassi2025\fig5'; %'V:\Connie\results\opto_sound_2025\context\mod_index_specified_cells\differences_pre_post\dff'; %'V:\Connie\results\opto_sound_2025\context\mod_index_specified_cells\differences_pre_post\dff';
%% calculate avg difference of post and pre
%unpack data
min_cells = 1;
[dff_response,~] = unpack_context_mouse_celltypes(context_data.dff,[],all_celltypes,min_cells,[1:25]); %context_data.deconv_interp
[deconv_response,~] = unpack_context_mouse_celltypes(context_data.deconv_interp,[],all_celltypes,min_cells,[1:25]); %context_data.deconv_interp

% Setup parameters
avg_prepost_params = struct(...
    'pre_frames', 51:60, ...
    'post_frames',63:93, ...
    'trial_type', 'stim', ...
    'mode', 'all',...
    'data_type', 'dff'); %separate, pooled or all (to separate or pool left vs right trials)

% NAMING CONVENTION - avg_post_ctrl = post sound only response;avg_pre_ctrl = pre sound only response;
%avg_post = post stim+sound response, avg_pre = pre stim+sound response

[avg_pre,avg_ctrl_pre, avg_post,avg_ctrl_post,avg_pre_left,avg_ctrl_pre_left,avg_post_left,avg_ctrl_post_left,avg_pre_right,avg_ctrl_pre_right,avg_post_right,avg_ctrl_post_right]  = ...
    wrapper_prepost_averaging(params.info, dff_response,stim_trials_context,ctrl_trials_context, all_celltypes, avg_prepost_params, []);

[avg_trial_pre,avg_trial_ctrl_pre, avg_trial_post,avg_trial_ctrl_post,avg_trial_pre_left,avg_trial_ctrl_pre_left,avg_trial_post_left,avg_trial_ctrl_post_left,avg_trial_pre_right,avg_trial_ctrl_pre_right,avg_trial_post_right,avg_trial_ctrl_post_right,correct_trials_stim,correct_trials_ctrl]  = ...
    wrapper_prepost_averaging_trials(params.info, dff_response,stim_trials_context,ctrl_trials_context, all_celltypes, avg_prepost_params, []);
%% find relevant differences

% define pre and post periods (stim+sound - sound) and pre active - pre
% passive
[diff_stim, diff_pre_stim, diff_pre_ctrl] = calculate_avg_differences(avg_pre,avg_ctrl_pre,avg_post,avg_ctrl_post);
save([current_save_dir '\diff_stim.mat'],'diff_stim');
save([current_save_dir '\diff_pre_stim'],'diff_pre_stim');
save([current_save_dir '\avg_ctrl_post'],'avg_ctrl_post');

%% (Functional traces also in MAIN figure)
plot_info.type = 'engagement'; %'sound'
savepath = 'W:\Connie\results\Bassi2025\fig4\functional_pre_traces\';% '/spont_sig'];% '/spont_sig']; %[info.savepath '/mod/' mod_params.mod_type '/spont_sig']; % Set directory to save figures.

[pooled_cell_types,plot_info.pooled_names,plot_info.pooled_colors] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'sound','opto','both','unmodulated'},[1:24],plot_info, 1);
plot_info.pooled_names = {{'Sound';'modulated'},{'Photostim';'modulated'},{'S & P';'modulated'},'Unmodulated'}
[traces_mean,dataset_ids] = wrapper_avg_pooled_type_traces(context_data.dff,pooled_cell_types,[],[1:24],savepath,'sound_dff_functional_types_-2to0_',plot_info,[1:10]);
table_fig3_evoked = make_stats_tables_evoked(traces_mean,[], 'avg_traces', {'Sound', 'Photostim', 'S & P','S & P'},51:60, savepath); %save stats table
%%
plot_info.type = 'engagement'; %'sound'
savepath = 'W:\Connie\results\Bassi2025\fig4\celltype_pre_traces\';% '/spont_sig'];% '/spont_sig']; %[info.savepath '/mod/' mod_params.mod_type '/spont_sig']; % Set directory to save figures.

plot_info.pooled_names = plot_info.celltype_names;
plot_info.colors_pooled_3contexts = plot_info.colors_celltypes_3contexts;
[traces_mean,dataset_ids] = wrapper_avg_pooled_type_traces(context_data.dff,all_celltypes,[],[1:24],savepath,'sound_dff_celltypes_types_-2to0_',plot_info,[1:10]);
table_fig3_evoked = make_stats_tables_evoked(traces_mean,[], 'avg_traces', {'Pyr', 'SOM', 'PV'},51:60, savepath); %save stats table

%% Functional pre responses (IN MAIN FIGURE)
%functional
plot_info = plotting_config();
[pooled_cell_types,plot_info.celltype_names,plot_info.colors_celltypes] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'sound','opto','both','unmodulated'},[1:24],plot_info, 1);
[preavg_index_by_dataset,~] = unpack_modindexm(avg_pre,[],pooled_cell_types,[1:24]);
params.plot_info = plot_info;
preavg_stats_celltypes_dataset = plot_connected_abs_mod_by_mouse('W:\Connie\results\Bassi2025\fig4', preavg_index_by_dataset, [1:24],...
          params.plot_info, [.075,.4],0,'Pre Mean (\DeltaF/F)');

%celltypes
plot_info = plotting_config();
params.plot_info = plot_info;
[preavg_index_by_dataset_ct,~] = unpack_modindexm(avg_pre,[],all_celltypes,[1:24]);
preavg_stats_celltypes_dataset_ct = plot_connected_abs_mod_by_mouse('W:\Connie\results\Bassi2025\fig4/celltypes', preavg_index_by_dataset_ct, [1:24],...
          plot_info, [0,.3],0,'Pre Mean (ΔF/F)');

stats = {preavg_stats_celltypes_dataset,preavg_stats_celltypes_dataset_ct};
table_fig4_pre = [];labels = {'functional','celltype'};
for i = 1:numel(stats)
    S = unwrap_cells_in_struct(stats{i});
    table = struct2table_recursive(S,labels{i},{'bootstat','ci'});
    table_fig4_pre = [ table_fig4_pre;table];
end
save(fullfile('W:\Connie\results\Bassi2025\fig4\', strcat('table_fig4_pre.mat')), 'table_fig4_pre');
writetable(table_fig4_pre, fullfile('W:\Connie\results\Bassi2025\fig4\', strcat('table_fig4_pre.csv')));



%% Make plots (scatter plot comparisons, pre vs post, difference pre vs post etc)
%make scatter plots and save them!
[pooled_cell_types_stim,plot_info.celltype_names,plot_info.colors_celltypes] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'unmodulated','sound','both','opto'},[1:24],plot_info, 1);

[modl_fit,~,~,stats1] = scatter_index_sigcells_histogram_optional([], pooled_cell_types_stim, [{diff_pre_stim{:,1}}',{diff_stim{:,1}}'], plot_info, current_save_dir, 'Pre Diff (active - passive)', 'Active Post (Δ Stim)',0,1,[-.6,2]);
[modl_fit,~,~,stats2] = scatter_index_sigcells_histogram_optional([], pooled_cell_types_stim, [{diff_pre_stim{:,1}}',{diff_stim{:,2}}'], plot_info, current_save_dir, 'Pre Diff (active - passive)', 'Passive Post (Δ Stim)',0,1,[-.6,2]);
[modl_fit,~,~,stats7] = scatter_index_sigcells_histogram_optional([], pooled_cell_types_stim, [{avg_pre{:,1}}',{diff_stim{:,1}}'], plot_info, current_save_dir, 'Active Pre', 'Active Post (\Delta Stim)',0,1,[-.6,2]);
[modl_fit,~,~,stats8] = scatter_index_sigcells_histogram_optional([], pooled_cell_types_stim, [{avg_pre{:,2}}',{diff_stim{:,2}}'], plot_info, current_save_dir, 'Passive Pre', 'Passive Post (\Delta Stim)',0,1,[-.6,2]);

[pooled_cell_types,plot_info.celltype_names,plot_info.colors_celltypes] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'unmodulated','both','opto','sound'},[1:24],plot_info, 1);
[modl_fit,~,~,stats3] = scatter_index_sigcells_histogram_optional([], pooled_cell_types, [{diff_pre_ctrl{:,1}}',{avg_ctrl_post{:,1}}'], plot_info, current_save_dir, 'Pre Diff (active - passive)', 'Active Post (sound)',0,1,[-.6,2]);
[modl_fit,~,~,stats4] = scatter_index_sigcells_histogram_optional([], pooled_cell_types, [{diff_pre_ctrl{:,1}}',{avg_ctrl_post{:,2}}'], plot_info, current_save_dir, 'Pre Diff (active - passive)', 'Passive Post (sound)',0,1,[-.6,2]);

[modl_fit,~,~,stats5] = scatter_index_sigcells_histogram_optional([], pooled_cell_types, [{avg_ctrl_pre{:,1}}',{avg_ctrl_post{:,1}}'], plot_info, current_save_dir, 'Active Pre (sound)', 'Active Post (sound)',0,1,[-.6,2]);
[modl_fit,~,~,stats6] = scatter_index_sigcells_histogram_optional([], pooled_cell_types, [{avg_ctrl_pre{:,2}}',{avg_ctrl_post{:,2}}'], plot_info, current_save_dir, 'Passive Pre (sound)', 'Passive Post (sound)',0,1,[-.6,2]);


% --- Defaults for responses ---
response_types_info = { ...
    struct('name','pre',       'data', avg_pre,   'range', [0.1,0.4], 'label', 'Pre Mean (ΔF/F)'), ...
    struct('name','diff_stim', 'data', diff_stim,'range', [-0.1,0.5],'label', 'Mean Pop. Activity (Δ Stim)'), ...
    struct('name','post',      'data', avg_post, 'range', [0,0.8],   'label', 'Mean Pop. Activity (Stim+Sound)') ...
};
[stats_all, responses_by_dataset] = wrapper_plot_response_means({avg_pre,diff_stim,avg_post},response_types_info, pooled_cell_types, [1:24], current_save_dir, plot_info, []);

[pooled_cell_types,plot_info.celltype_names,plot_info.colors_celltypes] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'sound','opto','both','unmodulated'},[1:24],plot_info, 1);

response_types_info = { ...
    struct('name','pre',       'data', avg_pre,   'range', [0.1,0.4], 'label', 'Pre Mean (ΔF/F)')};
[stats_all, responses_by_dataset] = wrapper_plot_response_means({avg_pre,diff_stim,avg_post},response_types_info, pooled_cell_types, [1:24], 'W:\Connie\results\Bassi2025\fig4', plot_info, []);

%% comparing pre vs post
modl_fit.prepost_stim = wrapper_scatter_index_contexts([],avg_pre, diff_stim, pooled_cell_types, plot_info, current_save_dir, 'Pre', 'Post (Δ Stim)',0,1,[-.6,2]);
modl_fit.prepost_sound = wrapper_scatter_index_contexts([],avg_ctrl_pre, avg_ctrl_post, pooled_cell_types, plot_info, current_save_dir, 'Pre', 'Post (Sound)',0,1,[-.6,2]);

%% comparing opto vs sound
%within context significance
n_contexts = 2;
[pooled_cell_types,plot_info.celltype_names,plot_info.colors_celltypes] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'both','opto','sound'},[1:24],plot_info, 1);
[modl_fit_deltastimsound,stats9] = wrapper_scatter_index_contexts([],avg_ctrl_post, diff_stim, pooled_cell_types, plot_info, current_save_dir, 'Post (Sound)', 'Post (Δ Stim)',0,0,[-1,2]);


[pooled_cell_types,plot_info.celltype_names,plot_info.colors_celltypes] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'sound','opto','both'},[1:24],plot_info, 1);
[stats_deltastimsound, corr_results_deltastimsound] = wrapper_plot_corr_means([],pooled_cell_types, avg_ctrl_post, diff_stim, avg_post, current_save_dir, plot_info, [-1,1], 'Corr (Sound vs Δ Stim)', [1:24], [1:3]) %1:4 is functional subtimes from pooled

%save stats into a single table
stats = {stats9,stats1, stats2, stats3, stats4, stats5, stats6,stats7,stats8};
table_pre_stats = [];
for i = 1:numel(stats)
    S = stats{i};
    table = struct2table_recursive(S,'scatter',{'bootstat','ci'});
    table_pre_stats = [ table_pre_stats;table];
end
S = unwrap_cells_in_struct(stats_deltastimsound);
table = struct2table_recursive(S,'corr',{'bootstat','ci'});
table_fig4_pre = [table;table_pre_stats];
save(fullfile(current_save_dir, strcat('table_fig5.mat')), 'table_fig4_pre');
writetable(table_fig4_pre, fullfile(current_save_dir, strcat('table_fig5.csv')));

%% separate into modulated and unmodulated
[pooled_cell_types_modulated,plot_info.celltype_names,plot_info.colors_celltypes] = organize_functional_groups(all_celltypes, sound.sig_mod_boot_thr, opto.sig_mod_boot_thr_ctrl, opto.mod(1:24,:), {'unmodulated','modulated'},[1:24],plot_info, 2);
current_save_dir2 ='V:\Connie\results\opto_sound_2025\context\mod_index_specified_cells\differences_pre_post\dff\modulated';

[stats_all, responses_by_dataset] = wrapper_plot_response_means({avg_pre,diff_stim,avg_post},response_types_info, pooled_cell_types_modulated, [1:24], current_save_dir2, plot_info, []);
celltypes_to_plot = 2; %modulated
response_types_to_plot =  1:2; %{1 ='Sound',2 ='Stim + Sound',3 ='Delta Stim}
[stats, corr_results] = wrapper_plot_means_std([],pooled_cell_types_modulated, avg_ctrl_post,  diff_stim, avg_post, current_save_dir2, plot_info, {[0.1,.3],[0,.25]}, {'Mean Population Activity','Std. Population Activity'}, [1:24], celltypes_to_plot, response_types_to_plot);
modl_fit.delta_stim_sound_modulated = wrapper_scatter_index_contexts([],avg_ctrl_post, diff_stim, pooled_cell_types_modulated, plot_info, current_save_dir2, 'Post (Sound)', 'Post (Δ Stim)',0,0,[-1,2]);

%% EXAMINATION OF COVARIANCE BETWEEN BASELINE SOUND VS SOUND+STIM-SOUND RESPONSE

%look at recruitment vs gain modulation
save_dir_corr = [current_save_dir '/correlations/'];
% have to be the same functional groups across contexts!
[pooled_cell_types_across_contexts,plot_info.celltype_names,plot_info.colors_celltypes] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'sound','both','opto','unmodulated'},[1:24],plot_info, 1);
[cos_corr_stats, cos_results] = wrapper_plot_cosine_sim_corr([],pooled_cell_types_across_contexts, avg_ctrl_post, diff_stim, save_dir_corr, plot_info, {[0,1],[0.5,1]}, [1:24], [1:4]);
[~, corr_results_across_ctx] = wrapper_plot_corr_means([],pooled_cell_types_across_contexts, avg_ctrl_post, diff_stim, avg_post, save_dir_corr, plot_info, [-1,1], 'Corr all (Sound vs Δ Stim)', [1:24], [1:4]) %1:4 is functional subtimes from pooled

% cdf of responses like delta stim across active and passive (pooling all
% neurons across datasets!) - ALSO HAS TO BE SAME FUNCTIONAL GROUPS ACROSS
% CONTEXTS (TO DO PAIRED STATS)
cdf_data = squeeze(corr_results_across_ctx.data_datasets(:,:,1:3,3));%using all cell types (4th # 1 = sound,2 sound+3, 3 delta stim)
plot_cdf_celltypes([], cdf_data, 1:24, plot_info,'Δ Stim',[-.1,0.3],0);
% mod_stats = plot_cdf_celltypes('V:\Connie\results\opto_sound_2025\context\mod_index_specified_cells\differences_pre_post\dff\', cdf_data, 1:24, plot_info,'Δ Stim',[-.1,0.3],0);
%% REPEAT ANALYSIS BUT USING PYR/SOM/PV as the celltypes
celltype_save_dir = [current_save_dir '\celltypes']; %'V:\Connie\results\opto_sound_2025\context\mod_index_specified_cells\differences_pre_post\dff';

[~, corr_results_across_ctx] = wrapper_plot_corr_means([],all_celltypes, avg_ctrl_post, diff_stim, avg_post, celltype_save_dir, plot_info, [-1,1], 'Corr all (Sound vs Δ Stim)', [1:24], [1:3]) %1:4 is functional subtimes from pooled
response_types_info{1, 1}(1, 1).range = [0.1,0.3];response_types_info{1, 2}(1, 1).range = [-0.05,.15];response_types_info{1, 3}(1, 1).range = [0.1,0.4]; %update ylims
[stats_all, responses_by_dataset] = wrapper_plot_response_means({avg_pre,diff_stim,avg_post},response_types_info, all_celltypes, [1:24], celltype_save_dir, plot_info, []);

n_contexts = 2;
modl_fit.delta_stim_sound = wrapper_scatter_index_contexts([],avg_ctrl_post, diff_stim, all_celltypes, plot_info, celltype_save_dir, 'Post (Sound)', 'Post (Δ Stim)',0,0,[-1,2]);



% --- Defaults for responses ---
response_types_info = { ...
    struct('name','diff_stim', 'data', diff_stim,'range', [-0.1,0.5],'label', 'Mean Pop. Activity (Δ Stim)')%, ...
%     struct('name','post',      'data', avg_post, 'range', [0,0.8],   'label', 'Mean Pop. Activity (Stim+Sound)') ...
};
[stats_all_ct_stim, responses_by_dataset_ct_stim] = wrapper_plot_response_means({diff_stim,avg_post},response_types_info, all_celltypes, [1:24], [celltype_save_dir '/photostim_sig/'], plot_info,opto.sig_cells);
[stats_allcellsstim,~] = wrapper_plot_response_means_allcells({diff_stim,avg_post},response_types_info, all_celltypes, [1:24], [celltype_save_dir '/photostim_sig/'], plot_info,opto.sig_cells); %pooling across datasets

%stim+sound and sound only responses across 3 contexts!
plot_info.behavioral_contexts = {'Active','Passive','Spontaneous'};
% --- Defaults for responses ---
response_types_info = { ...
    struct('name','pre',       'data', avg_ctrl_post,   'range', [0,0.4], 'label', 'Mean Pop. Activity (Sound)'), ...
    struct('name','post',      'data', avg_post, 'range', [0,0.6],   'label', 'Mean Pop. Activity (Stim+Sound)') ...
};
[stats_all_ct_stim, responses_by_dataset_ct_stim] = wrapper_plot_response_means({avg_ctrl_post,avg_post},response_types_info, all_celltypes, [1:24], [celltype_save_dir '/photostim_sig/'], plot_info,opto.sig_cells);
[stats_allcellsstim,~] = wrapper_plot_response_means_allcells({avg_ctrl_post,avg_post},response_types_info, all_celltypes, [1:24], [celltype_save_dir '/photostim_sig/'], plot_info,opto.sig_cells); %pooling across datasets

% --- Defaults for responses ---
response_types_info = { ...
    struct('name','pre',       'data', avg_ctrl_post,   'range', [0,0.4], 'label', 'Mean Pop. Activity (Sound)'), ...
    struct('name','post',      'data', avg_post, 'range', [0,0.4],   'label', 'Mean Pop. Activity (Stim+Sound)') ...
};
[stats_all_ct, responses_by_dataset_ct] = wrapper_plot_response_means({avg_ctrl_post,avg_post},response_types_info, all_celltypes, [1:24], [celltype_save_dir '/sound_sig/'], plot_info, sound.sig_cells);
[stats_allcells,~] = wrapper_plot_response_means_allcells({avg_ctrl_post,avg_post},response_types_info, all_celltypes, [1:24], [celltype_save_dir '/sound_sig/'], plot_info, sound.sig_cells); %pooling across datasets

%%
% %% plot performance vs pre stim rate
% % sound/opto/sound+opto/all
% num_bins = 5;
% pool_colors = [0.3,0.2,0.6 ; 1,0.7,0; 0.3,0.8,1; 0,0,0];
% for cur_celltypes = 1:4
%     [all_bin_perf,errorbar_correct_stats] = plot_error_bars_response_vs_axis(1:24,avg_trial_ctrl_pre,correct_trials_ctrl,cur_celltypes,num_bins,0,current_save_dir,pool_colors(cur_celltypes,:));
% end
% 
% [all_bin_perf,errorbar_correct_stats] = plot_error_bars_response_vs_axis(1:24,avg_trial_ctrl_pre,correct_trials_ctrl,1,num_bins,0,current_save_dir,[0.5,0.5,0.5]);
% 