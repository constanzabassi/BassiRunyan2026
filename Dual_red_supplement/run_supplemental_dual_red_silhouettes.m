% Code to plot SOM and PV silhouettes (S1)
params = experiment_config(); 
info = params.info;
save_path = [];

% 1) load data
%from main
load('plot_info.mat')
% from supplemental data dual red
load('silhouette_struct.mat'); 
% 2) make plots
plot_red_silhouettes(silhouette_struct,plot_info,save_path);
