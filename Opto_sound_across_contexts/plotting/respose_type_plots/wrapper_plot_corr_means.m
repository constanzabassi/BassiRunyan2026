function [stats, corr_results] = wrapper_plot_corr_means(sig_mod_boot,pooled_cell_types, post_sound, delta_stim,post_stim_sound, save_dir, plot_info, ylimits, label, datasets, celltypes_to_plot)
%PLOT_CORR_MEANS_WRAPPER  Compute correlations/means and plot by dataset

% this plots the correlations between post sound and delta stim! but also
% calculates other values like mean, std for post sound, delta stim, post
% sound+stim

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
    stats = plot_connected_abs_mod_by_mouse(save_dir, corr_datasets(:,:,[celltypes_to_plot]), datasets, ...
        plot_info, ylimits, 0, label); %0 is whether or not to take absolute value
end
