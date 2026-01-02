% Code to make 
% Active and passive pie charts of sound modulated (S5)
% Spont context heatmap and pie charts of opto modulated (S6)
% mod index plots of all cells (S7)

%%
contexts_to_compare = [1,2];

% 1) load data
% from main data
load('all_celltypes.mat'); load('sound.mat');load('opto.mat');load('plot_info');load('context_data');
% from supplemental
load('context_data_sounds');
params = experiment_config(); 
params.plot_info = plot_info;

%% Sound Index Plots
mod_params = params.mod_sounds;
mod_params.mod_threshold = .1;% 0 is no threshold applied
mod_params.chosen_mice = [1:25];
mod_params.min_cells = 0; % >0 so at least 1 modulated neuron per dataset

% Set labels for plots.
plot_info.behavioral_contexts = {'Active','Passive'}; %decide which contexts to plot
overlap_labels = {'Active', 'Passive','Both'}; %{'Active', 'Passive','Both'}; % {'Active', 'Passive','Both'}; %{'Active', 'Passive','Spont','Both'}; %
plot_info.type = 'sounds';
params.plot_info = plot_info;
params.info.chosen_mice = [1:25];
params.string = 'Sounds';
mod_params.results = sound.results;

%pie plots of modulated in active and passive contexts
%plot % modulated cells per context
plot_sig_mod_pie(mod_params, sound.mod, sound.sig_mod_boot_thr, [1], savepath, 'horizontal',all_celltypes);
plot_sig_mod_pie(mod_params, sound.mod, sound.sig_mod_boot_thr, [2], savepath, 'horizontal',all_celltypes);


%%%% all cells %%%%%%%%%%%
%avg traces
savepath_traces = [];
mod_params.mod_threshold =0;
mod_params.threshold_single_side =1;
[num_cells, ~] = organize_pooled_celltypes(context_data_sounds.dff, all_celltypes);
all_cells =  repmat(arrayfun(@(n) 1:n, num_cells, 'UniformOutput', false),2,1)';
[traces_mean,dataset_ids] = wrapper_avg_cell_type_traces(context_data_sounds.dff,all_celltypes,sound.mod,all_cells,mod_params,savepath_traces,'sound_dff',plot_info);

%save directory
save_dir = [];% 
plot_info.y_lims = [-.2, .20];params.plot_info = plot_info;
mod_index_stats_datasets = generate_mod_index_plots_datasets(params.info.chosen_mice, sound.mod, [], all_celltypes, params, save_dir);
% % %%% STATS TABLES
% table_fig3 = make_stats_tables_mod_index(mod_index_stats, mod_index_stats_datasets, save_dir);
% table_fig3_evoked = make_stats_tables_evoked(traces_mean,[], 'avg_traces', {'PYR', 'SOM', 'PV'},63:92, savepath_traces); %save stats table

%% Photostim Index plots
mod_params = params.mod;
mod_params.mod_threshold = .1;% 0 is no threshold applied
mod_params.chosen_mice = [1:24];
params.string = 'opto';
mod_params.min_cells = 0; %at least 1 neuron per dataset that is modulated! (>0 is the logic)
params.min_cells = mod_params.min_cells;
mod_params.results = opto.results;

%%% plot heatmaps and percentage modulated (spont context plots)
context_num = 3;
[percentage_stats] = plot_sig_mod_pie(mod_params, opto.mod_prepost, opto.sig_mod_boot_thr, context_num, [], 'horizontal',all_celltypes);
params.savepath = [];
generate_neural_heatmaps_simple_contextdata(context_data,opto.sig_mod_boot_thr(:,context_num )',[1:24], params, 'opto',context_num,'Time from stim onset (s)',[-0.5, 1],6);


% Set y-axis limits for the plots.
params.info.chosen_mice = mod_params.chosen_mice;
% Set labels for plots.
plot_info.plot_labels = {'Stim','Ctrl'}; % Alternative could be {'Left Sounds','Right Sounds'}
plot_info.behavioral_contexts = {'Active','Passive'}; %decide which contexts to plot
overlap_labels = {'Active', 'Passive','Both'}; %{'Active', 'Passive','Both'}; % {'Active', 'Passive','Both'}; %{'Active', 'Passive','Spont','Both'}; %
plot_info.type = 'stim';
params.plot_info = plot_info;

%%%% all cells %%%%%%%%%%%
%datasets
savepath_opto = [];
mod_index_stats_datasets = generate_mod_index_plots_datasets(params.info.chosen_mice, opto.mod,  [], all_celltypes, params,savepath_opto);

mod_params.mod_threshold = 0;
mod_params.threshold_single_side =1;
[num_cells, ~] = organize_pooled_celltypes(context_data.dff, all_celltypes);
all_cells =  repmat(arrayfun(@(n) 1:n, num_cells, 'UniformOutput', false),3,1)';
savepath_traces_opto = [];
%stim+sound - sound avg (difference)
% plot_info.trace_ylims = [-.01, .03];
[traces_mean_diff,dataset_ids_diff] = wrapper_avg_cell_type_traces_stim_minus_ctrl(context_data.dff,all_celltypes,opto.mod,all_cells,mod_params,savepath_traces_opto,'opto_dff',plot_info,opto.mod_prepost);

% table_fig3_evoked = make_stats_tables_evoked(traces_mean, traces_mean_diff, 'avg_traces', {'PYR', 'SOM', 'PV'},63:92, savepath_traces_opto); %save stats table
% %%% STATS TABLES
% table_fig3 = make_stats_tables_mod_index(mod_index_stats, mod_index_stats_datasets, savepath_all);
