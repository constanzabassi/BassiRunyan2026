function [stim_trials_updated,ctr_trials_updated,stim_left,stim_right,ctrl_left,ctrl_right] = separate_trial_types(stim_trials,ctrl_trials, trial_info,trial_info_ctrl, params)
% separate trials into left, right or all, or pooled (balanced)    
% Get trials based on trial type

%initialize structures (these will not be used if doing all or pooled
stim_left  = [];
stim_right = [];
ctrl_left = [];
ctrl_right = [];
%get current context trials
    valid_trials_stim = stim_trials;
    valid_trials_ctrl = ctrl_trials;
    
    if strcmpi(params.mode, 'all')
        % Pool all trials together
        stim_trials_updated = valid_trials_stim;
        ctr_trials_updated = valid_trials_ctrl;

    elseif strcmpi(params.mode, 'pooled') %balancing left and right trials
        left_trials = valid_trials_stim(find(trial_info == 1));
        right_trials = valid_trials_stim(find(trial_info == 2));
        left_trials_ctrl = valid_trials_ctrl(find(trial_info_ctrl == 1));
        right_trials_ctrl = valid_trials_ctrl(find(trial_info_ctrl == 2));


        % Balance the number of trials for stimulation and control.
        num_trials_stim = min(length(left_trials), length(right_trials));
        num_trials_ctrl = min(length(left_trials_ctrl), length(right_trials_ctrl));
    
        if all(isnan(left_trials)) && all(isnan(right_trials)) %spont condition!
            stim_trials_updated = valid_trials_stim;
            ctr_trials_updated = valid_trials_ctrl;
        else
            % Randomly sample balanced trials.
            balanced_left_trials_stim = randsample(left_trials, num_trials_stim, false);
            balanced_right_trials_stim = randsample(right_trials, num_trials_stim, false);
            balanced_left_trials_ctrl = randsample(left_trials_ctrl, num_trials_ctrl, false);
            balanced_right_trials_ctrl = randsample(right_trials_ctrl, num_trials_ctrl, false);
    
            %put trials together
            stim_trials_updated = [balanced_left_trials_stim,balanced_right_trials_stim];
            ctr_trials_updated = [balanced_left_trials_ctrl,balanced_right_trials_ctrl];
    
            %store values
            stim_left  = balanced_left_trials_stim;
            stim_right = balanced_right_trials_stim;
            ctrl_left = balanced_left_trials_ctrl;
            ctrl_right = balanced_right_trials_ctrl;
        end

    else
        %START WITH STIM
        % Separate left and right trials
        left_trials = valid_trials_stim(find(trial_info == 1));
        right_trials = valid_trials_stim(find(trial_info == 2));
        if all(isnan(left_trials)) && all(isnan(right_trials)) %spont condition!
            stim_trials_updated = valid_trials_stim;
            stim_left  = valid_trials_stim;
            stim_right = valid_trials_stim;
        else
            stim_trials_updated = valid_trials_stim;
            stim_left = left_trials;
            stim_right = right_trials;
        end
        

        %DO THE SAME FOR CONTROL!
        % Separate left and right trials
        left_trials = valid_trials_ctrl(find(trial_info_ctrl == 1));
        right_trials = valid_trials_ctrl(find(trial_info_ctrl == 2));

        if all(isnan(left_trials)) && all(isnan(right_trials)) %spont condition!
            % Compute averages for each condition
            ctr_trials_updated = valid_trials_ctrl;
            ctrl_left = valid_trials_ctrl;
            ctrl_right = valid_trials_ctrl;
        else
            ctr_trials_updated = valid_trials_ctrl;
            ctrl_left = left_trials;
            ctrl_right = right_trials;
        end
 
    end
end