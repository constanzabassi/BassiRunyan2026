function [cv_mod_index, cv_mod_index_separate, bootstrapResults] = handle_separate_mode(...
    stim_data, ctrl_data, stim_trials, ctrl_trials, current_conditions, current_conditions_ctrl, ...
    response_range, mod_type, nRepeats, nShuffles, specified_lr)
%compute modulation index independently for left and right sound trials
%use the max(abs(mod index)) of either side as the mod index for that cell


nNeurons = size(stim_data, 2);

% Process left side
[cv_mod_left, left_stim_data, left_ctrl_data] = process_single_side(...
    stim_data, ctrl_data, stim_trials, ctrl_trials, current_conditions, ...
    current_conditions_ctrl, response_range, mod_type, nRepeats, specified_lr, 'left');

% Process right side
[cv_mod_right, right_stim_data, right_ctrl_data] = process_single_side(...
    stim_data, ctrl_data, stim_trials, ctrl_trials, current_conditions, ...
    current_conditions_ctrl, response_range, mod_type, nRepeats, specified_lr, 'right');

% Select max side and prepare output
[cv_mod_index, cv_mod_index_separate,side] = select_max_side(...
    cv_mod_left, cv_mod_right, nNeurons);

% Bootstrap if requested
% Bootstrap: perform separately for left and right, then select based on chosen side.
if nShuffles > 0
    pVals_left = bootstrap_mod_index_cv(left_stim_data, left_ctrl_data, response_range, nShuffles, mod_type);
    pVals_right = bootstrap_mod_index_cv(right_stim_data, right_ctrl_data, response_range, nShuffles, mod_type);
    pVals_max = zeros(1, nNeurons);
    for n = 1:nNeurons
        if strcmp(side{n}, 'left')
            pVals_max(n) = pVals_left(n);
        else
            pVals_max(n) = pVals_right(n);
        end
    end
    bootstrapResults.left = pVals_left;
    bootstrapResults.right = pVals_right;
    bootstrapResults.max = pVals_max;
    bootstrapResults.pVals = pVals_max;
else

    bootstrapResults = [];
end
end