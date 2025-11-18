function mod_index = compute_mod_index_prepost(post_avg, pre_avg)
% compute_mod_index_prepost computes the modulation index for each neuron
% using the formula:
%
%     mod_index = (mean(post) - mean(pre)) / (mean(pre) + mean(post))
%
% where the mean is taken across trials. The inputs are matrices of averaged
% responses (over the specified response_range) with dimensions:
%      [nTrials x nNeurons]
%
% For each neuron, if (mean(pre) + mean(post)) equals zero, the index is set to 0.
% Also, if the computed index is exactly 1 or -1 and one of the responses is zero,
% the index is set to 0.
%
%   Inputs:
%     pre_avg : Matrix of pre stim responses [nTrials x nNeurons]
%     ctrl_avg : Matrix of post stim responses [nTrials_ctrl x nNeurons]
%
%   Output:
%     mod_index: 1 x nNeurons vector of modulation indices.
    nNeurons = size(post_avg, 2);
    mod_index = zeros(1, nNeurons);
    for cel = 1:nNeurons
        % Compute the average response for the neuron across trials.
        post_val = mean(post_avg(:, cel));
        pre_val = mean(pre_avg(:, cel));
        if (post_val + pre_val) == 0
            mod_index(cel) = 0;
        else
            mod_index(cel) = (post_val - pre_val) / (post_val + pre_val);
        end
        % If the result is exactly 1 or -1 and one of the responses is zero, set index to 0.
        if ((mod_index(cel) == 1 || mod_index(cel) == -1) && (post_val == 0 || pre_val == 0))
            mod_index(cel) = 0;
        end
    end
end