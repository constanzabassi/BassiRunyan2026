%% load context data

load('V:\Connie\results\opto_sound_2025\context\data_info\all_celltypes.mat');
load('V:\Connie\results\opto_sound_2025\context\data_info\context_data.mat');
plot_info = plotting_config(); %plotting params

keep context_data all_celltypes
%% define axis
[proj,proj_ctrl,proj_norm,proj_norm_ctrl, weights,trial_corr_context,percent_correct,act,act_norm_ctrl,act_norm,percent_correct_concat,proj_concat,proj_concat_norm] = find_axis(context_data.dff, [1:24], all_celltypes,[],[],[]); %,{50:59,63:73}

save_dir = 'W:\Connie\results\Bassi2025\fig4';%'V:\Connie\results\opto_sound_2025\context\axis_lme_plots_updated\dff';
save_dir2 = 'W:\Connie\results\Bassi2025\fig5';%'V:\Connie\results\opto_sound_2025\context\axis_lme_plots_updated\dff';

%% plot mean projection traces across datasets
celltype = 4; %4 = all

plot_proj_mean_traces([1:24],proj_ctrl, 'sound',celltype, [61:62],[0,0,0;.5,.5,.5],{'Active','Passive'},save_dir);
plot_proj_mean_traces([1:24],proj_ctrl, 'context',celltype, [61:62],[0,0,0;.5,.5,.5],{'Active','Passive'},save_dir);
plot_proj_mean_traces([1:24],proj, 'stim',celltype, [61:62],[0,0,0;.5,.5,.5],{'Active','Passive'},save_dir);

frames_to_avg = 50:59;
bin_edges = [-2:0.4:2];%
hist_stats =  histogram_axis_across_contexts([1:24],proj_ctrl, 'context',celltype, bin_edges,frames_to_avg,[0,0,0;.5,.5,.5],{'Active','Passive'},save_dir);

frames_to_avg = 63:93;
bin_edges = [-2:0.4:2];%
hist_stats =  histogram_axis_across_contexts([1:24],proj_ctrl, 'Sound',celltype, bin_edges,frames_to_avg,[0,0,0;.5,.5,.5],{'Active','Passive'},save_dir);

frames_to_avg = 63:93;
bin_edges = [-1.5:0.4:2.5];%
hist_stats =  histogram_axis_across_contexts([1:24],proj, 'Stim',celltype, bin_edges,frames_to_avg,[0,0,0;.5,.5,.5],{'Active','Passive'},save_dir);

%% model
celltype = 4;
frame_range_pre= 50:59;
frame_range_post = 63:93;
%sound (predicted) vs engagement axis
[lme_sound,tbl_sound,proj_all_sound,engagement_proj_all_sound,context_all_sound] = mixed_linear_model_nocontext(proj_ctrl, 'Sound',celltype,frame_range_pre,frame_range_post,[1:2]);
[lme_sound_pass,tbl_sound_pass,~,~,~] = mixed_linear_model_nocontext(proj_ctrl, 'Sound',celltype,frame_range_pre,frame_range_post,[1:2],'Context',1);

%stim(predicted) vs engagement axis
[lme_stim,tbl_stim,proj_all_stim,engagement_proj_all_stim,context_all_stim] = mixed_linear_model_nocontext(proj, 'Stim',celltype,frame_range_pre,frame_range_post,[1:2]);
[lme_stim_pass,tbl_stim_pass,~,~,~] = mixed_linear_model_nocontext(proj, 'Stim',celltype,frame_range_pre,frame_range_post,[1:2],'Context',1);

%sound(predicted) vs stim
[lme_sound_stim,tbl_sound_stim,proj_all_sound_stim,engagement_proj_all_sound_stim,context_all_sound_stim] = mixed_linear_model(proj,'Sound' ,celltype,frame_range_post,frame_range_post,'Stim');
[lme_sound_stim_pass,tbl_sound_stim_pass,~,~,~] = mixed_linear_model(proj,'Sound' ,celltype,frame_range_post,frame_range_post,'Stim',1);


