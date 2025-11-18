plot_info = plotting_config(); %plotting params
load('V:\Connie\results\behavior_updated\data_info\info.mat');
load('V:\Connie\results\behavior_updated\data_info\imaging_st.mat');
load('V:\Connie\results\behavior_updated\data_info\all_celltypes.mat');
save_path = 'W:/Connie/results/Bassi2025/fig1';
info.savepath = save_path;
alignment.conditions = []; %empty to run all conditions [5:8];
alignment.data_type = 'z_dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
alignment.field_to_separate = {'correct'};
plot_info.min_max = [-0.25 1];%[0 .02];% %
alignment.number = [1:6]; %'reward','turn','stimulus'
alignment.cells = [cellfun(@(x) x.pyr_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.som_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.pv_cells,all_celltypes,'UniformOutput',false)];
alignment.title = {'PYR','SOM','PV'};
plot_info.xlabel = [];
plot_info.sorting_type = 1;
plot_info.ylabel = 'Frames';
plot_info.xlabel_events = {'S1','S2','S3','turn','reward','ITI'};
plot_info.colors_celltype = plot_info.colors_celltypes;
bin_size = 1;


figure(90);clf;
% colormap(colormaps.slanCM('viridis',100));
colormap(viridis)
%plot heatmaps and grand avg
mouse_data_conditions = heatmaps_avg_combined_all_celltypes (imaging_st,plot_info,alignment,[],[save_path '\heatmaps'],bin_size);%last number is bin size

figure(90);clf;
% colormap(colormaps.slanCM('viridis',100));
colormap(viridis)
%plot heatmaps and grand avg
alignment.data_type = 'dff';
mouse_data_conditions = heatmaps_avg_combined_all_celltypes (imaging_st,plot_info,alignment,[],[save_path '\heatmaps_dff'],bin_size);%last number is bin size


% separating heatmaps from avg
alignment.data_type = 'z_dff';
plot_info.xlabel_events = {'S1','S2','S3','turn','reward','ITI'};
mouse_data_conditions = heatmaps_avg_combined_all_celltypes_separate_plots (imaging_st,plot_info,alignment,[],[save_path '\heatmaps'],bin_size);%last number is bin size

% % below is code to plot extra fields like velicity at the bottom
% figure(90);clf;
% colormap viridis
% mouse_data_conditions = heatmaps_avg_combined_all_celltypes_extra_fields
% (imaging_st,plot_info,alignment,[],[save_path '\heatmaps'],bin_size,'y_velocity',[]); 

% alignment.number = 6; %just ITI
% alignment.type = 'ITI';
% mouse_data_conditions = scatter_avg_combined_all_celltypes_extra_fields (imaging_st,plot_info,alignment,[],[],bin_size,'y_velocity',[]);
%% DYNAMICS PLOT OF FRACTION OF CELLS
plot_info.colors_celltype = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04 % red  
                            0 0 0.5]; %dark purple
dynamics_info.bin_size = 1;%3;
dynamics_info.conditions = []; %1:8 for stim or empty to do all conditions!
alignment.data_type = 'dff';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'

[dynamics_info.max_cel_avg,dynamics_info.new_onsets,dynamics_info.binss,dynamics_info.original_onsets] = peak_times_avg (imaging_st,alignment,dynamics_info,1);
%[dynamics_info.max_cel_mode,dynamics_info.freq,~, dynamics_info.binss,dynamics_info.new_onsets] = fraction_dynamics (imaging_st,alignment,dynamics_info); 
info.savepath = save_path;
plot_frc_dynamics(dynamics_info.max_cel_avg,dynamics_info,all_celltypes,plot_info, info,0); %last is save or not


%% make cdf plot using the peaks found -- ACTIVE
dynamics_info.bin_size = 1;
[dynamics_info.max_cel_avg,dynamics_info.new_onsets,dynamics_info.binns,dynamics_info.original_onsets] = peak_times_avg (imaging_st,alignment,dynamics_info,1);
%%% old code [dynamics_info.p_cdf,dynamics_info.KW_peaks, dynamics_stats] =  cdf_peak_times(dynamics_info.max_cel_avg,dynamics_info,all_celltypes,plot_info,info);
[dynamics_stats] =  cdf_peak_times_updated(dynamics_info.max_cel_avg,dynamics_info,all_celltypes,plot_info,info,1); %last number is number of nans wanted

%% plot average activity per epoch
[cel_avg,~,~,~] = avg_activity (imaging_st,alignment,dynamics_info,1,all_celltypes, plot_info);

alignment.data_type = 'z_dff';
[cel_avg_z,~,~,~] = avg_activity (imaging_st,alignment,dynamics_info,1,all_celltypes, plot_info);

S = unwrap_cells_in_struct(dynamics_stats);
table_fig1 = struct2table_recursive(S,'',{'bootstat','hist'});
save(fullfile(save_path, strcat('table_fig1.mat')), 'table_fig1');
writetable(table_fig1, fullfile(save_path, strcat('table_fig1.csv')));
