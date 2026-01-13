plot_info.type = 'engagement'; %'sound'
savepath_fig3 = ['W:\Connie\results\Bassi2025\deconv_figs\fig3'];
%% prestim traces

[pooled_cell_types,plot_info.pooled_names,plot_info.pooled_colors] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'sound','opto','both','unmodulated'},[1:24],plot_info, 1);
plot_info.pooled_names = {{'Sound';'modulated'},{'Photostim';'modulated'},{'S & P';'modulated'},'Unmodulated'}
plot_info.trace_ylims = [4.5,6.5];
[~,~] = wrapper_avg_pooled_type_traces(context_data.dff,pooled_cell_types,[],[1:24],savepath_fig3,'sound_deconv_functional_types_-2to0_',plot_info,[1:10]);

[pooled_cell_types,plot_info.celltype_names,plot_info.colors_celltypes] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'sound','opto','both','unmodulated'},[1:24],plot_info, 1);
[preavg_index_by_dataset,~] = unpack_modindexm(avg_responses.avg_pre,[],pooled_cell_types,[1:24]);
params.plot_info = plot_info;
preavg_stats_celltypes_dataset = plot_connected_abs_mod_by_mouse(savepath_fig3, preavg_index_by_dataset, [1:24],...
          params.plot_info, [.075,.4],0,'Pre Mean (\DeltaF/F)');


%%
[pooled_cell_types,plot_info.pooled_names,plot_info.pooled_colors] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'sound','opto','both','unmodulated'},[1:24],plot_info, 1);
plot_info.pooled_names = {{'Sound';'modulated'},{'Photostim';'modulated'},{'S & P';'modulated'},'Unmodulated'}
plot_info.trace_ylims = [0,0.01];
[~,~] = wrapper_avg_pooled_type_traces(context_data.deconv,pooled_cell_types,[],[1:24],savepath_fig3,'sound_dff_functional_types_-2to0_',plot_info,[1:10]);

[pooled_cell_types,plot_info.celltype_names,plot_info.colors_celltypes] = organize_functional_groups(all_celltypes, sound.sig_cells, opto.sig_cells, opto.mod(1:24,:), {'sound','opto','both','unmodulated'},[1:24],plot_info, 1);
[preavg_index_by_dataset,~] = unpack_modindexm(avg_responses.avg_pre,[],pooled_cell_types,[1:24]);
params.plot_info = plot_info;
preavg_stats_celltypes_dataset = plot_connected_abs_mod_by_mouse(savepath_fig3, preavg_index_by_dataset, [1:24],...
          params.plot_info, [.075,.4],0,'Pre Mean (\DeltaF/F)');

% 2) AXIS PLOTS
split_params.divisions = 4; split_params.random_or_not = 0; split_params.splits = 4;
choose_params.chosen_celltypes = 1:4; choose_params.chosen_datasets = 1:24;
[axis_results_deconv,proj,proj_ctrl,proj_norm,proj_norm_ctrl, weights,trial_corr_context,percent_correct,act,act_norm_ctrl,act_norm,percent_correct_concat,proj_concat,proj_concat_norm,engagement_concat,test_trials,test_trials_relative] = ...
    find_axis_updated_specify_splits_deconv(context_data.deconv, choose_params, all_celltypes,[],split_params); %,{50:59,63:73}

celltype = 4; %4 = using all neurons (1=pyr,2=som,3=pv)
plot_proj_meansplits_traces([1:24],axis_results_deconv.proj_norm_ctrl, 'context',celltype, [60:61],[0,0,0;.5,.5,.5],{'Active','Passive'},savepath_fig3,'xlabel','Time from stimulus onset (s)');

colors_medium = [0.37 0.75 0.49 %green
                0.17 0.35 0.8  %blue
                0.82 0.04 0.04];
edges_values_weights = [-.1,.1];
num_bins_weights = 20;
[~,~] = histogram_weights_celltypes_vs_axis_splits([1:24],axis_results_deconv.weights, 'Context' ,all_celltypes, edges_values_weights,num_bins_weights,colors_medium,savepath_fig3);

frame_range_pre= 50:59;
frame_range_post = 63:93;
%sound (predicted) vs engagement axis
[lm_sound,tbl_sound,~,~,context_all_sound,~,~,~] = ...
    linear_regression_corr_model(axis_results_deconv.proj_norm_ctrl, 'Sound',celltype,frame_range_pre,frame_range_post,[1:2]);