%% make plots
% make plots
coeffs_stim = extract_and_rename_coefficients_updated(lme_stim, lme_stim_pass, [], ...
    {'Slope'});

coeffs_sound = extract_and_rename_coefficients(lme_sound, lme_sound_pass, [], ...
    {'Slope'});

coeffs_sound_stim = extract_and_rename_coefficients(lme_sound_stim, lme_sound_stim_pass, 'passive', ...
    {'Slope (A)', 'Slope (P)', 'Context Diff. (A - P)', 'Slope Diff. (A - P)'});


plot_fixed_effects(coeffs_sound,coeffs_stim,  save_dir, [0.3,0.2,0.6 ; 1,0.7,0],[]); %“Active Engagement Effect”“Passive Engagement Effect”“Context Offset (Passive - Active)”“Interaction (Slope Difference)”%{'Intercept','Engagement effect(A)','P vs A offset', 'Context:Engagement (P vs A)'}; %{"Effect of engagement (active)", "Passive vs. active shift", "Change in engagement effect (passive vs. active)"}
plot_fixed_effects(coeffs_sound_stim, coeffs_sound_stim, save_dir2, [0,0,0],[]);

% p_val_sound = plot_me_residuals(tbl_sound,'Sound',save_dir);
% p_val_stim = plot_me_residuals(tbl_stim,'Stim',save_dir);

p_val_sound_stim = plot_me_residuals(tbl_sound_stim,'Sound',save_dir2,'Context');


plot_me_regression_lines(lme_sound,tbl_sound,context_all_sound,'Sound Projection',save_dir);
plot_me_regression_lines(lme_stim,tbl_stim,context_all_stim,'Stim Projection',save_dir);

plot_me_regression_lines(lme_sound_stim,tbl_sound_stim,context_all_sound_stim,'Sound Projection',save_dir2,'Stim');

%predcited vs observed
plot_scatter_pred_vs_obs(lme_sound,'Sound',save_dir);
plot_scatter_pred_vs_obs(lme_stim,'Stim',save_dir);
plot_scatter_pred_vs_obs(lme_sound_stim,'Sound',save_dir2);

% plot_predictor_variance(lme_sound);
% plot_predictor_variance(lme_stim);
save(strcat('coeffs_sound_all_all'),'coeffs_sound');
save(strcat('coeffs_stim_all_all'),'coeffs_stim');
save(strcat('coeffs_sound_stim_all_all'),'coeffs_sound_stim');
%% simple model done separately per context
celltype = 4;
frame_range_pre= 50:59;
frame_range_post = 63:93;
%sound (predicted) vs engagement axis
[lme_sound_separate_ctx,tbl_sound_separate_ctx,~,~,context_all_sound_separate_ctx] = mixed_linear_model_nocontext(proj_ctrl, 'Sound',celltype,frame_range_pre,frame_range_post,[1]); %active trials only
[lme_sound_pass_separate_ctx,tbl_sound_pass_separate_ctx,~,~,~] = mixed_linear_model_nocontext(proj_ctrl, 'Sound',celltype,frame_range_pre,frame_range_post,[2],'Context',1); %passive trials only

%stim(predicted) vs engagement axis
[lme_stim_separate_ctx,tbl_stim_separate_ctx,~,~,context_all_stim_separate_ctx] = mixed_linear_model_nocontext(proj, 'Stim',celltype,frame_range_pre,frame_range_post,[1]); %active trials only
[lme_stim_pass_separate_ctx,tbl_stim_pass_separate_ctx,~,~,~] = mixed_linear_model_nocontext(proj, 'Stim',celltype,frame_range_pre,frame_range_post,[2],'Context',1); %passive trials only

% make plots
coeffs_stim_separate_ctx = extract_and_rename_coefficients_updated(lme_stim_separate_ctx, lme_stim_pass_separate_ctx, 'passive', ...
    {'Slope (A)', 'Slope (P)'});

