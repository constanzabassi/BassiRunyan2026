contexts_to_compare = [1,2];

params = experiment_config(); 
plot_info = plotting_config(); %plotting params
params.plot_info = plot_info;
load('V:\Connie\results\opto_sound_2025\context\data_info\all_celltypes.mat');

% context_data has ctrl as ctrl only, context_data_sounds concatenated ctrl with sound only trials!
[sound,opto,sorted_cells,all_celltypes,context_data,ctrl_trials_context,stim_trials_context, context_data_sounds] = load_processed_opto_sound_data(params,{'separate','separate'});
% keep sound opto sorted_cells all_celltypes context_data ctrl_trials_context stim_trials_context  context_data_sounds
%% Sound Index Plots
mod_params = params.mod_sounds;
mod_params.mod_threshold = .1;% 0 is no threshold applied
mod_params.chosen_mice = [1:25];
mod_params.min_cells = 1;
% 1) load data
%load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\mod_indexm.mat');
% load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\sig_mod_boot_thr.mat');
% load('V:\Connie\results\opto_sound_2025\context\sounds\data_info\context_data.mat');
%%%% sig cells %%%%%%%%%%%
plot_info.y_lims = [-.4, .4];
% Set labels for plots.
plot_info.plot_labels = {'Sounds','Sounds'}; % Alternative could be {'Left Sounds','Right Sounds'}
plot_info.behavioral_contexts = {'Active','Passive'}; %decide which contexts to plot
overlap_labels = {'Active', 'Passive','Both'}; %{'Active', 'Passive','Both'}; % {'Active', 'Passive','Both'}; %{'Active', 'Passive','Spont','Both'}; %
plot_info.type = 'sounds';
params.plot_info = plot_info;
params.info.chosen_mice = [1:25];
params.string = 'Sounds';

%%%% sig cells %%%%%%%%%%%
savepath = 'W:\Connie\results\Bassi2025\fig3\sounds\mod\prepost_sound\separate\sig_neurons';
[combined_sig_cells, ~] = union_sig_cells(sound.sig_mod_boot_thr(:,1)', sound.sig_mod_boot_thr(:,2)', sound.mod);
%single neurons
plot_info.y_lims = [-.4, .4];params.plot_info = plot_info;
mod_index_stats = plot_context_comparisons(contexts_to_compare,overlap_labels, sound.mod, sound.sig_mod_boot_thr, all_celltypes, params, savepath);
%datasets
plot_info.y_lims = [-.2, .3];params.plot_info = plot_info;
mod_index_stats_datasets = generate_mod_index_plots_datasets(params.info.chosen_mice, sound.mod, combined_sig_cells, all_celltypes, params, savepath);
%avg traces
savepath_traces = 'W:\Connie\results\Bassi2025\fig3\sounds\celltype_traces\';
[traces_mean,dataset_ids] = wrapper_avg_cell_type_traces(context_data_sounds.dff,all_celltypes,sound.mod,sound.sig_mod_boot_thr,mod_params,savepath_traces,'sound_dff',plot_info);
%%% STATS TABLES
% table_fig3 = make_stats_tables_mod_index(mod_index_stats, mod_index_stats_datasets, save_dir);

%%%% all cells %%%%%%%%%%%
%save directory
save_dir = 'W:\Connie\results\Bassi2025\fig3\sounds\mod\prepost_sound\separate\';% '/spont_sig'];% '/spont_sig']; %[info.savepath '/mod/' mod_params.mod_type '/spont_sig']; % Set directory to save figures.

%single neurons
plot_info.y_lims = [-.4, .4];params.plot_info = plot_info;
mod_index_stats = plot_context_comparisons(contexts_to_compare,overlap_labels, sound.mod, [], all_celltypes, params, save_dir);
plot_info.y_lims = [-.2, .20];params.plot_info = plot_info;
%datasets
mod_index_stats_datasets = generate_mod_index_plots_datasets(params.info.chosen_mice, sound.mod, [], all_celltypes, params, save_dir);
%avg traces
savepath_traces = 'W:\Connie\results\Bassi2025\fig3\sounds\celltype_traces\all_cells\';
mod_params.mod_threshold = 0.001;
mod_params.threshold_single_side =1;
[num_cells, ~] = organize_pooled_celltypes(context_data_sounds.dff, all_celltypes);
all_cells =  repmat(arrayfun(@(n) 1:n, num_cells, 'UniformOutput', false),2,1)';
[traces_mean,dataset_ids] = wrapper_avg_cell_type_traces(context_data_sounds.dff,all_celltypes,sound.mod,all_cells,mod_params,savepath_traces,'sound_dff',plot_info);
%%% STATS TABLES
% table_fig3 = make_stats_tables_mod_index(mod_index_stats, mod_index_stats_datasets, save_dir);
%% Photostim Index plots

