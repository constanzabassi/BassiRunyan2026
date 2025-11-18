
addpath(genpath('C:\Code\Github\Opto_sounds_analysis'))
% Setup analysis parameters
%includes all datasets being analyzed, frame parameters, mod index
%parameters
params = experiment_config(); 
plot_info = plotting_config(); %plotting params
params.plot_info = plot_info;

%% load mod indices/ significant neurons/ selectivity indices

%opto
opto_sig_mod_boot_thr = load('V:\Connie\results\opto_sound_2025\context\mod\prepost\separate\sig_mod_boot_thr.mat').sig_mod_boot_thr;
opto_sig_mod_boot = load('V:\Connie\results\opto_sound_2025\context\mod\prepost\separate\sig_mod_boot.mat').sig_mod_boot;
opto_mod = load('V:\Connie\results\opto_sound_2025\context\mod\ctrl\separate\mod_indexm.mat').mod_indexm;
opto_mod_prepost = load('V:\Connie\results\opto_sound_2025\context\mod\prepost\separate\mod_indexm.mat').mod_indexm;

opto_mod_results = load('V:\Connie\results\opto_sound_2025\context\mod\ctrl\separate\mod_index_results.mat').results;
opto_sig_cells = opto_sig_mod_boot_thr(:,3); %from spontaneous context
opto_average = load('V:\Connie\results\opto_sound_2025\context\avg\trial_averaged_results.mat').avg_results;

%sound
sound_sig_mod_boot_thr = load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\sig_mod_boot_thr.mat').sig_mod_boot_thr;
sound_sig_mod_boot = load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\sig_mod_boot.mat').sig_mod_boot;
sound_mod = load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\mod_indexm.mat').mod_indexm;
sound_mod_results = load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\mod_index_results.mat').results;
[sound_sig_cells, ~] = union_sig_cells(sound_sig_mod_boot_thr(:,1)', sound_sig_mod_boot_thr(:,2)', sound_mod);
sound_average = load('V:\Connie\results\opto_sound_2025\context\sounds\avg\trial_averaged_results_sounds.mat').avg_results_sounds;
sound_stim_average = load('V:\Connie\results\opto_sound_2025\context\sounds\avg\trial_averaged_results_sounds_stim.mat').avg_results;