coeffs_sound_separate_ctx = extract_and_rename_coefficients(lme_sound_separate_ctx, lme_sound_pass_separate_ctx, 'passive', ...
    {'Slope (A)', 'Slope (P)'});


plot_fixed_effects(coeffs_sound_separate_ctx,coeffs_stim_separate_ctx,  save_dir, [0.3,0.2,0.6 ; 1,0.7,0],[],'Sound_stim_separate_ctx'); %"Active Engagement Effect”“Passive Engagement Effect”“Context Offset (Passive - Active)”“Interaction (Slope Difference)”%{'Intercept','Engagement effect(A)','P vs A offset', 'Context:Engagement (P vs A)'}; %{"Effect of engagement (active)", "Passive vs. active shift", "Change in engagement effect (passive vs. active)"}


plot_me_regression_lines_separate_ctx(lme_sound_separate_ctx,tbl_sound_separate_ctx,1,'Sound Projection',save_dir);
plot_me_regression_lines_separate_ctx(lme_sound_pass_separate_ctx,tbl_sound_pass_separate_ctx,2,'Sound Projection',save_dir);

plot_me_regression_lines_separate_ctx(lme_stim_separate_ctx,tbl_stim_separate_ctx,1,'Stim Projection',save_dir);
plot_me_regression_lines_separate_ctx(lme_stim_pass_separate_ctx,tbl_stim_pass_separate_ctx,2,'Stim Projection',save_dir);

save(strcat('coeffs_sound_separate_ctx'),'coeffs_sound_separate_ctx');
save(strcat('coeffs_stim_separate_ctx'),'coeffs_stim_separate_ctx');
%% performance
% lme_perf = plot_errorbar_performance_lme(percent_correct_concat,engagement_proj_all_sound,engagement_proj_all_stim,context_all_sound,context_all_stim,save_dir);
% save(strcat('lme_perf'),'lme_perf');

plot_performance_vs_engagement_axis(percent_correct_concat,engagement_proj_all_sound,engagement_proj_all_stim,context_all_sound,context_all_stim,[15,5],save_dir,[-1,1]);
%% weights
colors_medium = [0.37 0.75 0.49 %green
                0.17 0.35 0.8  %blue
                0.82 0.04 0.04];
edges_values_weights = [-.1,.1];
num_bins_weights = 20;
[weight_all_celltype,weight_ct_stats] = histogram_weights_celltypes_vs_axis([1:24],weights, 'Context' ,all_celltypes, edges_values_weights,num_bins_weights,colors_medium,save_dir);

%% extra plots
plot_me_violin_random_intercept(proj_all_sound,context_all_sound,lme_sound, 'Sound');
plot_me_violin_random_intercept(proj_all_stim,context_all_stim,lme_stim, 'Stim');


