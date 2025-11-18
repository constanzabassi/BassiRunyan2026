function [speed_trials_stim,speed_trials_ctrl] = find_speed_trials(mouse_vel_context,min_max_vals,stim_trials_context,ctrl_trials_context)
%find trials within specific velocity range and orgaize by dataset id and
%context
for mouse = 1:length(mouse_vel_context)
    for context = 1:size(mouse_vel_context,2)
        speed_trials_stim{1,mouse}{1,context} = stim_trials_context{1,mouse}{1,context}(find(mean(mouse_vel_context{mouse,context}.stim,2)>=min_max_vals(1) & mean(mouse_vel_context{mouse,context}.stim,2)<=min_max_vals(2)));
        speed_trials_ctrl{1,mouse}{1,context} = ctrl_trials_context{1,mouse}{1,context}(find(mean(mouse_vel_context{mouse,context}.ctrl,2)>=min_max_vals(1) & mean(mouse_vel_context{mouse,context}.ctrl,2)<=min_max_vals(2)));
        %stim_trials_context{1,m}{1,context}
        speed_trials_stim{2,mouse}{2,context} = (find(mean(mouse_vel_context{mouse,context}.stim,2)>=min_max_vals(1) & mean(mouse_vel_context{mouse,context}.stim,2)<=min_max_vals(2)));
        speed_trials_ctrl{2,mouse}{2,context} = (find(mean(mouse_vel_context{mouse,context}.ctrl,2)>=min_max_vals(1) & mean(mouse_vel_context{mouse,context}.ctrl,2)<=min_max_vals(2)));

    end
end