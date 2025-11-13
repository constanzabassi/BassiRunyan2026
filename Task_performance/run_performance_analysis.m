%% performance analysis
params = experiment_config(); 
load('V:\Connie\results\behavior_updated\data_info\imaging_st.mat');

behav_param.fields_to_balance = [3,4];%{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4
alignment.data_type = 'dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
chosen_mice = [1:25];
save_path = 'W:/Connie/results/Bassi2025/fig1';

performance = get_opto_performance_simple(imaging_st,behav_param,alignment);
% plot_performance_all(performance(1,chosen_mice),[save_path '/performance_analysis'],[params.info.mouseid{chosen_mice}]);
[performance_stats.all] = plot_performance_all(performance(1,chosen_mice),[save_path '/performance_analysis/'],chosen_mice);

%NOW PLOT OPTO VS CONTROL
chosen_mice = [1:24];
% [behav_param.p_val] = plot_performance(performance(:,chosen_mice),[save_path '/performance_analysis'],[params.info.mouseid{chosen_mice}]);
[performance_stats.opto] = plot_performance(performance(:,chosen_mice),[save_path '/performance_analysis/'],chosen_mice);

stats_table = struct2table_recursive(performance_stats, '', {'bootstat'});
save(fullfile([save_path '/performance_analysis/stats_table.mat']),'stats_table');
writetable(stats_table, fullfile(save_dir, strcat('table_performance.csv')));

%% iterates to balance condition and opto trials
% behav_param.num_iterations = 5;
% behav_param.fields_to_balance = [3,4];%{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4
% alignment.data_type = 'dff';% 'dff', 'z_dff', else it's deconvolved
% alignment.type = 'all'; %'reward','turn','stimulus','ITI'
% 
% performance = get_opto_performance(imaging_st,behav_param,alignment);
% % performance = get_opto_performance_selected_trials(imaging_st,behav_param,alignment,[1:5]); %takes first five after trials are balanced
% 
% % make plots
% %take control mouse out
% chosen_mice = setdiff(1:length(imaging_st),find(strcmp(info.mouse_date,'HE1-00\2023-05-30')));
% 
% [behav_param.p_val] = plot_performance(performance(:,chosen_mice),[info.savepath '/performance_analysis']);
% save('behav_param','behav_param');
% 
% % plot y,x velocity and view angle (abs of x and view angle)
% [behav_param.p_val_alt] = plot_performance_alt(performance(:,chosen_mice),[info.savepath '/performance_analysis']);
% 
% plot_performance_all_bar(performance,[info.savepath '/performance_analysis']);