plot_error_bars_response_vs_axis_allbinned(proj,proj_all_stim,engagement_proj_all_stim,context_all_stim,'Stim',[0,0,0;0.5,0.5,0.5],[]);
plot_error_bars_response_vs_axis_allbinned(proj_ctrl,proj_all_sound,engagement_proj_all_sound,context_all_sound,'Sound',[0,0,0;0.5,0.5,0.5],[]);
%% cell type effects (what is being predicted) vs same projections as before (using all cell types)
frame_range_pre= 50:59;
frame_range_post = 63:93;
celltype2 = 4;
for celltype = 1:4
    %update directory
    save_dir_celltype = strcat(save_dir,'/sound_all_axis/',upper(plot_info.celltype_names{celltype}));

    %sounds(predicted) vs context
    [lme_sound,tbl_sound,proj_all_sound,engagement_proj_all_sound,context_all_sound] = mixed_linear_model_nocontext(proj_ctrl, 'Sound',[celltype2,celltype],frame_range_pre,frame_range_post);
    [lme_sound_pass,tbl_sound_pass,~,~,~] = mixed_linear_model_nocontext(proj_ctrl, 'Sound',[celltype2,celltype],frame_range_pre,frame_range_post,'Context',1);
    
    %stim(predicted) vs context
    [lme_stim,tbl_stim,proj_all_stim,engagement_proj_all_stim,context_all_stim] = mixed_linear_model_nocontext(proj, 'Stim',[celltype2,celltype],frame_range_pre,frame_range_post);
    [lme_stim_pass,tbl_stim_pass,~,~,~] = mixed_linear_model_nocontext(proj, 'Stim',[celltype2,celltype],frame_range_pre,frame_range_post,'Context',1);
        
    %sound(predicted) vs stim
    [lme_sound_stim,tbl_sound_stim,proj_all_sound_stim,engagement_proj_all_sound_stim,context_all_sound_stim] = mixed_linear_model(proj,'Sound' ,[celltype2,celltype],frame_range_post,frame_range_post,'Stim');
    [lme_sound_stim_pass,tbl_sound_stim_pass,~,~,~] = mixed_linear_model(proj,'Sound' ,[celltype2,celltype],frame_range_post,frame_range_post,'Stim',1);

    coeffs_stim = extract_and_rename_coefficients_updated(lme_stim, lme_stim_pass, [], ...
        {'Slope '});
    
    coeffs_sound = extract_and_rename_coefficients(lme_sound, lme_sound_pass, [], ...
        {'Slope '});   

    coeffs_sound_stim = extract_and_rename_coefficients(lme_sound_stim, lme_sound_stim_pass, 'passive', ...
        {'Slope (A)', 'Slope (P)', 'Context Diff. (A - P)', 'Slope Diff. (A - P)'});

    %main plots
    plot_fixed_effects(coeffs_sound,coeffs_stim,  save_dir_celltype, [0.3,0.2,0.6 ; 1,0.7,0],[]); %“Active Engagement Effect”“Passive Engagement Effect”“Context Offset (Passive - Active)”“Interaction (Slope Difference)”%{'Intercept','Engagement effect(A)','P vs A offset', 'Context:Engagement (P vs A)'}; %{"Effect of engagement (active)", "Passive vs. active shift", "Change in engagement effect (passive vs. active)"}
    plot_fixed_effects(coeffs_sound_stim, coeffs_sound_stim, save_dir_celltype, [0,0,0],[]);
    
    plot_me_regression_lines(lme_sound,tbl_sound,context_all_sound,'Sound Projection',save_dir_celltype);
    plot_me_regression_lines(lme_stim,tbl_stim,context_all_stim,'Stim Projection',strcat(save_dir,'/stim_all_axis/',upper(plot_info.celltype_names{celltype})));
    
    plot_me_regression_lines(lme_sound_stim,tbl_sound_stim,context_all_sound_stim,'Sound Projection',save_dir_celltype,'Stim');
end


%%
celltype2 = 1;
    %sound(predicted) vs stim
    celltype = 2;
    [lme_sound_stim,tbl_sound_stim,proj_all_sound_stim,engagement_proj_all_sound_stim,context_all_sound_stim] = mixed_linear_model(proj,'Sound' ,[celltype2,celltype],frame_range_post,frame_range_post,'Stim');
    [lme_sound_stim_pass,tbl_sound_stim_pass,~,~,~] = mixed_linear_model(proj,'Sound' ,[celltype2,celltype],frame_range_post,frame_range_post,'Stim',1);
    celltype = 3
    [lme_sound_stim2,tbl_sound_stim2,proj_all_sound_stim2,engagement_proj_all_sound_stim2,context_all_sound_stim2] = mixed_linear_model(proj,'Sound' ,[celltype2,celltype],frame_range_post,frame_range_post,'Stim');
    [lme_sound_stim_pass2,tbl_sound_stim_pass2,~,~,~] = mixed_linear_model(proj,'Sound' ,[celltype2,celltype],frame_range_post,frame_range_post,'Stim',1);


    coeffs_sound_stim = extract_and_rename_coefficients(lme_sound_stim, lme_sound_stim_pass, 'passive', ...
        {'Slope (A)', 'Slope (P)', 'Context Diff. (A - P)', 'Slope Diff. (A - P)'});

    coeffs_sound_stim2 = extract_and_rename_coefficients(lme_sound_stim2, lme_sound_stim_pass2, 'passive', ...
    {'Slope (A)', 'Slope (P)', 'Context Diff. (A - P)', 'Slope Diff. (A - P)'});

    %main plots
    plot_fixed_effects(coeffs_sound_stim, coeffs_sound_stim2, save_dir, plot_info.colors_celltypes(2:3,:),[],'SOMPV_stimaxis_soundPYR');
