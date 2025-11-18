function [stats_all,indices_by_dataset] = wrapper_plot_response_means(responses,responses_info, pooled_cell_types, datasets, save_dir, plot_info, sig_mod_boot)
%PLOT_RESPONSE_MEANS_WRAPPER  Wrapper for unpack_modindexm + plotting
% plotting response means for sound, delta stim, stim+sound!
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
%       stats_all : cell array of outputs from plot_connected_abs_mod_by_mouse

    stats_all = cell(numel(responses),1);

    for i = 1:numel(responses)
        resp = responses{i};
        resp_info = responses_info{i};

        % unpack dataset means
        [index_by_dataset, ~] = unpack_modindexm(resp, sig_mod_boot, pooled_cell_types, datasets);

        % Save the unpacked indices
        indices_by_dataset.(resp_info(1).name) = index_by_dataset;

        % plot
        stats_all{i} = plot_connected_abs_mod_by_mouse(save_dir, index_by_dataset, datasets, ...
            plot_info, resp_info(1).range, 0, resp_info(1).label);
    end
end
