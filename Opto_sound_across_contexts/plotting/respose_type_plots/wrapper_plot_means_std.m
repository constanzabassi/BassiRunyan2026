function [stats, corr_results] = wrapper_plot_means_std(sig_mod_boot,pooled_cell_types, post_sound, delta_stim,post_stim_sound, save_dir, plot_info, ylimits, label, datasets, celltypes_to_plot, response_types_to_plot)
%wrapper_plot_means_std  Compute correlations/means/std and plot by dataset

% this plots the mean and std comparing different response types!

%
%   [stats, corr_results] = plot_corr_means_wrapper(pooled_cell_types, dataX, dataY, save_dir, plot_info, ylimits, label, datasets)
%
%   Inputs:
%       pooled_cell_types : grouping of cells (from organize_cells)
%       dataX, dataY      : {datasets x contexts} or similar inputs
%       save_dir          : path to save results
%       plot_info         : struct with plotting config
%       ylimits           : [ymin, ymax] for plotting
%       label             : ylabel for the plot
%       datasets          : vector of dataset indices (e.g., 1:24)
%
%   Outputs:
%       stats             : output from plot_connected_abs_mod_by_mouse
%       corr_results      : struct with fields:
%                           .corr_datasets
%                           .corr_celltypes
%                           .means_datasets
%                           .std_datasets
%                           .data_datasets

    % Compute correlations and means across datasets
    [corr_datasets, corr_celltypes, means_datasets, std_datasets, data_datasets] = ...
        compute_means_correlations_per_dataset(sig_mod_boot, pooled_cell_types, post_sound, delta_stim,post_stim_sound);

    % Package results
    corr_results = struct();
    corr_results.corr_datasets = corr_datasets;
    corr_results.corr_all_pooled = corr_celltypes;
    corr_results.means_datasets = means_datasets;
    corr_results.std_datasets = std_datasets;
    corr_results.data_datasets = data_datasets;

    % Pass to plotting function
    plot_info.zero_star = 1; % keep your convention

    adjusted_means1 = squeeze(means_datasets(:,:,celltypes_to_plot,response_types_to_plot)); %using all cell types (1 = sound,2 sound+3, 3 delta stim)
    adjusted_means = permute(adjusted_means1, [1 3 2]); %switching response type with context so context is plotted within the same column
    adjusted_std1 = squeeze(std_datasets(:,:,celltypes_to_plot,response_types_to_plot)); %using all cell types (1 = sound,2 sound+3, 3 delta stim)
    adjusted_std = permute(adjusted_std1, [1 3 2]);
    %update plotting info
    plot_info.colors_celltypes = [0,0,0;0.5,0.5,0.5]; %active is black, passive is gray
    default_names = {'Sound','Stim + Sound','\Delta Stim'};
    plot_info.behavioral_contexts = default_names(response_types_to_plot);
    plot_info.zero_star = 0; %whether to compare to zero!

    stats.mean = plot_connected_abs_mod_by_mouse(save_dir, adjusted_means, datasets, ...
        plot_info, ylimits{1}, 0, label{1}); %0 is whether or not to take absolute value

    stats.std = plot_connected_abs_mod_by_mouse(save_dir, adjusted_std, datasets, ...
        plot_info, ylimits{2}, 0, label{2}); %0 is whether or not to take absolute value
end