%%
celltype2 = 3;
frame_range_post2 = frame_range_post;
frame_range_post3 = 63:73;
    %sound(predicted) vs stim
    celltype = 2;
    [lme_sound_stim,tbl_sound_stim,proj_all_sound_stim,engagement_proj_all_sound_stim,context_all_sound_stim] = mixed_linear_model(proj,'Sound' ,[celltype2,celltype],frame_range_post2,frame_range_post3,'Stim_post');
    [lme_sound_stim_pass,tbl_sound_stim_pass,~,~,~] = mixed_linear_model(proj,'Sound' ,[celltype2,celltype],frame_range_post2,frame_range_post3,'Stim_post',1);
    celltype = 3
    [lme_sound_stim2,tbl_sound_stim2,proj_all_sound_stim2,engagement_proj_all_sound_stim2,context_all_sound_stim2] = mixed_linear_model(proj,'Sound' ,[celltype2,celltype],frame_range_post2,frame_range_post3,'Stim_post');
    [lme_sound_stim_pass2,tbl_sound_stim_pass2,~,~,~] = mixed_linear_model(proj,'Sound' ,[celltype2,celltype],frame_range_post2,frame_range_post3,'Stim_post',1);


    coeffs_sound_stim = extract_and_rename_coefficients(lme_sound_stim, lme_sound_stim_pass, 'passive', ...
        {'Slope (A)', 'Slope (P)', 'Context Diff. (A - P)', 'Slope Diff. (A - P)'});

    coeffs_sound_stim2 = extract_and_rename_coefficients(lme_sound_stim2, lme_sound_stim_pass2, 'passive', ...
    {'Slope (A)', 'Slope (P)', 'Context Diff. (A - P)', 'Slope Diff. (A - P)'});

    %main plots
%     plot_fixed_effects(coeffs_sound_stim, coeffs_sound_stim2, save_dir, plot_info.colors_celltypes(2:3,:),[],'SOMPV_orthpstimpostmaxis_soundPYR');
    plot_fixed_effects(coeffs_sound_stim, coeffs_sound_stim2, [], plot_info.colors_celltypes(2:3,:),[],'SOMPV_orthpstimpostmaxis_soundPYR');

%%
%run model that is stim_proj = ~ Sound Proj * Context + Celltype Proj * Context + (1|AnimalID)' 
for celltypes = 1:3
    %update directory
    save_dir_celltype = strcat(save_dir,upper(plot_info.celltype_names{celltypes}));
    celltype = [1,1,celltypes];
    [lme_sound_stim_ih,tbl_sound_stim_ih,proj_all_sound_stim_ih,engagement_proj_all_sound_stim_ih,context_all_sound_stim_ih] = mixed_linear_model_with_inhib(proj,'Sound' ,celltype,frame_range_post,frame_range_post,proj,'Stim');
    [lme_sound_stim_pass_ih,tbl_sound_stim_pass_ih,~,~,~] = mixed_linear_model_with_inhib(proj,'Sound' ,celltype,frame_range_post,frame_range_post,proj,'Stim',1);
    
    
    coeffs_sound_stim_ih = extract_and_rename_coefficients_updated(lme_sound_stim_ih, lme_sound_stim_pass_ih, 'passive', ...
        {
            'Stim Slope (Active)', ...
            'Stim Slope (Passive)', ...
            strcat(plot_info.celltype_names{celltypes},' Slope (Active)'), ...
            strcat(plot_info.celltype_names{celltypes},' Slope (Passive)'), ...
            'Context', ...
            'Stim x Context', ...
            strcat(plot_info.celltype_names{celltypes},' x Context')});
    
    
    plot_fixed_effects(coeffs_sound_stim_ih, coeffs_sound_stim_ih,save_dir_celltype, [0,0,0],[],strcat(plot_info.celltype_names{celltypes},'_stim_sound_orthogonal',num2str(celltype(1))));
