function [dff_context,stim_trials_context,ctrl_trials_context] = separate_structure_w_matrix(dff_st,mouse_context_tr)
for m = 1:length(dff_st)
    stim_trials_all = [];
    ctrl_trials_all = [];
    for c = 1:size(mouse_context_tr{1,1},1)
        if size(mouse_context_tr{1,1},2) == 4
            stim_trials = mouse_context_tr{1,m}{c,3};
            ctrl_trials = mouse_context_tr{1,m}{c,4};
        else
            stim_trials = mouse_context_tr{1,m}{c,1};
            ctrl_trials = mouse_context_tr{1,m}{c,2};
        end
            dff_context{c,m}.stim = dff_st{1,m}.stim(stim_trials,:,:);
            dff_context{c,m}.ctrl = dff_st{1,m}.ctrl(ctrl_trials,:,:);
            stim_trials_all = [stim_trials_all,{stim_trials}];
            ctrl_trials_all = [ctrl_trials_all,{ctrl_trials}];
    end
    stim_trials_context{m} = stim_trials_all;
    ctrl_trials_context{m} = ctrl_trials_all;
end