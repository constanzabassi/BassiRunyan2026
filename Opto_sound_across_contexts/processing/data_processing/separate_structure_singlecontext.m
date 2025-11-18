function [dff_context,stim_trials_context,ctrl_trials_context] = separate_structure_singlecontext(dff_st)
for m = 1:length(dff_st)
    stim_trials_all = [];
    ctrl_trials_all = [];
    
    stim_trials = 1:size(dff_st{1,m}.stim,1);
    dff_context{m}.stim = dff_st{1,m}.stim(stim_trials,:,:);
    ctrl_trials = 1:size(dff_st{1,m}.ctrl,1);
    dff_context{m}.ctrl = dff_st{1,m}.ctrl(ctrl_trials,:,:);
    stim_trials_all = [stim_trials_all,{stim_trials}];
    ctrl_trials_all = [ctrl_trials_all,{ctrl_trials}];
    if isfield(dff_st{1, m}, 'z_stim') && isfield(dff_st{1, m}, 'z_ctrl')
        dff_context{m}.z_stim = dff_st{1, m}.z_stim(stim_trials,:,:);
        dff_context{m}.z_ctrl = dff_st{1, m}.z_ctrl(ctrl_trials,:,:);
    end
    
    stim_trials_context{m} = stim_trials_all;
    ctrl_trials_context{m} = ctrl_trials_all;
end