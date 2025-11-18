function [stats_all,indices_all] = wrapper_plot_response_means_allcells(responses,responses_info, pooled_cell_types, datasets, save_dir, plot_info, sig_mod_boot)
%PLOT_RESPONSE_MEANS_WRAPPER  Wrapper for unpack_modindexm + plotting
% plotting response means for sound, delta stim, stim+sound! DOES NOT
% SEPARATE ACROSS DATASETS (POOLED THEM TOGETHER, SEM ARE OF TH POOLED
% DATA)
%
%   stats_all = plot_response_means_wrapper(responses, pooled_cell_types, datasets, save_dir, plot_info)
%
%   Inputs:
%       responses : cell array of structs with fields:
%           .data   -> input to unpack_modindexm (e.g. avg_pre, diff_stim, avg_post)
%           .ylims  -> [ymin ymax] limits for plotting
%           .label  -> ylabel string for plot
%           .save   -> (optional) directory for saving; if empty, use save_dir
%       pooled_cell_types : grouping of cells (from organize_functional_groups)
%       datasets : vector of dataset indices (e.g., 1:24)
%       save_dir : default save directory
%       plot_info : struct with plotting config
%
%   Outputs:
%       stats_all : cell array of outputs from scatter_abs_mean_mod

    stats_all = cell(numel(responses),1);

    for i = 1:numel(responses)
        resp = responses{i};
        resp_info = responses_info{i};

        % unpack dataset means
        [index_all, ~, ~, ~, celltypes_ids] = ... %cellids has the indices relative to all
        organize_sig_mod_index_contexts_celltypes(datasets, resp, sig_mod_boot, pooled_cell_types,plot_info.celltype_names); 

        % Save the unpacked indices
        indices_all.(resp_info(1).name) = index_all;

        % plot
        stats_all{i} = scatter_abs_mean_mod(save_dir,index_all,plot_info,...
            celltypes_ids,datasets,2,resp_info(1, 1).range, resp_info(1, 1).label,0) %0 means no absolute value taken
    end
end