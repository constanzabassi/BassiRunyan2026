function [stats, cos_results] = wrapper_plot_cosine_sim_corr(sig_mod_boot,pooled_cell_types, avg_ctrl_post, diff_stim, save_dir, plot_info, ylimits, datasets, functional_types_to_plot)
%wrapper_plot_means_std  Compute correlations/means/std and plot by dataset

% this plots the mean and std comparing different response types!

    % Compute correlations and means across datasets
    [cos_similarity,rho] = calculate_cosine_sim_rank_corr(diff_stim,sig_mod_boot,pooled_cell_types); %delta stim
    [cos_similarity_sound,rho_sound] = calculate_cosine_sim_rank_corr(avg_ctrl_post,sig_mod_boot,pooled_cell_types); %sound response

    % Package results
    cos_results = struct();
    cos_results.delta_stim = cos_similarity;
    cos_results.sound = cos_similarity_sound;
    cos_results.rho_delta_stim = rho;
    cos_results.rho_sound = rho_sound;

    % Pass to plotting function
    plot_info.zero_star = 0; % keep your convention

    %update plotting info
    plot_info.colors_celltypes = [0,0,0;0.5,0.5,0.5]; %active is black, passive is gray
    default_names = plot_info.pooled_names; 
    plot_info.behavioral_contexts = default_names(functional_types_to_plot);
    plot_info.zero_star = 0; %whether to compare to zero!
    plot_info.colors_celltypes = plot_info.pooled_colors;

    % Delta Stim
    stats.delta_stim.rho = plot_connected_abs_mod_by_mouse(save_dir, rho, datasets,...
                    plot_info, ylimits{1},0,'Corr Δ Stim (contexts)'); %0 is whether or not to take absolute value
    stats.delta_stim.cos = plot_connected_abs_mod_by_mouse(save_dir, cos_similarity, datasets,...
                    plot_info, ylimits{2},0,{'Cosine Sim. Δ Stim';'across contexts'});
    
    % Sound
    stats.post_sound.rho = plot_connected_abs_mod_by_mouse(save_dir, rho_sound, datasets,...
                    plot_info, ylimits{1},0,'Corr Sound (contexts)');
    stats.post_sound.cos = plot_connected_abs_mod_by_mouse(save_dir, cos_similarity_sound, datasets,...
                    plot_info, ylimits{2},0,'Cosine Sim. Sound (contexts)');
end