mod_params = params.mod;
mod_params.mod_threshold = .1;% 0 is no threshold applied
mod_params.chosen_mice = [1:24];
params.string = 'opto';
mod_params.min_cells = 1; %2 matches mod index summary scatter plot

%%% plot heatmaps and percentage modulated (spont)
context_num = 3;
[percentage_stats] = plot_sig_mod_pie(mod_params, opto.mod_prepost, opto.sig_mod_boot_thr, context_num, 'W:\Connie\results\Bassi2025\fig3\mod\', 'horizontal',all_celltypes);
params.savepath = 'W:\Connie\results\Bassi2025\fig3\avg_heatmaps';
generate_neural_heatmaps_simple_contextdata(context_data,opto.sig_mod_boot_thr(:,context_num )',[1:24], params, 'opto',context_num,'Time from stim onset (s)');

% 1) load data
% load('V:\Connie\results\opto_sound_2025\context\mod\prepost\separate\sig_mod_boot_thr.mat')% sig neurons based on pre post spont
% sig_mod_boot = opto.sig_mod_boot;% load('V:\Connie\results\opto_sound_2025\context\mod\prepost\separate\sig_mod_boot.mat')
% load('V:\Connie\results\opto_sound_2025\context\mod\ctrl\separate\mod_indexm.mat')

% Set y-axis limits for the plots.
plot_info.y_lims = [-.4, .4];
params.info.chosen_mice = mod_params.chosen_mice;
% Set labels for plots.
plot_info.plot_labels = {'Stim','Ctrl'}; % Alternative could be {'Left Sounds','Right Sounds'}
plot_info.behavioral_contexts = {'Active','Passive'}; %decide which contexts to plot
overlap_labels = {'Active', 'Passive','Both'}; %{'Active', 'Passive','Both'}; % {'Active', 'Passive','Both'}; %{'Active', 'Passive','Spont','Both'}; %
plot_info.type = 'stim';
params.plot_info = plot_info;

%%%% sig cells %%%%%%%%%%%
savepath = 'W:\Connie\results\Bassi2025\fig3\mod\ctrl\separate\sig_neurons';
%single neurons
mod_index_stats = plot_context_comparisons(contexts_to_compare,overlap_labels, opto.mod, opto.sig_mod_boot_thr(:,3), all_celltypes, params,savepath); %single neurons
%datasets
plot_info.y_lims = [-.2, .4]; params.plot_info = plot_info;
mod_index_stats_datasets = generate_mod_index_plots_datasets(params.info.chosen_mice, opto.mod,  opto.sig_mod_boot_thr(:,3)', all_celltypes, params,savepath);
savepath_traces = 'W:\Connie\results\Bassi2025\fig3\celltype_traces\';
%stim+sound avg
[traces_mean,dataset_ids] = wrapper_avg_cell_type_traces(context_data.dff,all_celltypes,opto.mod,opto.sig_mod_boot,mod_params,savepath_traces,'opto_dff',plot_info,opto.mod_prepost); 
%stim+sound - sound avg (difference)
[traces_mean_diff,dataset_ids_diff] = wrapper_avg_cell_type_traces_stim_minus_ctrl(context_data.dff,all_celltypes,opto.mod,opto.sig_mod_boot,mod_params,savepath_traces,'opto_dff',plot_info,opto.mod_prepost);
table_fig3_evoked = make_stats_tables_evoked(traces_mean, traces_mean_diff, 'avg_traces', {'PYR', 'SOM', 'PV'},63:92, savepath_traces); %save stats table
%%% STATS TABLES
% table_fig3 = make_stats_tables_mod_index(mod_index_stats, mod_index_stats_datasets, save_dir);


%%%% all cells %%%%%%%%%%%
plot_info.y_lims = [-.4, .4];params.plot_info = plot_info;
%save directory
savepath = 'W:\Connie\results\Bassi2025\fig3\mod\ctrl\separate';%

%single neurons
mod_index_stats = plot_context_comparisons(contexts_to_compare,overlap_labels, opto.mod, [], all_celltypes, params,savepath);%single neurons
plot_info.y_lims = [-.2, .2];params.plot_info = plot_info;
%datasets
mod_index_stats_datasets = generate_mod_index_plots_datasets(params.info.chosen_mice, opto.mod,  [], all_celltypes, params,savepath);
%stim+sound avg
mod_params.mod_threshold = 0.001;
mod_params.threshold_single_side =1;
[num_cells, ~] = organize_pooled_celltypes(context_data.dff, all_celltypes);
all_cells =  repmat(arrayfun(@(n) 1:n, num_cells, 'UniformOutput', false),3,1)';
savepath_traces = 'W:\Connie\results\Bassi2025\fig3\celltype_traces\all_cells\';
[traces_mean,dataset_ids] = wrapper_avg_cell_type_traces(context_data.dff,all_celltypes,opto.mod,all_cells,mod_params,savepath_traces,'opto_dff',plot_info,opto.mod_prepost);
%stim+sound - sound avg (difference)
% plot_info.trace_ylims = [-.01, .03];
[traces_mean_diff,dataset_ids_diff] = wrapper_avg_cell_type_traces_stim_minus_ctrl(context_data.dff,all_celltypes,opto.mod,all_cells,mod_params,savepath_traces,'opto_dff',plot_info,opto.mod_prepost);
table_fig3_evoked = make_stats_tables_evoked(traces_mean, traces_mean_diff, 'avg_traces', {'PYR', 'SOM', 'PV'},63:92, savepath_traces); %save stats table
%%% STATS TABLES
% table_fig3 = make_stats_tables_mod_index(mod_index_stats, mod_index_stats_datasets, save_dir);
%%% to close anovas close hidden all
%% Engagement Index Plots
% 1) load data
load('W:\Connie\results\Bassi2025\fig3\mod\pre_engagement\simple\sig_mod_boot_thr.mat');
load('W:\Connie\results\Bassi2025\fig3\mod\pre_engagement\simple\sig_mod_boot.mat');
load('W:\Connie\results\Bassi2025\fig3\mod\pre_engagement\simple\mod_indexm.mat');
contexts_to_compare = [1]; %[1:3];%[1,2]; %[1,2]; %[1:3];
overlap_labels = {'Act - Pass'}; %{'Active', 'Passive','Both'}; % {'Active', 'Passive','Both'}; %{'Active', 'Passive','Spont','Both'}; %
savepath = 'W:\Connie\results\Bassi2025\fig3\mod\pre_engagement\simple\';
mod_params.mod_threshold = .1;% 0 is no threshold applied
mod_params.chosen_mice = [1:25];
mod_params.min_cells = 1;

params.info.chosen_mice = mod_params.chosen_mice;
plot_info.y_lims = [-.3, .3];
plot_info.behavioral_contexts = {'Engagement Index'}; %decide which contexts to plot
plot_info.type = 'engagement'; %make lines gray instead of yellow

[context_mod_all, ~, ~, ~, celltypes_ids] = ...
    organize_sig_mod_index_contexts_celltypes([1:24], mod_indexm', sig_mod_boot_thr, all_celltypes,plot_info.celltype_names);

%%%%%% sig cells (celltypes) %%%%%
plot_info.y_lim_ratio = 2;
params.plot_info = plot_info;
mod_index_stats_datasets_all = generate_engagement_index_plots_datasets(params.info.chosen_mice, mod_indexm', sig_mod_boot_thr, all_celltypes, params, ['W:\Connie\results\Bassi2025\fig3\mod\pre_engagement\simple'] , celltypes_ids,plot_info.y_lims);

%%%%%% all cells (celltypes) %%%%%%%%
%plot all neurons including not engaged ones
plot_info.y_lim_ratio = 2;
params.plot_info = plot_info;
mod_index_stats_datasets_all = generate_engagement_index_plots_datasets(params.info.chosen_mice, mod_indexm', [], all_celltypes, params, ['W:\Connie\results\Bassi2025\fig3\mod\pre_engagement\simple/all'] , celltypes_ids,plot_info.y_lims);

savepath = ['W:\Connie\results\Bassi2025\fig3\pre_engagement\celltype_traces\'];
wrapper_avg_cell_type_traces_engagement(context_data.dff,all_celltypes,mod_indexm,sig_mod_boot_thr,mod_params,savepath,'engagement_dff',plot_info, plot_info.celltype_names,plot_info.colors_celltypes_3contexts);

%%%%%% functional comparisons! %%%%%%%%

% sig cells (including unmodulated)
[pooled_cell_types,plot_info.celltype_names,plot_info.colors_celltypes] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'sound','opto','both','unmodulated'},[1:24],plot_info, 1);
params.plot_info = plot_info;
params.info.chosen_mice = [1:24]; %because last dataset is control and should not be considered with photostim
% plot_info.celltype_names = {'Sound','Photostim','S + P','Unmodulated'}; %// could say both or S&P?
mod_pooled_index_stats_datasets = generate_engagement_index_plots_datasets(params.info.chosen_mice, mod_indexm',  sig_mod_boot_thr, pooled_cell_types, params, ['W:\Connie\results\Bassi2025\fig3\mod\pre_engagement\simple/functional_pools/'], celltypes_ids,plot_info.y_lims);

[pooled_cell_types,plot_info.celltype_names,plot_info.colors_celltypes] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'sound','opto','both'},[1:24],plot_info, 1);
params.plot_info = plot_info;
params.info.chosen_mice = [1:24]; %because last dataset is control and should not be considered with photostim
% plot_info.celltype_names = {'Sound','Photostim','S + P','Unmodulated'}; %// could say both or S&P?
mod_pooled_index_stats_datasets = generate_engagement_index_plots_datasets(params.info.chosen_mice, mod_indexm',  sig_mod_boot_thr, pooled_cell_types, params, ['W:\Connie\results\Bassi2025\fig3\mod\pre_engagement\simple/functional_pools_nounmod/'], celltypes_ids,plot_info.y_lims);

% making this plot in another script (run_prepost_analysis_updated)
% mod_params.chosen_mice = [1:24]; %1 less for opto control
% savepath = ['W:\Connie\results\Bassi2025\fig3\pre_engagement\functional_celltype_traces\'];
% wrapper_avg_cell_type_traces_engagement(context_data.dff,pooled_cell_types,mod_indexm,sig_mod_boot_thr,mod_params,savepath,'engagement_dff',plot_info,plot_info.celltype_names,plot_info.colors_pooled_3contexts); %repelem(plot_info.functional_colors, 3, 1)

%%%% plot fraction + and - modulated per functional group
[pooled_cell_types,plot_info.functional_names,plot_info.functional_colors] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'sound','opto','both'},[1:24],plot_info, 1); %,'unmodulated'
%separate by positive and negative modulation
param_sets = { 
    struct('mod_threshold', mod_params.mod_threshold, 'threshold_single_side', 1, 'savestring', [ 'positive_modulated'],'chosen_mice', mod_params.chosen_mice),
    struct('mod_threshold', -1 * mod_params.mod_threshold, 'threshold_single_side', 1, 'savestring', [ 'negative_modulated'],'chosen_mice', mod_params.chosen_mice),
};
mod_params.chosen_mice = 1:24;
for i = 1:length(param_sets)
        mod_params_plot = param_sets{i};
        mod_params_plot.data_type = 'engagement';
        %get the significant neurons (positive, negative, both);
        [current_sig_cells] = get_thresholded_sig_cells_simple( mod_params_plot, mod_indexm', sig_mod_boot'); %using mod_indexm2 because using prepost instead of ctrl for opto
        percent_cells_signed{i} = calculate_sig_celltype_percentages(current_sig_cells(1:24), pooled_cell_types, []);
end
[~,percent_bar_stats] = bar_plot_percent(percent_cells_signed{1},percent_cells_signed{2}, ['W:\Connie\results\Bassi2025\fig3\mod\pre_engagement\simple/functional_pools/'],plot_info.functional_names,plot_info.functional_colors,{'Positive','Negative'});

%%% generate the difference plot
% taking the differences
frames_to_sort = 50:59; %used for sorting
plot_active_passive_diff_heatmap(context_data, frames_to_sort, 'Time from stimulus onset (s)', 'W:\Connie\results\Bassi2025\fig3\pre_engagement');

