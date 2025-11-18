function [avg_response_stim,avg_response_ctrl] = separate_trial_types(stim_trials,ctrl_trials, trial_info,trial_info_ctrl, params)
% separate trials into left, right or all, or pooled (balanced)    
% Get trials based on trial type
    
    if strcmpi(params.mode, 'pooled')
        % Pool all trials together
                

    else
        %START WITH STIM
        % Separate left and right trials
        left_trials = valid_trials_stim(find(trial_info == 1));
        right_trials = valid_trials_stim(find(trial_info == 2));
        if all(isnan(left_trials)) && all(isnan(right_trials)) %spont condition!
            % Compute averages for each condition
            avg_response_stim.stim = compute_neuron_averages(neural_data_stim, valid_trials_stim, ...
                 params.response_window);
            avg_response_stim.ctrl = compute_neuron_averages(neural_data_ctrl, valid_trials_ctrl, ...
                 params.response_window);

        else
            % Compute averages for each condition
            avg_response_stim.left = compute_neuron_averages(neural_data_stim, left_trials, ...
                 params.response_window);
            avg_response_stim.right = compute_neuron_averages(neural_data_stim, right_trials, ...
                 params.response_window);
        end
        
        

        % Store trial counts
        avg_response_stim.trial_counts = struct(...
            'left', length(left_trials), ...
            'right', length(right_trials));

        %DO THE SAME FOR CONTROL!
        % Separate left and right trials
        left_trials = valid_trials_ctrl(find(trial_info_ctrl == 1));
        right_trials = valid_trials_ctrl(find(trial_info_ctrl == 2));

        if all(isnan(left_trials)) && all(isnan(right_trials)) %spont condition!
            % Compute averages for each condition
            avg_response_ctrl.ctrl = compute_neuron_averages(neural_data_ctrl, valid_trials_ctrl, ...
                 params.response_window);
            avg_response_ctrl.stim = compute_neuron_averages(neural_data_stim, valid_trials_stim, ...
                 params.response_window);
        else

            avg_response_ctrl.left = compute_neuron_averages(neural_data_ctrl, left_trials, ...
                 params.response_window);
    
            avg_response_ctrl.right = compute_neuron_averages(neural_data_ctrl, right_trials, ...
                 params.response_window);
        end
 
        % Store trial counts
        avg_response_ctrl.trial_counts = struct(...
            'left', length(left_trials), ...
            'right', length(right_trials));
    end
end