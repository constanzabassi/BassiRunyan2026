function wrapper_plot_betas_distributions(info,bin_id, beta_mat, all_celltypes, mdl_param, onset_id,save_path, beta_mat_pass)
input_param{1,1}{1} = mdl_param;
plot_info = default_plot_info(input_param);
plot_info.labels = {'Pyr','SOM','PV','All','Top Pyr'}; %{'Active'};

    for offset = bin_id

        plot_dist_weights(offset, beta_mat, all_celltypes, plot_info, mdl_param, info, 1:3,save_path);
        if ~isempty( beta_mat_pass)
            plot_dist_weights(offset, beta_mat_pass, all_celltypes, plot_info, mdl_param, onset_id,save_path, '_passive');
        end
    end
end
