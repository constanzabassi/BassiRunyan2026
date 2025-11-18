function valid_trials = get_valid_trials(trial_indices, condition_info, params)
    % Extract valid trials based on conditions and trial types
    valid_trials = struct();
    
    switch params.trial_types
        case 'stim'
            trials = intersect(trial_indices, find(condition_info.is_stim));
        case 'ctrl'
            trials = intersect(trial_indices, find(~condition_info.is_stim));
        case 'sound_only'
            trials = intersect(trial_indices, find(condition_info.is_sound_only));
    end
    
    % Sort by condition
    for cond_idx = 1:length(params.conditions)
        condition = params.conditions{cond_idx};
        valid_trials.(condition) = trials(condition_info.condition(trials) == condition);
    end
end