%previously calculated selecvitiy
selectivity_mode = 'prepost_ctrl';
selectivity_base = ['V:\Connie\results\opto_sound_2025\context\sounds\selectivity\' selectivity_mode];
selectivity_indexm = load([selectivity_base '\mod_indexm.mat']).mod_indexm;
selectivity_results = load([selectivity_base '\mod_index_results.mat']).results; %has significant neurons too!

% selectivity_indexm = load('V:\Connie\results\opto_sound_2025\context\sounds\selectivity\prepost_ctrl\mod_indexm.mat').mod_indexm;

load('V:\Connie\results\opto_sound_2025\context\data_info\sorted_cells.mat');
load('V:\Connie\results\opto_sound_2025\context\data_info\all_celltypes.mat');
%load data and trials
load('V:\Connie\results\opto_sound_2025\context\data_info\context_data.mat');
load('V:\Connie\results\opto_sound_2025\context\data_info\ctrl_trials_context.mat');
load('V:\Connie\results\opto_sound_2025\context\data_info\stim_trials_context.mat');

%% set up colors and different pools of cells
plot_info.colors_celltypes = [0.3,0.2,0.6 ; 1,0.7,0; 0.3,0.8,1; 0.5,0.5,0.5]; %0.9/0.6/0.2 or 1,0.7,0
opto_only_sig_cells = setdiff_sig_cells(opto_sig_cells', sound_sig_cells,opto_mod);
sound_only_sig_cells = setdiff_sig_cells(sound_sig_cells(1,1:24),opto_sig_cells', opto_mod);
opto_sound_sig_cells = intersect_sig_cells(opto_sig_cells', sound_sig_cells,opto_mod);
all_cells =[cellfun(@(x) x.pyr_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.som_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.pv_cells,all_celltypes,'UniformOutput',false)];
num_cells = cellfun(@length, all_cells );

pooled_cell_types = {};
for dataset = 1:24
    current_sig_cells = [sound_only_sig_cells{dataset}, opto_only_sig_cells{dataset}, opto_sound_sig_cells{dataset}];
    unmodulated{dataset} = setdiff(1:sum(num_cells(:,dataset)),current_sig_cells);
%     pooled_cell_types{dataset}.unmodulated = setdiff(1:sum(num_cells(:,dataset)),current_sig_cells);
    pooled_cell_types{dataset}.sound = sound_only_sig_cells{dataset};
    pooled_cell_types{dataset}.opto = opto_only_sig_cells{dataset};
    pooled_cell_types{dataset}.both = opto_sound_sig_cells{dataset};
    pooled_cell_types{dataset}.unmodulated = setdiff(1:sum(num_cells(:,dataset)),current_sig_cells);
end

pooled_all = {};
for dataset = 1:24
    pooled_all{dataset}.all = 1:sum(num_cells(:,dataset));
end

%% set up plotting labels
plot_info.celltype_names = {'Sound','Opto','Both','Unmodulated'};
plot_info.y_lims = [-.2, .4];
% Set labels for plots.
plot_info.behavioral_contexts = {'Active','Passive'}; %decide which contexts to plot
params.plot_info = plot_info;
%% calculate avg difference of post and pre

%unpack data
[dff_response,~] = unpack_context_mouse_celltypes(context_data.dff,[],all_celltypes,[1:25]); %context_data.deconv_interp
[deconv_response,~] = unpack_context_mouse_celltypes(context_data.deconv_interp,[],all_celltypes,[1:25]); %context_data.deconv_interp

% Setup parameters
avg_prepost_params = struct(...
    'pre_frames', 51:60, ...
    'post_frames',63:93, ...
    'trial_type', 'stim', ...
    'mode', 'all',...
    'data_type', 'dff'); %separate, pooled or all (to separate or pool left vs right trials)
[avg_pre,avg_ctrl_pre, avg_post,avg_ctrl_post,avg_pre_left,avg_ctrl_pre_left,avg_post_left,avg_ctrl_post_left,avg_pre_right,avg_ctrl_pre_right,avg_post_right,avg_ctrl_post_right]  = ...
    wrapper_prepost_averaging(params.info, dff_response,stim_trials_context,ctrl_trials_context, all_celltypes, avg_prepost_params, []);

[avg_trial_pre,avg_trial_ctrl_pre, avg_trial_post,avg_trial_ctrl_post,avg_trial_pre_left,avg_trial_ctrl_pre_left,avg_trial_post_left,avg_trial_ctrl_post_left,avg_trial_pre_right,avg_trial_ctrl_pre_right,avg_trial_post_right,avg_trial_ctrl_post_right,correct_trials_stim,correct_trials_ctrl]  = ...
    wrapper_prepost_averaging_trials(params.info, dff_response,stim_trials_context,ctrl_trials_context, all_celltypes, avg_prepost_params, []);
%%
current_save_dir = 'W:\Connie\results\Bassi2025\fig5'; %'V:\Connie\results\opto_sound_2025\context\mod_index_specified_cells\differences_pre_post\dff'; %'V:\Connie\results\opto_sound_2025\context\mod_index_specified_cells\differences_pre_post\dff';

%% plot performance vs pre stim rate
% sound/opto/sound+opto/all
num_bins = 5;
pool_colors = [0.3,0.2,0.6 ; 1,0.7,0; 0.3,0.8,1; 0,0,0];
for cur_celltypes = 1:4
    [all_bin_perf,errorbar_correct_stats] = plot_error_bars_response_vs_axis(1:24,avg_trial_ctrl_pre,correct_trials_ctrl,cur_celltypes,num_bins,0,current_save_dir,pool_colors(cur_celltypes,:));
end

[all_bin_perf,errorbar_correct_stats] = plot_error_bars_response_vs_axis(1:24,avg_trial_ctrl_pre,correct_trials_ctrl,1,num_bins,0,current_save_dir,[0.5,0.5,0.5]);

%% find relevant differences

% define pre and post periods (stim+sound - sound) and pre active - pre
% passive
[diff_stim, diff_pre_stim, diff_pre_ctrl] = calculate_avg_differences(avg_pre,avg_ctrl_pre,avg_post,avg_ctrl_post);
save('diff_stim','diff_stim')
save('diff_pre_stim','diff_pre_stim')
save('avg_ctrl_post','avg_ctrl_post')
%% Make plots
%make scatter plots and save them!
modl_fit = scatter_index_sigcells_histogram_optional([], pooled_cell_types, [{diff_pre_stim{:,1}}',{diff_stim{:,1}}'], plot_info, current_save_dir, 'Pre Diff (active - passive)', 'Active Post (\Delta Stim)',0,1,[-.6,2]);
modl_fit = scatter_index_sigcells_histogram_optional([], pooled_cell_types, [{diff_pre_stim{:,1}}',{diff_stim{:,2}}'], plot_info, current_save_dir, 'Pre Diff (active - passive)', 'Passive Post (\Delta Stim)',0,1,[-.6,2]);

modl_fit = scatter_index_sigcells_histogram_optional([], pooled_cell_types, [{diff_pre_ctrl{:,1}}',{avg_ctrl_post{:,1}}'], plot_info, current_save_dir, 'Pre Diff (active - passive)', 'Active Post (sound)',0,1,[-.6,2]);
modl_fit = scatter_index_sigcells_histogram_optional([], pooled_cell_types, [{diff_pre_ctrl{:,1}}',{avg_ctrl_post{:,2}}'], plot_info, current_save_dir, 'Pre Diff (active - passive)', 'Passive Post (sound)',0,1,[-.6,2]);

[preavg_index_by_dataset,~] = unpack_modindexm(avg_pre,[],pooled_cell_types,[1:24]);
preavg_stats_celltypes_dataset = plot_connected_abs_mod_by_mouse('W:\Connie\results\Bassi2025\fig4', preavg_index_by_dataset, [1:24],...
          params.plot_info, [.1,.4],0,'Pre Mean (\DeltaF/F)');

[diff_stim_index_by_dataset,~] = unpack_modindexm(diff_stim,[],pooled_cell_types,[1:24]);
diff_stim_stats_celltypes_dataset = plot_connected_abs_mod_by_mouse(current_save_dir, diff_stim_index_by_dataset, [1:24],...
          params.plot_info, [-.1,.5],0,'Mean Pop. Activity (\Delta Stim)'); %'\Delta Stim (\DeltaF/F)'

[post_stim_index_by_dataset,~] = unpack_modindexm(avg_post,[],pooled_cell_types,[1:24]);
post_stim_stats_celltypes_dataset = plot_connected_abs_mod_by_mouse(current_save_dir, post_stim_index_by_dataset, [1:24],...
          params.plot_info, [0,.8],0,'Mean Pop. Activity (Stim+Sound)'); %'\Delta Stim (\DeltaF/F)'
%% comparing pre vs post
modl_fit = scatter_index_sigcells_histogram_optional([], pooled_cell_types, [{avg_pre{:,1}}',{diff_stim{:,1}}'], plot_info, current_save_dir, 'Active Pre', 'Active Post (\Delta Stim)',0,1,[-.6,2]);
modl_fit = scatter_index_sigcells_histogram_optional([], pooled_cell_types, [{avg_pre{:,2}}',{diff_stim{:,2}}'], plot_info, current_save_dir, 'Passive Pre', 'Passive Post (\Delta Stim)',0,1,[-.6,2]);

modl_fit = scatter_index_sigcells_histogram_optional([], pooled_cell_types, [{avg_ctrl_pre{:,1}}',{avg_ctrl_post{:,1}}'], plot_info, current_save_dir, 'Active Pre', 'Active Post (Sound)',0,1,[-.6,2]);
modl_fit = scatter_index_sigcells_histogram_optional([], pooled_cell_types, [{avg_ctrl_pre{:,2}}',{avg_ctrl_post{:,2}}'], plot_info, current_save_dir, 'Passive Pre', 'Passive Post (Sound)',0,1,[-.6,2]);

%% comparing opto vs sound
plot_info.colors_celltypes = [ 0.3,0.8,1; 1,0.7,0;0.3,0.2,0.6 ]; %0.9/0.6/0.2 or 1,0.7,0
opto_only_sig_cells = setdiff_sig_cells(opto_sig_cells', sound_sig_cells,opto_mod);
sound_only_sig_cells = setdiff_sig_cells(sound_sig_cells(1,1:24),opto_sig_cells', opto_mod);
opto_sound_sig_cells = intersect_sig_cells(opto_sig_cells', sound_sig_cells,opto_mod);
all_cells =[cellfun(@(x) x.pyr_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.som_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.pv_cells,all_celltypes,'UniformOutput',false)];
num_cells = cellfun(@length, all_cells );

pooled_cell_types_soundfirst = {};
for dataset = 1:24
    current_sig_cells = [sound_only_sig_cells{dataset}, opto_only_sig_cells{dataset}, opto_sound_sig_cells{dataset}];
%     pooled_cell_types{dataset}.unmodulated = setdiff(1:sum(num_cells(:,dataset)),current_sig_cells);
    pooled_cell_types_soundfirst{dataset}.opto = opto_only_sig_cells{dataset};
    pooled_cell_types_soundfirst{dataset}.both = opto_sound_sig_cells{dataset};
    pooled_cell_types_soundfirst{dataset}.sound = sound_only_sig_cells{dataset};


end

[modl_fit,sound_post.act,delta_stim.act] = scatter_index_sigcells_histogram_optional([], pooled_cell_types_soundfirst, [{avg_ctrl_post{:,1}}',{diff_stim{:,1}}'], plot_info, current_save_dir, 'Active Post (Sound)', 'Active Post (\Delta Stim)',0,0,[-1,2]);
[modl_fit,sound_post.pass,delta_stim.pass] = scatter_index_sigcells_histogram_optional([], pooled_cell_types_soundfirst, [{avg_ctrl_post{:,2}}',{diff_stim{:,2}}'], plot_info, current_save_dir, 'Passive Post (Sound)', 'Passive Post (\Delta Stim)',0,0,[-1,2]);

%% separate into modulated and unmodulated
pooled_cell_types_modulated = {};
for dataset = 1:24
    current_sig_cells = [sound_only_sig_cells{dataset}, opto_only_sig_cells{dataset}, opto_sound_sig_cells{dataset}];
%     pooled_cell_types{dataset}.unmodulated = setdiff(1:sum(num_cells(:,dataset)),current_sig_cells);
    pooled_cell_types_modulated{dataset}.mod = current_sig_cells;
    pooled_cell_types_modulated{dataset}.unmod = setdiff(1:sum(num_cells(:,dataset)),current_sig_cells);
    
end
[all_corr_across_celltypes_datasets2,all_corr_across_celltypes2,all_means_across_celltypes_datasets2,all_std_across_celltypes_datasets2,all_data_celltypes_datasets2] = compute_means_correlations_per_dataset([], pooled_cell_types_modulated, avg_ctrl_post, diff_stim, avg_post);

current_save_dir2 ='V:\Connie\results\opto_sound_2025\context\mod_index_specified_cells\differences_pre_post\dff\modulated';
adjusted_means1 = squeeze(all_means_across_celltypes_datasets2(:,:,1,1:2)); %using all cell types (1 = sound,2 sound+3, 3 delta stim)
adjusted_means = permute(adjusted_means1, [1 3 2]);

adjusted_std1 = squeeze(all_std_across_celltypes_datasets2(:,:,1,1:2)); %using all cell types (1 = sound,2 sound+3, 3 delta stim)
adjusted_std = permute(adjusted_std1, [1 3 2]);

params.plot_info.colors_celltypes = [0,0,0;0.5,0.5,0.5];
st = plot_connected_abs_mod_by_mouse(current_save_dir2, adjusted_means, [1:24],...
          params.plot_info, [0.1,.3],0,'Mean Population Activity');

st = plot_connected_abs_mod_by_mouse(current_save_dir2, adjusted_std, [1:24],...
          params.plot_info, [0,.25],0,'Std. Population Activity');

plot_info.colors_celltypes = [0,0,0;0.5,0.5,0.5];
[modl_fit,sound_post.act,delta_stim.act] = scatter_index_sigcells_histogram_optional([], pooled_cell_types_modulated, [{avg_ctrl_post{:,1}}',{diff_stim{:,1}}'], plot_info, current_save_dir2, 'Active Post (Sound)', 'Active Post (\Delta Stim)',0,0,[-1,2]);
[modl_fit,sound_post.pass,delta_stim.pass] = scatter_index_sigcells_histogram_optional([], pooled_cell_types_modulated, [{avg_ctrl_post{:,2}}',{diff_stim{:,2}}'], plot_info, current_save_dir2, 'Passive Post (Sound)', 'Passive Post (\Delta Stim)',0,0,[-1,2]);



%% EXAMINATION OF COVARIANCE BETWEEN BASELINE SOUND VS SOUND+STIM-SOUND RESPONSE
[all_corr_across_celltypes_datasets,all_corr_across_celltypes,all_means_across_celltypes_datasets,all_std_across_celltypes_datasets,all_data_celltypes_datasets] = compute_means_correlations_per_dataset([], pooled_cell_types, avg_ctrl_post, diff_stim, avg_post);
[all_corr_across_celltypes_datasets,all_corr_across_celltypes,all_means_across_celltypes_datasets,all_std_across_celltypes_datasets,all_data_celltypes_datasets] = compute_means_correlations_signseparated_per_dataset([], pooled_cell_types, avg_ctrl_post, diff_stim, avg_post);
[fraction_suppressed, fraction_activated] = compute_fraction_suppressed_per_dataset([], pooled_cell_types, diff_stim);

plot_info.celltype_names = {'Sound','Opto','Both','Unmodulated'};
plot_info.y_lims = [-.2, .4];
% Set labels for plots.
plot_info.behavioral_contexts = {'Active','Passive'}; %decide which contexts to plot
plot_info.colors_celltypes = [0.3,0.2,0.6 ; 1,0.7,0; 0.3,0.8,1; 0.5,0.5,0.5]; %0.9/0.6/0.2 or 1,0.7,0

params.plot_info = plot_info;
params.plot_info.zero_star = 1;
st = plot_connected_abs_mod_by_mouse(current_save_dir, all_corr_across_celltypes_datasets(:,:,1:4), [1:24],...
          params.plot_info, [-1,1],0,'Corr all (Sound vs Δ Stim)');

params.plot_info.zero_star = 0;
st = plot_connected_abs_mod_by_mouse(current_save_dir, fraction_suppressed(:,:,1:4), [1:24],...
          params.plot_info, [0, 1],0,'Fraction Suppressed all (Δ Stim)');

st = plot_connected_abs_mod_by_mouse(current_save_dir, fraction_activated(:,:,1:3), [1:24],...
          params.plot_info, [0, 1],0,'Fraction Activated (Δ Stim)');

st = plot_connected_abs_mod_by_mouse([], all_corr_across_celltypes_datasets(:,:,4), [1:24],...
          params.plot_info, [-1,1],0,'Corr (Sound vs Δ Stim)');

%look at recruitment vs gain modulation
[cos_similarity,rho] = calculate_cosine_sim_rank_corr(diff_stim,[],pooled_cell_types);
[cos_similarity_sound,rho_sound] = calculate_cosine_sim_rank_corr(avg_ctrl_post,[],pooled_cell_types);
params.plot_info.zero_star = 0;
params.plot_info.behavioral_contexts = {'Sound','Opto','Both'};
save_dir_corr = [current_save_dir '/correlations/'];
st = plot_connected_abs_mod_by_mouse(save_dir_corr, rho, [1:24],...
          params.plot_info, [0,1],0,'Corr Δ Stim (contexts)');
st = plot_connected_abs_mod_by_mouse(save_dir_corr, cos_similarity, [1:24],...
          params.plot_info, [0,1],0,{'Cosine Sim. Δ Stim';'across contexts'});

st = plot_connected_abs_mod_by_mouse(save_dir_corr, rho_sound, [1:24],...
          params.plot_info, [0,1],0,'Corr Sound (contexts)');
st = plot_connected_abs_mod_by_mouse(save_dir_corr, cos_similarity_sound, [1:24],...
          params.plot_info, [0,1],0,'Cosine Sim. Sound (contexts)');
% sts = scatter_abs_mean_mod_by_dataset([], permute(rho, [1 2 3]), params.plot_info, 2)


plot_info.colors_celltypes = [0,0,0;0.5,0.5,0.5;0,0,0]; %0.9/0.6/0.2 or 1,0.7,0
plot_info.celltype_names = {'Sound','Stim + Sound','Δ Stim'};
% Set labels for plots.
plot_info.behavioral_contexts = {'Sound','Stim + Sound'}; %decide which contexts to plot
params.plot_info = plot_info;

%plot means across datasets
adjusted_means1 = squeeze(all_means_across_celltypes_datasets(:,:,4,1:2)); %using all cell types (1 = sound,2 sound+3, 3 delta stim)
adjusted_means = permute(adjusted_means1, [1 3 2]);

adjusted_std1 = squeeze(all_std_across_celltypes_datasets(:,:,4,1:2)); %using all cell types (1 = sound,2 sound+3, 3 delta stim)
adjusted_std = permute(adjusted_std1, [1 3 2]);
current_save_dir = [];
st = plot_connected_abs_mod_by_mouse(current_save_dir, adjusted_means, [1:24],...
          params.plot_info, [0.1,.3],0,'Mean Population Activity');

st = plot_connected_abs_mod_by_mouse(current_save_dir, adjusted_std, [1:24],...
          params.plot_info, [0,.25],0,'Std. Population Activity');

adjusted_std1 = squeeze(all_std_across_celltypes_datasets(:,:,4,[1,3])); %using all cell types (1 = sound,2 sound+3, 3 delta stim)
adjusted_std = permute(adjusted_std1, [1 3 2]);
plot_info.colors_celltypes = [0,0,0;0.5,0.5,0.5;0,0,0]; %0.9/0.6/0.2 or 1,0.7,0
plot_info.celltype_names = {'Sound','Δ Stim'};
% Set labels for plots.
plot_info.behavioral_contexts = {'Sound','Δ Stim'}; %decide which contexts to plot
params.plot_info = plot_info;
st = plot_connected_abs_mod_by_mouse(current_save_dir, adjusted_std, [1:24],...
          params.plot_info, [0,.25],0,'Std. Population Activity');

ctx = 1;
heatmap_info = cell2mat(squeeze(all_data_celltypes_datasets(:,ctx,1,[1,3])));
[~,sort_id] = sort(heatmap_info(:,1));
figure(1);clf;
hold on
bar(heatmap_info(sort_id,1),'stack','FaceColor',[0.3,0.2,0.6]);
bar(heatmap_info(sort_id,2),'stack','FaceColor','black'); %[.6,.6,.6]); %[0.8 0 0.2]);
% mod_index_heatmap([],heatmap_info,plot_info,[1:24],[-.5,.5])

adjusted_std2 = squeeze(all_std_across_celltypes_datasets(:,:,[1:3],[3])); %using all cell types (1 = sound,2 sound+3, 3 delta stim) %datasets, contexts, cell types, type of data
adjusted_std = permute(adjusted_std2, [1 2 3]);
plot_info.colors_celltypes = [0,0,0;0.5,0.5,0.5;0,0,0]; %0.9/0.6/0.2 or 1,0.7,0
plot_info.celltype_names = {'Sound','Opto','Sound&Opto'};
% Set labels for plots.
plot_info.behavioral_contexts = {'Active','Passive'}; %decide which contexts to plot
plot_info.y_lims = [-.2, .4];
% Set labels for plots.
plot_info.behavioral_contexts = {'Active','Passive'}; %decide which contexts to plot
plot_info.colors_celltypes = [0.3,0.2,0.6 ; 1,0.7,0; 0.3,0.8,1; 0.5,0.5,0.5]; %0.9/0.6/0.2 or 1,0.7,0
params.plot_info = plot_info;
st = plot_connected_abs_mod_by_mouse(current_save_dir, adjusted_std, [1:24],...
          params.plot_info, [0,.7],0,'Std. Pop. Activity (Δ Stim)');

st = plot_connected_abs_mod_by_mouse(current_save_dir, squeeze(all_std_across_celltypes_datasets(:,:,[1:3],[2])), [1:24],...
          params.plot_info, [0,.7],0,'Std. Pop. Activity (Stim + Sound)');

st = plot_connected_abs_mod_by_mouse(current_save_dir, squeeze(all_std_across_celltypes_datasets(:,:,[1:3],[1])), [1:24],...
          params.plot_info, [0,.5],0,'Std. Pop. Activity (Sound)');
%% cdf of delta stim across active and passive
cdf_data = squeeze(all_data_celltypes_datasets(:,:,1:3,3));%using all cell types (4th # 1 = sound,2 sound+3, 3 delta stim)
plot_info.lineStyles_contexts = {'-',':'};
plot_info.colors = [0.3,0.2,0.6 ; 1,0.7,0; 0.3,0.8,1; 0.5,0.5,0.5]; %0.9/0.6/0.2 or 1,0.7,0

mod_stats = plot_cdf_celltypes('V:\Connie\results\opto_sound_2025\context\mod_index_specified_cells\differences_pre_post\dff\', cdf_data, 1:24, plot_info,'\Delta Stim',[-.1,0.3],0);
%% make plots but using PYR/SOM/PV as the celltypes
current_save_dir = 'V:\Connie\results\opto_sound_2025\context\mod_index_specified_cells\differences_pre_post\dff\celltypes'; %'V:\Connie\results\opto_sound_2025\context\mod_index_specified_cells\differences_pre_post\dff';

[all_corr_across_celltypes_datasets,all_corr_across_celltypes,all_means_across_celltypes_datasets,all_std_across_celltypes_datasets,all_data_celltypes_datasets] = compute_means_correlations_per_dataset([], all_celltypes, avg_ctrl_post, diff_stim, avg_post);

plot_info.celltype_names = {'PYR','PV','SOM'};
plot_info.y_lims = [-.2, .4];
% Set labels for plots.
plot_info.behavioral_contexts = {'Active','Passive'}; %decide which contexts to plot
plot_info.colors_celltypes = [0.37 0.75 0.49 %green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04]; %red

params.plot_info = plot_info;

st = plot_connected_abs_mod_by_mouse(current_save_dir, all_corr_across_celltypes_datasets(:,:,1:3), [1:24],...
          params.plot_info, [-1,1],0,'Corr (Sound vs Δ Stim)');

st = plot_connected_abs_mod_by_mouse([], all_corr_across_celltypes_datasets(:,:,4), [1:24],...
          params.plot_info, [-1,1],0,'Corr (Sound vs Δ Stim)');

adjusted_std2 = squeeze(all_std_across_celltypes_datasets(:,:,[1:3],[3])); %using all cell types (1 = sound,2 sound+3, 3 delta stim) %datasets, contexts, cell types, type of data
adjusted_std = permute(adjusted_std2, [1 2 3]);
params.plot_info = plot_info;
st = plot_connected_abs_mod_by_mouse(current_save_dir, adjusted_std, [1:24],...
          params.plot_info, [0,.3],0,'Std. Pop. Activity (Δ Stim)');

st = plot_connected_abs_mod_by_mouse(current_save_dir, squeeze(all_std_across_celltypes_datasets(:,:,[1:3],[2])), [1:24],...
          params.plot_info, [0,.3],0,'Std. Pop. Activity (Stim + Sound)');

st = plot_connected_abs_mod_by_mouse(current_save_dir, squeeze(all_std_across_celltypes_datasets(:,:,[1:3],[1])), [1:24],...
          params.plot_info, [0,.2],0,'Std. Pop. Activity (Sound)');


%%
ctx = 'act';

for pool_to_look = 1:3; 

cov_val = cov([sound_post.(ctx){1,pool_to_look}],[delta_stim.(ctx){1,pool_to_look}]);
covariance_metrix = cov_val(1,2); %off diagonal
corr_val = corr([sound_post.(ctx){1,pool_to_look}]',[delta_stim.(ctx){1,pool_to_look}]');

x_z = zscore([sound_post.(ctx){1,pool_to_look}]);
dx_z = zscore([delta_stim.(ctx){1,pool_to_look}]);
dp_z = dot(x_z, dx_z) / (norm(x_z) * norm(dx_z));
all_vals.(ctx)(pool_to_look) = corr_val;
end
% dp = dot([sound_post.(ctx){1,pool_to_look}],[delta_stim.(ctx){1,pool_to_look}]);
% dp_norm = dp / (norm([sound_post.(ctx){1,pool_to_look}])*norm([delta_stim.(ctx){1,pool_to_look}]));
%%
summary_table = summarize_group_correlations(sound_post.(ctx),delta_stim.(ctx), pooled_cell_types);
disp(summary_table);

figure;
bar(categorical(summary_table.Group), summary_table.Correlation);
hold on;
errorbar(categorical(summary_table.Group), summary_table.Correlation, summary_table.SEM, 'k.', 'LineWidth', 1);
ylabel('Correlation (baseline vs delta)');
title('Group-wise reshuffling summary');
yline(0, '--', 'Color', [0.5 0.5 0.5]);
box off;


%%
[dff_response,~] = unpack_context_mouse_celltypes(context_data.dff,[],all_celltypes,[1:25]); %context_data.deconv_interp
[dff_trial_cel_mouse_pre,dff_context_celltype] = calc_avg_rate_across_context_celltype_choosetrials(dff_response,50:59,stim_trials_context, ctrl_trials_context);
[dff_trial_cel_mouse_post,dff_context_celltype2] = calc_avg_rate_across_context_celltype_choosetrials(dff_response,63:92,stim_trials_context, ctrl_trials_context);

% if wanted to do deconvolved
% [deconv_response,~] = unpack_context_mouse_celltypes(context_data.deconv_interp,[],all_celltypes,[1:25]); %context_data.deconv_interp
% [dff_trial_cel_mouse_pre,dff_context_celltype] = calc_spike_rate_across_context_celltype_choosetrials(deconv_response,50:59,stim_trials_context, ctrl_trials_context);
% [dff_trial_cel_mouse_post,dff_context_celltype2] = calc_spike_rate_across_context_celltype_choosetrials(deconv_response,63:92,stim_trials_context, ctrl_trials_context);

[dff_context_matrix_pre,dff_context_matrix_ctrl_pre] = into_mod_structure(dff_trial_cel_mouse_pre,all_celltypes); %same as mod structure for easy plotting!
[dff_context_matrix_post,dff_context_matrix_ctrl_post] = into_mod_structure(dff_trial_cel_mouse_post,all_celltypes); %same as mod structure for easy plotting!


%make scatter plots and save them!
current_save_dir = ''; %'V:\Connie\results\opto_sound_2025\context\mod_index_specified_cells\differences_pre_post\dff';
modl_fit = scatter_index_sigcells_histogram([], pooled_cell_types, [{diff_pre_stim{:,1}}',{diff_stim{:,1}}'], plot_info, current_save_dir, 'Pre Diff (active - passive)', 'Active Post (stim+sound - sound)',[-.6,2]);
modl_fit = scatter_index_sigcells_histogram([], pooled_cell_types, [{diff_pre_stim{:,1}}',{diff_stim{:,2}}'], plot_info, current_save_dir, 'Pre Diff (active - passive)', 'Passive Post (stim+sound - sound)',[-.6,2]);

modl_fit = scatter_index_sigcells_histogram([], pooled_cell_types, [{diff_pre_ctrl{:,1}}',{dff_context_matrix_ctrl_post{:,1}}'], plot_info, current_save_dir, 'Pre Diff (active - passive)', 'Active Post (sound)',[-.6,2]);
modl_fit = scatter_index_sigcells_histogram([], pooled_cell_types, [{diff_pre_ctrl{:,1}}',{dff_context_matrix_ctrl_post{:,2}}'], plot_info, current_save_dir, 'Pre Diff (active - passive)', 'Passive Post (sound)',[-.6,2]);

[preavg_index_by_dataset,~] = unpack_modindexm(dff_context_matrix_pre,[],pooled_cell_types,[1:24]);
preavg_stats_celltypes_dataset = plot_connected_abs_mod_by_mouse(current_save_dir, preavg_index_by_dataset, [1:24],...
          params.plot_info, [0,.3],0,'Pre Mean (ΔF/F)');

%across celltypes
plot_info.colors_celltypes = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04]; % red  
[preavg_index_by_dataset_ct,~] = unpack_modindexm(dff_context_matrix_pre,[],all_celltypes,[1:24]);
preavg_stats_celltypes_dataset_ct = plot_connected_abs_mod_by_mouse([current_save_dir '/celltypes'], preavg_index_by_dataset_ct, [1:24],...
          plot_info, [0,.3],0,'Pre Mean (ΔF/F)');

%%
modl_fit = scatter_index_sigcells_histogram([], pooled_cell_types, [{dff_context_matrix_pre{:,1}}',{diff_stim{:,1}}'], plot_info, current_save_dir, 'Pre Active', 'Active Post (stim+sound - sound)',[-.6,2]);
modl_fit = scatter_index_sigcells_histogram([], pooled_cell_types, [{dff_context_matrix_pre{:,2}}',{diff_stim{:,2}}'], plot_info, current_save_dir, 'Pre Passive', 'Passive Post (stim+sound - sound)',[-.6,2]);

modl_fit = scatter_index_sigcells_histogram([], pooled_cell_types, [{dff_context_matrix_ctrl_pre{:,1}}',{dff_context_matrix_ctrl_post{:,1}}'], plot_info, current_save_dir, 'Pre Diff (active - passive)', 'Active Post (sound)',[-.6,2]);
modl_fit = scatter_index_sigcells_histogram([], pooled_cell_types, [{dff_context_matrix_ctrl_pre{:,2}}',{dff_context_matrix_ctrl_post{:,2}}'], plot_info, current_save_dir, 'Pre Diff (active - passive)', 'Passive Post (sound)',[-.6,2]);
