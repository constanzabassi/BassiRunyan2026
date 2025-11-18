params = experiment_config(); 

%% load mod indices/ significant neurons
[sound,opto,sorted_cells,all_celltypes,context_data,ctrl_trials_context,stim_trials_context] = load_processed_opto_sound_data(params,{'separate','separate'});
both.sig_cells = intersect_sig_cells(opto.sig_cells',sound.sig_cells,opto.mod);
opto.sig_cells_opto_only = setdiff_sig_cells(opto.sig_cells',sound.sig_cells,opto.mod);
sound.sig_cells_opto_only = setdiff_sig_cells(sound.sig_cells(1:24),opto.sig_cells',opto.mod);

%%
split_params.divisions = 4; split_params.random_or_not = 0; split_params.splits = 4;
choose_params.chosen_celltypes = 4; choose_params.chosen_datasets = 1:24;
[~,~,proj_norm_stim,~] = ... %[proj,proj_ctrl,proj_norm,proj_norm_ctrl]
    find_axis_updated_specify_splits(context_data.dff, choose_params, all_celltypes,sound.sig_cells_opto_only,split_params); %,{50:59,63:73}

%%
celltype = 4;
proj_norm_new = proj_norm;
for split = 1:size(proj_norm,1)
    for current_dataset = 1:size(proj_norm,2)
        for celltype = 4
            for context = 1:2
                if ~isempty(proj_norm_stim{split,current_dataset,celltype,context})
                    proj_norm_new{split,current_dataset,celltype,context}.stim = ...
                    proj_norm_stim{split,current_dataset,celltype,context}.stim;
                else
                    proj_norm_new{split,current_dataset,celltype,context}.stim = nan(122);
                end
            end
        end
    end
end
[lm_sound_stim2,~,~,~,~,~, ~,~] = ...
    linear_regression_corr_model(proj_norm_new,'Sound' ,celltype,frame_range_post,frame_range_post,[1],'Stim');

[lm_sound_stim_pass2,~,~,~,~,~, ~,~] = ...
    linear_regression_corr_model(proj_norm_new,'Sound' ,celltype,frame_range_post,frame_range_post,[2],'Stim');
    save_dir3 = strcat(save_dir2, 'sound_sig_axis_only','/');
    plot_proj_meansplits_traces([1:24],proj_norm_new, 'stim',celltype, [61:62],[0,0,0;.5,.5,.5],{'Active','Passive'},save_dir3);

%     plot_linear_regression_lines(lm_sound_stim,tbl_sound_stim,context_all_sound_stim,'Sound Projection',save_dir3,'Stim',[],[-2,4],[-4,4],'topright');
%     plot_linear_regression_lines(lm_sound_stim_pass,tbl_sound_stim_pass,context_all_sound_stim_pass,'Sound Projection',save_dir3,'Stim',[],[-2,4],[-4,4]);
    bar_plot_coefficients({lm_sound_stim2}, {lm_sound_stim_pass2}, save_dir3, [0,0,0;0.5,0.5,0.5], "Slope",{'Active','Passive'},'act_pass',[-.2,.2]);
