% get red cell info
params = experiment_config(); 

info = params.info;
plot_info.colors_celltype = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04 % red  
                            0 0 0.5]; %dark purple

save_dir = 'W:\Connie\results\Bassi2025\fig1\supplement';
[all_sil,missing_data] = get_red_silhouettes(info,plot_info,[save_dir '/red_cell_analysis']);

%% also get general stats per dataset (avg # of cells per dataset?)