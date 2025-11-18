function mod_index = compute_mod_index_influence(stim_avg, ctrl_avg)
% compute_mod_index calculates the modulation index from averaged stim and ctrl data.
%
%   stim_avg : Matrix of stim responses [nStimTrials x nNeurons]
%   ctrl_avg : Matrix of control responses [nCtrlTrials x nNeurons]
%
%   For each neuron, the function:
%     1. Computes the difference between each stim trial and the average control response.
%     2. Normalizes the differences by the standard deviation across stim trials.
%     3. Averages the normalized differences to yield the modulation index.

    numStimTrials = size(stim_avg, 1);
    nNeurons = size(stim_avg, 2);
    
    mod_diffs = zeros(numStimTrials, nNeurons);
    
    % Compute the overall average control response for each neuron.
    avg_ctrl_response = mean(ctrl_avg, 1);
    
    % Compute the difference for each stim trial.
    for trials = 1:numStimTrials
        mod_diffs(trials, :) = stim_avg(trials, :) - avg_ctrl_response;
    end
    
    % Compute the standard deviation (across trials) for each neuron.
    std_diffs = std(mod_diffs, 0, 1); %std(stim_avg, 0, 1);%std(mod_diffs, 0, 1);
    std_diffs(std_diffs == 0) = 1;  % Prevent division by zero.
    
    % Normalize each trial's difference.
    norm_diffs = mod_diffs ./ std_diffs;
    
    % Average the normalized differences to get the modulation index.
    mod_index = mean(norm_diffs, 1);
end
