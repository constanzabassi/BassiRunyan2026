function [dff_context,stim_trials_context,ctrl_trials_context] = separate_structure_2context(dff_st,mouse_context_tr,stim_info)
for m = 1:length(dff_st)
    stim_trials_all = [];
    ctrl_trials_all = [];
    for c = 1:size(mouse_context_tr{1,1},1)
        if c == 1
            stim_trials = 1:length(mouse_context_tr{1,m}{c,1});
            dff_context{c,m}.stim = dff_st{1,m}.stim(stim_trials,:,:);
            ctrl_trials = 1:length(mouse_context_tr{1,m}{c,2});
            dff_context{c,m}.ctrl = dff_st{1,m}.ctrl(ctrl_trials,:,:);
            stim_trials_all = [stim_trials_all,{stim_trials}];
            ctrl_trials_all = [ctrl_trials_all,{ctrl_trials}];
            if isfield(dff_st{1, m}, 'z_stim') && isfield(dff_st{1, m}, 'z_ctrl')
                dff_context{c,m}.z_stim = dff_st{1, m}.z_stim(stim_trials,:,:);
                dff_context{c,m}.z_ctrl = dff_st{1, m}.z_ctrl(ctrl_trials,:,:);
            end
        else
            stim_trials = sum(cellfun(@length,mouse_context_tr{1,m}(c-1:-1:1,1)))+1:sum(cellfun(@length,mouse_context_tr{1,m}(c:-1:1,1)));
            dff_context{c,m}.stim = dff_st{1,m}.stim(stim_trials,:,:);
            ctrl_trials = sum(cellfun(@length,mouse_context_tr{1,m}(c-1:-1:1,2)))+1:sum(cellfun(@length,mouse_context_tr{1,m}(c:-1:1,2)));
            dff_context{c,m}.ctrl = dff_st{1,m}.ctrl(ctrl_trials,:,:);
            stim_trials_all = [stim_trials_all,{stim_trials}];
            ctrl_trials_all = [ctrl_trials_all,{ctrl_trials}];
            if isfield(dff_st{1, m}, 'z_stim') && isfield(dff_st{1, m}, 'z_ctrl')
                dff_context{c,m}.z_stim = dff_st{1, m}.z_stim(stim_trials,:,:);
                dff_context{c,m}.z_ctrl = dff_st{1, m}.z_ctrl(ctrl_trials,:,:);
            end
        end
    end
    stim_trials_context{m} = stim_trials_all;
    ctrl_trials_context{m} = ctrl_trials_all;
end