function [trials_left, trials_right] = get_trial_indices_contexts(trials, m, context)
    % Get trial indices based on context
    
    trials_left = trials{1,1}{1,m}{1,context};
    trials_right = trials{2,1}{1,m}{1,context};
end