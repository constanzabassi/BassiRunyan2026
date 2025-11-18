function [avg_response_stim,avg_response_ctrl] = get_trial_averaged_response(neural_data_stim, neural_data_ctrl,stim_trials,ctrl_trials, trial_info,trial_info_ctrl, params)
    % Get trial-averaged neural responses for specific conditions
    % 
    % Inputs:
    %   neural_data - stim: [trials x neurons x frames]
    %                 ctrl: [trials x neurons x frames]
    %   trial_info  - Structure with trial conditions
    %   trial_info_ctrl -Structure with trial conditions for control matrix
    %   params     - Structure with:
    %                .response_window - Frames to average over
    %                .trial_types    - 'stim', 'sounds'
    %                .mode          - 'pooled' or 'separate'
    
    % Initialize output structure
    avg_response_stim = struct();
    avg_response_ctrl = struct();

    %get current context trials
    valid_trials_stim = stim_trials;
    valid_trials_ctrl = ctrl_trials;
    
    % Get relevant data and trials based on trial type
    
    if strcmpi(params.mode, 'pooled')
        % Pool all trials together
        %STIM
        avg_response_stim = compute_neuron_averages(neural_data_stim, valid_trials_stim, ...
             params.response_window);

        %CTRL
        avg_response_ctrl = compute_neuron_averages(neural_data_ctrl, valid_trials_ctrl, ...
             params.response_window);
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

