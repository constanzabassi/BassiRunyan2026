function [cv_mod, stim_data_out, ctrl_data_out] = process_single_side(...
    stim_data, ctrl_data, stim_trials, ctrl_trials, current_conditions, ...
    current_conditions_ctrl, response_range, mod_type, nRepeats, specified_lr, side)
    
%start with random seed for reproducibility!
rng(123);

    % Initialize storage
    nNeurons = size(stim_data, 2);
    cv_mod_all = zeros(nRepeats, nNeurons);
    
    % Cross-validation repeats
    for reps = 1:nRepeats
%         reps
        % Get trial indices
        [stim_trials_side, ctrl_trials_side] = get_side_trials(specified_lr, ...
            stim_trials, ctrl_trials, current_conditions, current_conditions_ctrl, side);
        
        % Extract data for this side
        stim_data_out = stim_data(stim_trials_side, :, :);
        ctrl_data_out = ctrl_data(ctrl_trials_side, :, :);
    

        % Split data into folds
        [fold1_data1, fold2_data1] = split_data(stim_data_out);
        [fold1_data2, fold2_data2] = split_data(ctrl_data_out);
        
        % Compute averages across folds
        % using mod_type to decide what to take the average of
        [avg_data1_fold1, avg_data2_fold1] = utils.compute_fold_averages(fold1_data1, fold1_data2, response_range, mod_type); %fold 1
        [avg_data1_fold2, avg_data2_fold2] = utils.compute_fold_averages(fold2_data1, fold2_data2, response_range, mod_type); %fold 2
        
        % Compute modulation indices
        mod1 = compute_mod_index(avg_data1_fold1, avg_data2_fold1, mod_type);
        mod2 = compute_mod_index(avg_data1_fold2, avg_data2_fold2, mod_type);
        
        % Store average of folds
        cv_mod_all(reps, :) = (mod1 + mod2) / 2;

    end
    
    % Final cross-validated index
    cv_mod = mean(cv_mod_all, 1);
end

function [stim_trials_side, ctrl_trials_side] = get_side_trials(specified_lr, ...
    stim_trials, ctrl_trials, current_conditions, current_conditions_ctrl, side)
    
    if ~isempty(specified_lr)
        if strcmp(side, 'left')
            stim_trials_side = specified_lr.left_stim;
            ctrl_trials_side = specified_lr.left_ctrl;
        else
            stim_trials_side = specified_lr.right_stim;
            ctrl_trials_side = specified_lr.right_ctrl;
        end
    else
        %balance trials
        [~, ~, left_stim, left_ctrl, right_stim, right_ctrl] = ...
            find_sound_trials_single(stim_trials, ctrl_trials, ...
            current_conditions, current_conditions_ctrl);
        
        if strcmp(side, 'left')
            stim_trials_side = left_stim;
            ctrl_trials_side = left_ctrl;
        else
            stim_trials_side = right_stim;
            ctrl_trials_side = right_ctrl;
        end
    end
end