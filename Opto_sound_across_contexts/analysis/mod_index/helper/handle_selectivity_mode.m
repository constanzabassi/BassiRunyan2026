function [cv_mod_index, cv_mod_index_separate, bootstrapResults] = handle_selectivity_mode(...
    stim_data, ctrl_data, stim_trials, ctrl_trials, current_conditions, current_conditions_ctrl, ...
    response_range, mod_type, nRepeats, nShuffles, specified_lr)

%in selectivity mode we are only going to use control trials (sounds
%withot opto!) to compute selectivity to left vs right sounds! (left -
%right / (left+ right)

%start with random seed for reproducibility!
rng(123);

nNeurons = size(stim_data, 2);
cv_mod_all = zeros(nRepeats, nNeurons);

for reps = 1:nRepeats
    % Get balanced trials
    % get trial indices for left and right and balance them (_all
    % is unbalanced trials)
    % If specified left/right indices are provided, use them.
    if ~isempty(specified_lr)
        left_stim  = specified_lr.left_stim;
        left_ctrl  = specified_lr.left_ctrl;
        right_stim = specified_lr.right_stim;
        right_ctrl = specified_lr.right_ctrl;
    else
        % Otherwise, balance the trials using find_sound_trials_single.
        [~, ~, left_stim, left_ctrl, right_stim, right_ctrl,left_stim_all, left_ctrl_all,  right_stim_all, right_ctrl_all] = ...
            find_sound_trials_single(stim_trials, ctrl_trials, current_conditions, current_conditions_ctrl);
    end
    
    % Combine left and right trial indices.
    data1_indices = [left_ctrl(:)]; %[left_stim(:); left_ctrl(:)];
    data2_indices = [right_ctrl(:)]; %[left_stim(:); left_ctrl(:)];

    % Extract data from control
    all_data1 = ctrl_data(data1_indices, :, :); %data1
    all_data2 = ctrl_data(data2_indices, :, :); %data2

     % Split data randomly into two folds
    [fold1_data1, fold2_data1] = split_data(all_data1);
    [fold1_data2, fold2_data2] = split_data(all_data2);
    
    % Compute averages across folds
    % using mod_type to decide what to take the average of
    [avg_data1_fold1, avg_data2_fold1] = utils.compute_fold_averages(fold1_data1, fold1_data2, response_range, mod_type); %fold 1
    [avg_data1_fold2, avg_data2_fold2] = utils.compute_fold_averages(fold2_data1, fold2_data2, response_range, mod_type); %fold 2
    
    % Compute modulation indices
    mod1 = compute_mod_index(avg_data1_fold1, avg_data2_fold1, mod_type);
    mod2 = compute_mod_index(avg_data1_fold2, avg_data2_fold2, mod_type);
        
    % Average the two folds
    cv_mod_all(reps, :) = (mod1 + mod2) / 2;
end

% Compute final results
cv_mod_index = mean(cv_mod_all, 1);
cv_mod_index_separate = [];

% Bootstrap if requested
if nShuffles > 0
    pVals = bootstrap_mod_index_cv(all_data1, all_data2, response_range, nShuffles, mod_type);
    bootstrapResults.pVals = pVals;
else
    bootstrapResults = [];
end
end