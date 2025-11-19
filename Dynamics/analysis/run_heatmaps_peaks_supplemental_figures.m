plot_info = plotting_config(); %plotting params
%loading from different directory bc mice have to match between
%active,passive,spont
[info, alignment, plot_info, bin_size,imaging_st,all_celltypes,imaging_passive] = get_alignment_config_dynamics('W:/Connie/results/Bassi2025/fig1', 'V:\Connie\results\active\data_info', plot_info, 'V:\Connie\results\passive\data_info')
[imaging_st,info.eliminated_trials] = eliminate_trials(imaging_st,7,800);


alignment.conditions = [1,2]; %empty to run all conditions [5:8];
alignment.field_to_separate = {'is_stim_trial'}; %will separate into two parts control then stim

% save_path = 'W:/Connie/results/Bassi2025/fig3/avg_heatmap_across_entire_trial/';
%% HEATMAPS
%load sound modulated neurons
load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\mod_indexm.mat');
load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\sig_mod_boot.mat');
load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\sig_mod_boot_thr.mat');

%% HEATMAPS SORTED BY SPONT!!
figure_height = [185]; %155/165
save_path = 'W:/Connie/results/Bassi2025/fig3/avg_heatmap_across_entire_trial_stretched_updated/';
load('V:\Connie\results\opto_sound_2025\context\mod\prepost\separate\sig_mod_boot_thr.mat');% get spontaneously defined modulated neurons

load('V:\Connie\results\opto_sound_2025\context\data_info\context_data.mat'); %to plot spont context
% sorting_id_updated_datasets = get_sorting_indices_only(imaging_st, alignment, bin_size, sig_mod_boot, 0)
sig_mod_boot = sig_mod_boot_thr(:,3);
% [~,sorting_id_updated_datasets] = heatmaps_avg_combined_selected_cells_spont (context_data, plot_info,alignment,[],[save_path],1, sig_mod_boot,0);
avg_across_datasets = 0; do_plot = 1;  plot_info.position = [100,100,131,figure_height];
[~,sorting_id_updated_datasets] = heatmaps_avg_combined_selected_cells_spont_refactored( ...
        context_data, plot_info, alignment, [], ...
        save_path, [], sig_mod_boot, ...
        avg_across_datasets, do_plot);

%plot heatmaps and grand avg for active context
alignment.conditions = [1,2]; %empty to run all conditions [5:8];
alignment.number = [1:6]; %'reward','turn','stimulus'
alignment.type = 'all';        plot_info.position =  [100,100,225,figure_height]; %[100,100,215,155];
heatmaps_avg_combined_selected_cells_refactored (imaging_st,plot_info,alignment,sorting_id_updated_datasets(2,:),[save_path 'photostim/sorted'],bin_size, sig_mod_boot,0,1);
alignment.number = [1:3]; %'reward','turn','stimulus'
alignment.type = 'stimulus';        plot_info.position = [100,100,112,figure_height];
heatmaps_avg_combined_selected_cells_refactored (imaging_passive,plot_info,alignment,sorting_id_updated_datasets(2,:),[save_path  'photostim' '/sorted/passive/'],bin_size, sig_mod_boot,0,2);
% 
% now do SOUNDS!
load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\mod_indexm.mat');
load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\sig_mod_boot.mat');
load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\sig_mod_boot_thr.mat');

% Define the parameter sets
mod_params.mod_threshold = 0.1;
mod_params.chosen_mice = [1:25];
param_sets = { 
    struct('mod_threshold', mod_params.mod_threshold, 'threshold_single_side', 1, 'savestring', [ 'sound_positive_modulated'],'chosen_mice', mod_params.chosen_mice,'data_type','sounds'),
    struct('mod_threshold', -1 * mod_params.mod_threshold, 'threshold_single_side', 1, 'savestring', [ 'sound_negative_modulated'],'chosen_mice', mod_params.chosen_mice,'data_type','sounds'),
    struct('mod_threshold', mod_params.mod_threshold, 'threshold_single_side', 0, 'savestring', [ 'sound_all_modulated'],'chosen_mice', mod_params.chosen_mice,'data_type','sounds')
    };


