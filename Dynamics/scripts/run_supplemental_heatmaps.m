%Code to make supplemental heatmaps in S5 and S6

% 1) load data
% from main data
load('plot_info.mat'); load('info.mat');load('all_celltypes.mat');
load('imaging_st.mat'); load('alignment.mat');
load('sound.mat'); load('opto.mat');load('context_data.mat');
% from supplemental passive
load('imaging_st_passive.mat')
alignment.conditions = [1,2]; %empty to run all conditions [5:8];
alignment.field_to_separate = {'is_stim_trial'}; %will separate into two parts control then stim

%% OPTO HEATMAPS SORTED BY SPONT!! (S6)
figure_height = [185]; %155/165
plot_info.gradavg_ylim = [-0.3,1.2];
bin_size = 1;
save_path = [];

avg_across_datasets = 0; do_plot = 1;  plot_info.position = [100,100,131*0.954,figure_height];
[~,sorting_id_updated_datasets] = heatmaps_avg_combined_selected_cells_spont_refactored( ...
        context_data, plot_info, alignment, [], ...
        save_path, [], opto.sig_cells, ...
        avg_across_datasets, do_plot);

%plot heatmaps and grand avg for active context
alignment.conditions = [1,2]; %empty to run all conditions [5:8];
alignment.number = [1:6]; %'reward','turn','stimulus'
alignment.type = 'all';        plot_info.position =  [100,100,225*1.155,figure_height];%[100,100,225,figure_height]; %[100,100,215,155];
heatmaps_avg_combined_selected_cells_refactored (imaging_st,plot_info,alignment,sorting_id_updated_datasets(2,:),save_path,bin_size, opto.sig_cells,0,1);
alignment.number = [1:3]; %'reward','turn','stimulus'
alignment.type = 'stimulus';        plot_info.position = [100,100,112*0.921,figure_height];%[100,100,112,figure_height];
heatmaps_avg_combined_selected_cells_refactored (imaging_st_passive,plot_info,alignment,sorting_id_updated_datasets(2,:),save_path,bin_size, opto.sig_cells,0,2);
% 
%% Sound heatmaps (S5)
% Define the parameter sets
save_path_passive = [];
mod_params.mod_threshold = 0.1;
mod_params.chosen_mice = [1:25];
param_sets = { 
    struct('mod_threshold', mod_params.mod_threshold, 'threshold_single_side', 1, 'savestring', [ 'sound_positive_modulated'],'chosen_mice', mod_params.chosen_mice,'data_type','sounds'),
    struct('mod_threshold', -1 * mod_params.mod_threshold, 'threshold_single_side', 1, 'savestring', [ 'sound_negative_modulated'],'chosen_mice', mod_params.chosen_mice,'data_type','sounds'),
    struct('mod_threshold', mod_params.mod_threshold, 'threshold_single_side', 0, 'savestring', [ 'sound_all_modulated'],'chosen_mice', mod_params.chosen_mice,'data_type','sounds')
    };

ylims_avg = [-.5,.5;-.5,.5;-.5,.5];
%heatmaps for positive, negative and all modulated sound neurons
for i = 1:length(param_sets)
    plot_info.gradavg_ylim =ylims_avg(i,:);
    %get sorting index
    [current_sig_cells] = get_thresholded_sig_cells_simple( param_sets{i}, sound.mod, sound.sig_mod_boot_thr);
    sig_cells = get_significant_neurons(current_sig_cells, sound.mod, 'union'); %union of active and passive
    cumsum(cellfun(@length, sig_cells))
    
    %do active
    alignment.conditions = [1,2]; %empty to run all conditions [5:8];
    alignment.number = [1:6]; %'reward','turn','stimulus'
    alignment.type = 'all';
    sorting_id_updated_datasets_sounds = get_sorting_indices_only(imaging_st, alignment, bin_size, sig_cells, 1)
    sound_sorting = [sorting_id_updated_datasets_sounds(2,:)];

        mod_params_plots = param_sets{i};
        [current_sig_cells] = get_thresholded_sig_cells_simple( mod_params_plots, sound.mod, sound.sig_mod_boot_thr);
        sig_cells = get_significant_neurons(current_sig_cells, sound.mod, 'union'); %union of active and passive
        cumsum(cellfun(@length, sig_cells))
        
        %do active
        alignment.conditions = [1,2]; %empty to run all conditions [5:8];
        alignment.number = [1:6]; %'reward','turn','stimulus'
        alignment.type = 'all';
        plot_info.position = [100,100,225*1.155,figure_height]; %215
        heatmaps_avg_combined_selected_cells_refactored (imaging_st,plot_info,alignment,sound_sorting(1,:),save_path,bin_size, sig_cells,0,1);

        %do passive
        alignment.number = [1:3]; %'reward','turn','stimulus'
        alignment.type = 'stimulus';
        plot_info.position = [100,100,112*0.921,figure_height]; %117 %had to adjust y for this because 
        heatmaps_avg_combined_selected_cells_refactored (imaging_st_passive,plot_info,alignment,sound_sorting(1,:),save_path_passive,bin_size, sig_cells,0,2);
end
