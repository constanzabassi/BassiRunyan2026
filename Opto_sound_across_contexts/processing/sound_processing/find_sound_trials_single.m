function [sound_trials_stim, sound_trials_ctrl, ...
          left_trials_stim, left_trials_ctrl, ...
          right_trials_stim, right_trials_ctrl, ...
          left_trials_stim_all, left_trials_ctrl_all, ...
          right_trials_stim_all, right_trials_ctrl_all] = ...
    find_sound_trials_single(stim_trials, ctrl_trials, current_conditions, current_conditions_ctrl)
% find_sound_trials_single selects and balances sound trials for a single mouse and context.
%
%   Inputs:
%     stim_trials           - Vector of stimulation trial identifiers (or indices) for this context.
%     ctrl_trials           - Vector of control trial identifiers (or indices) for this context.
%     current_conditions    - Array of condition labels for stimulation trials.
%                             For example, condition 1 for left sound and 2 for right sound.
%     current_conditions_ctrl - Array of condition labels for control trials.
%
%   Outputs:
%     sound_trials_stim     - Combined balanced stimulation trial indices (left+right).
%     sound_trials_ctrl     - Combined balanced control trial indices.
%     left_trials_stim      - Balanced left-side stimulation trial indices.
%     left_trials_ctrl      - Balanced left-side control trial indices.
%     right_trials_stim     - Balanced right-side stimulation trial indices.
%     right_trials_ctrl     - Balanced right-side control trial indices.
%     left_trials_stim_all  - All left-side stimulation trial indices (unbalanced).
%     left_trials_ctrl_all  - All left-side control trial indices (unbalanced).
%     right_trials_stim_all - All right-side stimulation trial indices (unbalanced).
%     right_trials_ctrl_all - All right-side control trial indices (unbalanced).
%
%   Example usage:
%     [sound_trials_stim, sound_trials_ctrl, left_trials_stim, left_trials_ctrl, ...
%      right_trials_stim, right_trials_ctrl, left_trials_stim_all, left_trials_ctrl_all, ...
%      right_trials_stim_all, right_trials_ctrl_all] = ...
%          find_sound_trials_single(stim_trials, ctrl_trials, current_conditions, current_conditions_ctrl);
    %% Find left/right trials for stimulation.
    if ~isempty(current_conditions)
        %validate lengths to make sure we can use this trial info
        %structure!
        if length(stim_trials) ~= length(current_conditions) 
            warning('Length mismatch: stim_trials and current_conditions must have the same length.');
        end
        if length(ctrl_trials) ~= length(current_conditions_ctrl)
            warning('Length mismatch: ctrl_trials and current_conditions_ctrl must have the same length.');
        end

        % Find left/right trials for opto.
        sound_left_trials = stim_trials(current_conditions == 1);
        sound_right_trials = stim_trials(current_conditions == 2);
        % Find left/right trials for control.
        sound_left_trials_ctrl = ctrl_trials(current_conditions_ctrl == 1);
        sound_right_trials_ctrl = ctrl_trials(current_conditions_ctrl == 2);
    else %using all trials in the spontaneous context since there are no left or right sounds!
        sound_left_trials = stim_trials;
        sound_right_trials = stim_trials;
        % Find left/right trials for control.
        sound_left_trials_ctrl = ctrl_trials;
        sound_right_trials_ctrl = ctrl_trials;

    end
    % Balance the number of trials for stimulation and control.
    num_trials_stim = min(length(sound_left_trials), length(sound_right_trials));
    num_trials_ctrl = min(length(sound_left_trials_ctrl), length(sound_right_trials_ctrl));

    % Randomly sample balanced trials.
    balanced_left_trials_stim = randsample(sound_left_trials, num_trials_stim, false);
    balanced_right_trials_stim = randsample(sound_right_trials, num_trials_stim, false);
    balanced_left_trials_ctrl = randsample(sound_left_trials_ctrl, num_trials_ctrl, false);
    balanced_right_trials_ctrl = randsample(sound_right_trials_ctrl, num_trials_ctrl, false);

    % Combine balanced trials.
    sound_trials_stim = [balanced_left_trials_stim, balanced_right_trials_stim];
    sound_trials_ctrl = [balanced_left_trials_ctrl, balanced_right_trials_ctrl];

    % Output the balanced trials separately.
    left_trials_stim  = balanced_left_trials_stim;
    left_trials_ctrl  = balanced_left_trials_ctrl;
    right_trials_stim = balanced_right_trials_stim;
    right_trials_ctrl = balanced_right_trials_ctrl;
    
    % Also output the full (unbalanced) left/right trial sets.
    left_trials_stim_all  = sound_left_trials;
    left_trials_ctrl_all  = sound_left_trials_ctrl;
    right_trials_stim_all = sound_right_trials;
    right_trials_ctrl_all = sound_right_trials_ctrl;
end