end


%run model that is Sound Proj = ~ stim_proj * Context + Celltype Proj * Context + (1|AnimalID)' 
for celltypes = 2:3
    %update directory
    save_dir_celltype = strcat(save_dir,upper(plot_info.celltype_names{celltypes}));
    celltype = [1,1,celltypes];
    [lme_sound_stim_ih,tbl_sound_stim_ih,proj_all_sound_stim_ih,engagement_proj_all_sound_stim_ih,context_all_sound_stim_ih] = mixed_linear_model_with_inhib(proj,'Sound' ,celltype,frame_range_post,frame_range_post,proj,'Stim',0,'Stim_post');
    [lme_sound_stim_pass_ih,tbl_sound_stim_pass_ih,~,~,~] = mixed_linear_model_with_inhib(proj,'Sound' ,celltype,frame_range_post,frame_range_post,proj,'Stim',1,'Stim_post');
    
    
    coeffs_sound_stim_ih = extract_and_rename_coefficients_updated(lme_sound_stim_ih, lme_sound_stim_pass_ih, 'passive', ...
        {
            'Stim Slope (A)', ...
            'Stim Slope (P)', ...
            strcat(plot_info.celltype_names{celltypes},' Slope (A)'), ...
            strcat(plot_info.celltype_names{celltypes},' Slope (P)'), ...
            'Context', ...
            'Stim x Context', ...
            strcat(plot_info.celltype_names{celltypes},' x Context')});
    
    
    plot_fixed_effects(coeffs_sound_stim_ih, coeffs_sound_stim_ih,save_dir_celltype, [0,0,0],[],strcat(plot_info.celltype_names{celltypes},'_stim_sound_poststimmean',num2str(celltype(1)),num2str(celltype(2))));
end
%% look at inhibitory neurons (decide which one to use)
%sound(predicted-PYR) vs inhibitory neurons (using same axis just pre vs post)
[lme_sound_pv,tbl_sound_stim,proj_all_sound_pv,engagement_proj_all_sound_pv,context_all_sound_pv] = mixed_linear_model(proj,'Sound' ,[1,3],frame_range_pre,frame_range_post,'Sound');
[lme_sound_pv_pass,tbl_sound_stim_pass,~,~,~] = mixed_linear_model(proj,'Sound' ,[1,3],frame_range_pre,frame_range_post,'Sound',1);
[lme_sound_som,tbl_sound_stim,proj_all_sound_som,engagement_proj_all_sound_som,context_all_sound_som] = mixed_linear_model(proj,'Sound' ,[1,2],frame_range_pre,frame_range_post,'Sound');
[lme_sound_som_pass,tbl_sound_stim_pass,~,~,~] = mixed_linear_model(proj,'Sound' ,[1,2],frame_range_pre,frame_range_post,'Sound',1);
%stim(predicted-PYR) vs inhibitory neurons (using same axis just pre vs post)
[lme_sound_pv,tbl_sound_stim,proj_all_sound_pv,engagement_proj_all_sound_pv,context_all_sound_pv] = mixed_linear_model(proj,'Stim' ,[1,3],frame_range_pre,frame_range_post,'Stim');
[lme_sound_pv_pass,tbl_sound_stim_pass,~,~,~] = mixed_linear_model(proj,'Stim' ,[1,3],frame_range_pre,frame_range_post,'Stim',1);
[lme_sound_som,tbl_sound_stim,proj_all_sound_som,engagement_proj_all_sound_som,context_all_sound_som] = mixed_linear_model(proj,'Stim' ,[1,2],frame_range_pre,frame_range_post,'Stim');
[lme_sound_som_pass,tbl_sound_stim_pass,~,~,~] = mixed_linear_model(proj,'Stim' ,[1,2],frame_range_pre,frame_range_post,'Stim',1);

