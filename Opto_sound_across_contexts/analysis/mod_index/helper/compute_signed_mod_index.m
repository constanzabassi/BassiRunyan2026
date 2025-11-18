function mod_index = compute_signed_mod_index(stim_avg, ctrl_avg)
% compute_signed_mod_index computes the signed modulation selectivity index:
%
%     mod_index = (stim - ctrl) / (|stim| + |ctrl| + epsilon)
%
% This version is robust to suppression and avoids exploding values near zero.
%
%   Inputs:
%     stim_avg : Matrix of stim responses [nTrials x nNeurons]
%     ctrl_avg : Matrix of control responses [nTrials_ctrl x nNeurons]
%
%   Output:
%     mod_index: 1 x nNeurons vector of signed modulation indices.

    epsilon = 1e-5;  % small constant to avoid divide-by-zero
    nNeurons = size(stim_avg, 2);
    mod_index = zeros(1, nNeurons);

    for cel = 1:nNeurons
        stim_val = mean(stim_avg(:, cel));
        ctrl_val = mean(ctrl_avg(:, cel));

        numerator = stim_val - ctrl_val;
        denominator = abs(stim_val) + abs(ctrl_val) + epsilon;

        mod_index(cel) = numerator / denominator;
    end
end
