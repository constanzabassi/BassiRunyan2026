contexts_to_compare = [1,2];

params = experiment_config(); 
plot_info = plotting_config(); %plotting params
params.plot_info = plot_info;
load('V:\Connie\results\opto_sound_2025\context\data_info\all_celltypes.mat');

% context_data has ctrl as ctrl only, context_data_sounds concatenated ctrl with sound only trials!
[sound,opto,sorted_cells,all_celltypes,context_data,ctrl_trials_context,stim_trials_context, context_data_sounds] = load_processed_opto_sound_data(params,{'separate','separate'});
% keep sound opto sorted_cells all_celltypes context_data ctrl_trials_context stim_trials_context  context_data_sounds
%% plot preferences
get_side_counts_per_celltype(opto.results,all_celltypes,opto.sig_cells, 1:24, plot_info);
get_side_counts_per_celltype(sound.results,all_celltypes,sound.sig_cells, 1:25, plot_info);

sound= get_left_right_mod(sound);
opto = get_left_right_mod(opto);
%%
for side = 1:2
    % Sound Index Plots
    mod_params = params.mod_sounds;
    mod_params.mod_threshold = .1;% 0 is no threshold applied
    mod_params.chosen_mice = [1:25];
    mod_params.min_cells = 0; % >0 so at least 1 modulated neuron per dataset
    % 1) load data
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

    if side == 1
        sound_mod = sound.mod_left;
        opto_mod = opto.mod_left;
        savestring = 'left';
    else
        sound_mod = sound.mod_right;
        opto_mod = opto.mod_right;
        savestring = 'right';
    end
    
    savepath = fullfile('W:\Connie\results\Bassi2025\fig3\sounds\mod\prepost_sound\separate\sig_neurons',savestring,'\');
    savepath_traces = fullfile('W:\Connie\results\Bassi2025\fig3\sounds\celltype_traces\',savestring,'\');
    savepath_traces_all = fullfile('W:\Connie\results\Bassi2025\fig3\sounds\celltype_traces\all_cells\',savestring,'\');
    save_dir = fullfile('W:\Connie\results\Bassi2025\fig3\sounds\mod\prepost_sound\separate\',savestring,'\');% 
    
    %%%% sig cells %%%%%%%%%%%
    
    [combined_sig_cells, ~] = union_sig_cells(sound.sig_mod_boot_thr(:,1)', sound.sig_mod_boot_thr(:,2)', sound_mod);
    %single neurons
    plot_info.y_lims = [-.4, .4];params.plot_info = plot_info;
    mod_index_stats = plot_context_comparisons(contexts_to_compare,overlap_labels, sound_mod, sound.sig_mod_boot_thr, all_celltypes, params, savepath);
    %datasets
    plot_info.y_lims = [-.2, .3];params.plot_info = plot_info;
    mod_index_stats_datasets = generate_mod_index_plots_datasets(params.info.chosen_mice, sound_mod, combined_sig_cells, all_celltypes, params, savepath);    
    
    %%% STATS TABLES
    table_fig3 = make_stats_tables_mod_index(mod_index_stats, mod_index_stats_datasets, savepath);
    
    %%%% all cells %%%%%%%%%%%
    
    %single neurons
    plot_info.y_lims = [-.4, .4];params.plot_info = plot_info;
    mod_index_stats = plot_context_comparisons(contexts_to_compare,overlap_labels, sound_mod, [], all_celltypes, params, save_dir);
    plot_info.y_lims = [-.2, .20];params.plot_info = plot_info;
    %datasets
    mod_index_stats_datasets = generate_mod_index_plots_datasets(params.info.chosen_mice, sound_mod, [], all_celltypes, params, save_dir);
    % %%% STATS TABLES
    table_fig3 = make_stats_tables_mod_index(mod_index_stats, mod_index_stats_datasets, save_dir);
    
    % Photostim Index plots
    mod_params = params.mod;
    mod_params.mod_threshold = .1;% 0 is no threshold applied
    mod_params.chosen_mice = [1:24];
    params.string = 'opto';
    mod_params.min_cells = 0; %at least 1 neuron per dataset that is modulated! (>0 is the logic)
    params.min_cells = mod_params.min_cells;
    
    % Set y-axis limits for the plots.
    plot_info.y_lims = [-.4, .4];
    params.info.chosen_mice = mod_params.chosen_mice;
    % Set labels for plots.
    plot_info.plot_labels = {'Stim','Ctrl'}; % Alternative could be {'Left Sounds','Right Sounds'}
    plot_info.behavioral_contexts = {'Active','Passive'}; %decide which contexts to plot
    overlap_labels = {'Active', 'Passive','Both'}; %{'Active', 'Passive','Both'}; % {'Active', 'Passive','Both'}; %{'Active', 'Passive','Spont','Both'}; %
    plot_info.type = 'stim';
    params.plot_info = plot_info;
    
    %savepaths 
    savepath_all = fullfile('W:\Connie\results\Bassi2025\fig3\mod\ctrl\separate\',savestring,'\');%
    savepath = fullfile('W:\Connie\results\Bassi2025\fig3\mod\ctrl\separate\sig_neurons\',savestring,'\');
    savepath_traces = fullfile('W:\Connie\results\Bassi2025\fig3\celltype_traces\',savestring,'\');
    savepath_traces_all = fullfile('W:\Connie\results\Bassi2025\fig3\celltype_traces\all_cells\',savestring,'\');
    
    %%%% sig cells %%%%%%%%%%%
    
    %single neurons
    mod_index_stats = plot_context_comparisons(contexts_to_compare,overlap_labels, opto_mod, opto.sig_mod_boot_thr(:,3), all_celltypes, params,savepath); %single neurons
    %datasets
    plot_info.y_lims = [-.2, .4]; params.plot_info = plot_info;params.min_cells = mod_params.min_cells;
    mod_index_stats_datasets = generate_mod_index_plots_datasets(params.info.chosen_mice, opto_mod,  opto.sig_mod_boot_thr(:,3)', all_celltypes, params,savepath);
    %%% STATS TABLES
    table_fig3 = make_stats_tables_mod_index(mod_index_stats, mod_index_stats_datasets, savepath);
    
    
    %%%% all cells %%%%%%%%%%%
    plot_info.y_lims = [-.4, .4];params.plot_info = plot_info;
    %save directory
    
    %single neurons
    mod_index_stats = plot_context_comparisons(contexts_to_compare,overlap_labels, opto_mod, [], all_celltypes, params,savepath_all);%single neurons
    plot_info.y_lims = [-.2, .2];params.plot_info = plot_info;
    %datasets
    mod_index_stats_datasets = generate_mod_index_plots_datasets(params.info.chosen_mice, opto_mod,  [], all_celltypes, params,savepath_all);
    %%% STATS TABLES
    table_fig3 = make_stats_tables_mod_index(mod_index_stats, mod_index_stats_datasets, savepath_all);
    %%% to close anovas close hidden all
end