%orthogonalized IH projections 
[lme_sound_pv,tbl_sound_stim,proj_all_sound_pv,engagement_proj_all_sound_pv,context_all_sound_pv] = mixed_linear_model(proj,'Stim' ,[1,3],frame_range_post,frame_range_post,'Stim_post');
[lme_sound_pv_pass,tbl_sound_stim_pass,~,~,~] = mixed_linear_model(proj,'Stim' ,[1,3],frame_range_post,frame_range_post,'Stim_post',1);
[lme_sound_som,tbl_sound_stim,proj_all_sound_som,engagement_proj_all_sound_som,context_all_sound_som] = mixed_linear_model(proj,'Stim' ,[1,2],frame_range_post,frame_range_post,'Stim_post');
[lme_sound_som_pass,tbl_sound_stim_pass,~,~,~] = mixed_linear_model(proj,'Stim' ,[1,2],frame_range_post,frame_range_post,'Stim_post',1);

[lme_sound_pv,tbl_sound_stim,proj_all_sound_pv,engagement_proj_all_sound_pv,context_all_sound_pv] = mixed_linear_model(proj,'Stim' ,[1,3],frame_range_pre,frame_range_post,'Stim_pre');
[lme_sound_pv_pass,tbl_sound_stim_pass,~,~,~] = mixed_linear_model(proj,'Stim' ,[1,3],frame_range_pre,frame_range_post,'Stim_pre',1);
[lme_sound_som,tbl_sound_stim,proj_all_sound_som,engagement_proj_all_sound_som,context_all_sound_som] = mixed_linear_model(proj,'Stim' ,[1,2],frame_range_pre,frame_range_post,'Stim_pre');
[lme_sound_som_pass,tbl_sound_stim_pass,~,~,~] = mixed_linear_model(proj,'Stim' ,[1,2],frame_range_pre,frame_range_post,'Stim_pre',1);


% organize outputs
coeffs_sound_ih = extract_and_rename_coefficients(lme_sound_pv, lme_sound_pv_pass, 'passive', ...
    {'IH Slope (A)', 'IH Slope (P)', 'Context Diff. (A - P)', 'Slope Diff. (A - P)'});
coeffs_sound_som = extract_and_rename_coefficients(lme_sound_som, lme_sound_som_pass, 'passive', ...
    {'IH Slope (A)', 'IH Slope (P)', 'Context Diff. (A - P)', 'Slope Diff. (A - P)'});


%inhibitory effects
plot_fixed_effects(coeffs_sound_som, coeffs_sound_ih, save_dir, plot_info.colors_celltypes(2:3,:),[],'sound_vs_preIH');
plot_me_regression_lines(lme_sound_pv,engagement_proj_all_sound_pv,proj_all_sound_pv,context_all_sound_pv,'Sound Projection',save_dir,'PV');
plot_me_regression_lines(lme_sound_som,engagement_proj_all_sound_som,proj_all_sound_som,context_all_sound_som,'Sound Projection',save_dir,'SOM');

plot_fixed_effects(coeffs_sound_som, coeffs_sound_ih, save_dir, plot_info.colors_celltypes(2:3,:),[],'stim_vs_preIH');
plot_me_regression_lines(lme_sound_pv,engagement_proj_all_sound_pv,proj_all_sound_pv,context_all_sound_pv,'Stim Projection',save_dir,'PV');
plot_me_regression_lines(lme_sound_som,engagement_proj_all_sound_som,proj_all_sound_som,context_all_sound_som,'Stim Projection',save_dir,'SOM');

plot_fixed_effects(coeffs_sound_som, coeffs_sound_ih, save_dir, plot_info.colors_celltypes(2:3,:),[],'stim_vs_postIH');
plot_me_regression_lines(lme_sound_pv,engagement_proj_all_sound_pv,proj_all_sound_pv,context_all_sound_pv,'Stim Projection',save_dir,'PV (post)');

%% no context
%sounds(predicted) vs context
