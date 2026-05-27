savepath_fig1 = ['W:\Connie\results\Bassi2025\fig1_nature\reviews\'];
cd("W:\Connie\results\Bassi2025\data")
%% Figure 1 -DYNAMICS AND DECODING
load('plot_info.mat'); load('info.mat');load('all_celltypes.mat');
load('imaging_st.mat'); load('alignment.mat');
params = experiment_config(); 

% DYNAMICS PLOTS
alignment.data_type = 'dff';
plot_info.min_max = [0,.5];
heatmaps_avg_combined_all_celltypes_separate_plots_refactored( ...
        imaging_st,plot_info,alignment,[],savepath_fig1,1)
%% across mice?
alignment.data_type = 'dff';
plot_info.min_max = [0,.5];
heatmaps_avg_combined_all_celltypes_separate_plots_refactored( ...
        imaging_st,plot_info,alignment,[],savepath_fig1,1,[params.info.mouseid{:}]);
alignment.data_type = 'z_dff';
plot_info.min_max = [-.25,1];
heatmaps_avg_combined_all_celltypes_separate_plots_refactored( ...
        imaging_st,plot_info,alignment,[],savepath_fig1,1,[params.info.mouseid{:}]);
