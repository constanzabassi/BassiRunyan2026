function [divided_trials_stim, divided_trials_ctrl] = divide_context_trials(stim_trials_context, ctrl_trials_context, num_divisions)
% This function divides trials into equal parts based on the specified number of divisions.
% 
% Inputs:
%   - stim_trials_context: Cell array containing stimulus trials for each dataset and context.
%   - ctrl_trials_context: Cell array containing control trials for each dataset and context.
%   - num_divisions: (Optional) Number of divisions; defaults to 2 (halves).
%
% Outputs:
%   - divided_trials_stim: Cell array where each entry contains subsets of stim trials.
%   - divided_trials_ctrl: Cell array where each entry contains subsets of control trials.

% Default to dividing trials into 2 parts if not specified
if nargin < 3
    num_divisions = 2;
end

% Initialize output cell arrays
divided_trials_stim = cell(size(1,2));
divided_trials_ctrl = cell(size(1,2));

% Iterate through datasets
for dataset_id = 1:length(stim_trials_context)
    % Iterate through contexts
    for context = 1:size(stim_trials_context{1,1}, 2)
        % Extract stimulus and control trials for the current dataset and context
        stim_trials = stim_trials_context{1,dataset_id}{1,context};
        control_trials = ctrl_trials_context{1,dataset_id}{1,context};
        
        % Get total number of trials
        num_stim_trials = length(stim_trials);
        num_ctrl_trials = length(control_trials);
        
        % Determine the size of each trial division
        stim_div_size = floor(num_stim_trials / num_divisions);
        ctrl_div_size = floor(num_ctrl_trials / num_divisions);
        
        % Divide stimulus trials
        for div = 1:num_divisions
            start_idx = (div - 1) * stim_div_size + 1;
            if div == num_divisions
                end_idx = num_stim_trials; % Ensure last division includes remaining trials
            else
                end_idx = div * stim_div_size;
            end
            divided_trials_stim{div}{dataset_id}{context} = stim_trials(start_idx:end_idx);
        end
        
        % Divide control trials
        for div = 1:num_divisions
            start_idx = (div - 1) * ctrl_div_size + 1;
            if div == num_divisions
                end_idx = num_ctrl_trials; % Ensure last division includes remaining trials
            else
                end_idx = div * ctrl_div_size;
            end
            divided_trials_ctrl{div}{dataset_id}{context} = control_trials(start_idx:end_idx);
        end
    end
end
end
