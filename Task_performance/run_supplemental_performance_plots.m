%Code to run performance across stim and no stim trials (S6)
% 1) load data
% from main data
load('plot_info.mat'); load('info.mat');
load('imaging_st.mat'); load('alignment.mat');
params = experiment_config(); 

behav_param.fields_to_balance = [3,4];%{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4
alignment.data_type = 'dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
save_path = [];

performance = get_opto_performance_simple(imaging_st,behav_param,alignment);

%NOW PLOT OPTO VS CONTROL
chosen_mice = [1:24];
[performance_stats.opto] = plot_performance(performance(:,chosen_mice),save_path,chosen_mice);
