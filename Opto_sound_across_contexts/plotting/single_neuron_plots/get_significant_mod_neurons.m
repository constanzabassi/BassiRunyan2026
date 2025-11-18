function sig_neurons = get_significant_mod_neurons(mod_index, sig_mod_boot, modulation_type)
% GET_SIGNIFICANT_NEURONS filters and sorts the preselected significant neurons based on a modulation threshold.
%
%   Inputs:
%     mod_index      - 1 x nNeurons vector of modulation indices.
%     sig_mod_boot   - Vector of neuron indices (local indices) that were already determined
%                      to be significant by bootstrapping.
%     modulation_type- Numeric flag:
%                        1 to select neurons with positive modulation,
%                       -1 to select neurons with negative modulation.
%
%   Output:
%     sig_neurons    - Vector of neuron indices (subset of sig_mod_boot) that are significant,
%                      sorted in descending order by the absolute value of their modulation index.
%
%   The function uses a default modulation threshold of 0.1. For modulation_type == 1,
%   only neurons with mod_index >= 0.1 are returned. For modulation_type == -1,
%   only neurons with mod_index <= -0.1 are returned.
%
%   Example:
%       % Suppose mod_index is a 1x100 vector and sig_mod_boot = [3, 7, 15, 20].
%       % For positive modulation:
%       sig_neurons = get_significant_neurons(mod_index, sig_mod_boot, 1);
%
%   Author: Your Name, Date
    % Set default modulation threshold.
    mod_threshold = 0.1;
    % Filter the significant neurons (from bootstrap) based on the modulation threshold.
    if modulation_type == 1
        % For positive modulation: select neurons with mod_index >= mod_threshold.
        candidateIndices = sig_mod_boot(mod_index(sig_mod_boot) >= mod_threshold);
    elseif modulation_type == -1
        % For negative modulation: select neurons with mod_index <= -mod_threshold.
        candidateIndices = sig_mod_boot(mod_index(sig_mod_boot) <= -mod_threshold);
    else
        error('modulation_type must be either 1 (positive) or -1 (negative).');
    end
    % Sort the candidate indices in descending order based on the absolute modulation index.
    if ~isempty(candidateIndices)
        [~, sortOrder] = sort(abs(mod_index(candidateIndices)), 'descend');
        sig_neurons = candidateIndices(sortOrder);
    else
        sig_neurons = [];
    end
end