%stim(predicted) vs engagement axis
[lm_stim,tbl_stim,~,~,context_all_stim,~,~,~] = ...
    linear_regression_corr_model(axis_results_deconv.proj_norm, 'Stim',celltype,frame_range_pre,frame_range_post,[1:2]);

plot_linear_regression_lines(lm_sound,tbl_sound,context_all_sound,'Sound Projection',savepath_fig3,'Engagement');
plot_linear_regression_lines(lm_stim,tbl_stim,context_all_stim,'Stim Projection',savepath_fig3,'Engagement');

nDatasets = 24;
for d = 1:nDatasets
    percent_correct_all{d} = horzcat(percent_correct_concat{:,d});   % concatenate across splits
    %find mean across neurons
    concat_activity{d} = vertcat(act{:,d,4}); %trials x neurons
    mean_act = mean(concat_activity{d}(:,50:59),2);
    activity_all{d} = mean_act';

    %do the same for the engagement axis
    concat_engagement{d} = vertcat(engagement_concat{:,d,4}); %trials x neurons
    mean_engagement = mean(concat_engagement{d}(:,50:59),2);
    engagement_all{d} = mean_engagement';
    test_trials_all{d} = horzcat(test_trials{:,d}); 
    test_trials_all_relative{d} = horzcat(test_trials_relative{:,d}); 
end
plot_performance_vs_engagement_axis_updated(percent_correct_all,engagement_all,[20,5],savepath_fig3,[0,2]);


plot_proj_meansplits_traces([1:24],axis_results_deconv.proj_norm_ctrl, 'sound',celltype, [60:61],[0,0,0;.5,.5,.5],{'Active','Passive'},savepath_fig3,'xlabel','Time from sound onset (s)');
plot_proj_meansplits_traces([1:24],axis_results_deconv.proj_norm, 'stim',celltype, [60:61],[0,0,0;.5,.5,.5],{'Active','Passive'},savepath_fig3,'xlabel','Time from stim onset (s)');

frames_to_avg = 50:59;
bin_edges = [-2:0.4:2];%
hist_stats =  histogram_axis_across_contexts_splits([1:24],axis_results_deconv.proj_norm_ctrl, 'context',celltype, bin_edges,frames_to_avg,[0,0,0;.5,.5,.5],{'Active','Passive'},savepath_fig3);

%axis stability across folds
plot_mean_axis_stability_across_splits(axis_results_deconv.weights,celltype,savepath_fig3);

%% comparison across cell types- to define engagement axis
celltype_of_predicted_var = 4;
frame_range_pre= 50:59;
frame_range_post = 63:93;
lm_sound_celltypes = {}; lm_stim_celltypes = {};
for celltype = 1:3 %celltype of variable used to make predictions
    if ~isempty(savepath_fig3)
        save_dir_celltype = strcat(savepath_fig3,upper(plot_info.celltype_names{celltype}),'_engagement')
    else
        save_dir_celltype = [];
    end
    
    [lm_sound,tbl_sound,~,~,context_all_sound,corr_mean, ~, ~] = ...
    linear_regression_corr_model(axis_results_deconv.proj_norm_ctrl, 'Sound',[celltype_of_predicted_var,celltype],frame_range_pre,frame_range_post,[1:2]);
    %stim(predicted) vs engagement axis
    [lm_stim,tbl_stim,~,~,context_all_stim,~, ~,~] = ...
        linear_regression_corr_model(axis_results_deconv.proj_norm, 'Stim',[celltype_of_predicted_var,celltype],frame_range_pre,frame_range_post,[1:2]);
    %save across celltypes
    lm_sound_celltypes{celltype} = lm_sound;
    lm_stim_celltypes{celltype} = lm_stim;
    %make plots across celltypes
    plot_linear_regression_lines(lm_sound,tbl_sound,context_all_sound,'Sound Projection',save_dir_celltype,'Engagement');
    plot_linear_regression_lines(lm_stim,tbl_stim,context_all_stim,'Stim Projection',save_dir_celltype,'Engagement');

end

bar_plot_coefficients({lm_sound_celltypes{2};lm_stim_celltypes{2}}, {lm_sound_celltypes{3};lm_stim_celltypes{3}}, savepath_fig3, plot_info.colors_celltypes(2:3,:), "Slope",{'Sound','Photostim'},'SOMPV');
