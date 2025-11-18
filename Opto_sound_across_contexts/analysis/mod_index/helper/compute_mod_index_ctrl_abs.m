function mod_index = compute_mod_index_ctrl_abs(stim_avg, ctrl_avg)
% compute_mod_index_influence computes the modulation index for each neuron
% using the formula:
%
%     mod_index = (mean(stim) - mean(ctrl)) / (abs(mean(stim)) +
%     abs(mean(ctrl)))
%
% where the mean is taken across trials. The inputs are matrices of averaged
% responses (over the specified response_range) with dimensions:
%      [nTrials x nNeurons]
%
% For each neuron, if (mean(stim)+mean(ctrl)) equals zero, the index is set to 0.
% Also, if the computed index is exactly 1 or -1 and one of the responses is zero,
% the index is set to 0.
%
%   Inputs:
%     stim_avg : Matrix of stim responses [nTrials x nNeurons]
%     ctrl_avg : Matrix of control responses [nTrials_ctrl x nNeurons]
%
%   Output:
%     mod_index: 1 x nNeurons vector of modulation indices.
    nNeurons = size(stim_avg, 2);
    mod_index = zeros(1, nNeurons);
    for cel = 1:nNeurons
        % Compute the average response for the neuron across trials.
        stim_val = mean(stim_avg(:, cel));
        ctrl_val = mean(ctrl_avg(:, cel));
        if (stim_val + ctrl_val) == 0
            mod_index(cel) = 0;
        else
            mod_index(cel) = (stim_val - ctrl_val) / (abs(stim_val) + abs(ctrl_val));
        end
        % If the result is exactly 1 or -1 and one of the responses is zero, set index to 0.
        if ((mod_index(cel) == 1 || mod_index(cel) == -1) && (stim_val == 0 || ctrl_val == 0)) || abs(mod_index(cel)) > 1
            mod_index(cel) = 0;
        end
    end
end