for i = 1:length(param_sets)
i
    %get sorting index
    [current_sig_cells] = get_thresholded_sig_cells_simple( param_sets{i}, mod_indexm, sig_mod_boot_thr);
    sig_cells = get_significant_neurons(current_sig_cells, mod_indexm, 'union'); %union of active and passive
    cumsum(cellfun(@length, sig_cells))
    
    %do active
    alignment.conditions = [1,2]; %empty to run all conditions [5:8];
    alignment.number = [1:6]; %'reward','turn','stimulus'
    alignment.type = 'all';
    sorting_id_updated_datasets_sounds = get_sorting_indices_only(imaging_st, alignment, bin_size, sig_cells, 1)
%     [~,sorting_id_updated_datasets_sounds] = heatmaps_avg_combined_selected_cells (imaging_st,plot_info,alignment,[],[],bin_size, sig_cells,0,1);
%     [~,sorting_id_updated_datasets_sounds2] = heatmaps_avg_combined_selected_cells (imaging_st,plot_info,alignment,[],[],bin_size, sig_cells,0,1);
%     sound_sorting = [sorting_id_updated_datasets_sounds(2,:);sorting_id_updated_datasets_sounds2(2,:)];
    sound_sorting = [sorting_id_updated_datasets_sounds(2,:)];

        mod_params_plots = param_sets{i};
        [current_sig_cells] = get_thresholded_sig_cells_simple( mod_params_plots, mod_indexm, sig_mod_boot_thr);
        sig_cells = get_significant_neurons(current_sig_cells, mod_indexm, 'union'); %union of active and passive
        cumsum(cellfun(@length, sig_cells))
        
        %do active
        alignment.conditions = [1,2]; %empty to run all conditions [5:8];
        alignment.number = [1:6]; %'reward','turn','stimulus'
        alignment.type = 'all';
        plot_info.position = [100,100,215,figure_height];
        heatmaps_avg_combined_selected_cells_refactored (imaging_st,plot_info,alignment,sound_sorting(1,:),[save_path mod_params_plots.savestring ],bin_size, sig_cells,0,1);

        %do passive
        alignment.number = [1:3]; %'reward','turn','stimulus'
        alignment.type = 'stimulus';
        plot_info.position = [100,100,117,figure_height]; %had to adjust y for this because 
        heatmaps_avg_combined_selected_cells_refactored (imaging_passive,plot_info,alignment,sound_sorting(1,:),[save_path mod_params_plots.savestring '/passive/'],bin_size, sig_cells,0,2);
end

%% FIND NS for each plot!
for i = 1:length(param_sets)
i
    %get sorting index
    [current_sig_cells] = get_thresholded_sig_cells_simple( param_sets{i}, mod_indexm, sig_mod_boot_thr);
    sig_cells = get_significant_neurons(current_sig_cells, mod_indexm, 'union'); %union of active and passive
    total_n = cumsum(cellfun(@length, sig_cells))
    [total_sig_cells,total_sig_cells_per_dataset,sig_cells_permouse] = find_sig_celltypes_ns(sig_cells,all_celltypes);
    table_sound_heatmaps1 = struct2table_recursive(total_sig_cells,param_sets{i}.savestring);
    table_sound_heatmaps2 = struct2table_recursive(total_sig_cells_per_dataset,param_sets{i}.savestring);
    table_sound_heatmaps = [table_sound_heatmaps1;table_sound_heatmaps2];
    save(fullfile(save_path, strcat('table_',param_sets{i}.savestring,'.mat')), 'table_sound_heatmaps');
    writetable(table_sound_heatmaps, fullfile(save_path, strcat('table_sound_heatmaps_',param_sets{i}.savestring,'.csv')));
end