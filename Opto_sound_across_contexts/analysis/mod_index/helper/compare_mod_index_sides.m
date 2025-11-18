function [sameSideLogical_all, fracSame_all] = compare_mod_index_sides(mod_index_results, varargin)
% compare_mod_index_sides compares the "side" assignments of significantly (or not) modulated neurons 
% across multiple contexts for each dataset.
%
%   Inputs:
%       mod_index_results - Structure array containing modulation index results.
%                           For each dataset, mod_index_results(dataset_index).context(context_index)
%                           should have a field 'cv_mod_index_separate' with a field 'side'
%                           (a cell array of strings, e.g., {'left', 'right', ...}).
%       Optional:
%         sigIndicesAll - A cell array (one cell per dataset) containing vectors of neuron indices 
%                         (local to the dataset) that are significant (e.g., obtained from bootstrap).
%                         If provided, only these neurons will be considered.
%
%   Outputs:
%       sameSideLogical_all - Cell array where each element corresponds to a dataset and contains
%                             a logical vector (1 x nSelectedNeurons) indicating whether each 
%                             neuron has the same "side" across the specified contexts.
%       fracSame_all        - Vector (1 x nDatasets) containing the fraction of neurons with identical
%                             side assignments for each dataset.
%
%   Example:
%       % Without specifying significant indices (use all neurons):
%       [sameSideLogical_all, fracSame_all] = compare_mod_index_sides(mod_index_results);
%
%       % Specifying significant neurons:
%       [sameSideLogical_all, fracSame_all] = compare_mod_index_sides(mod_index_results, sig_mod_boot);
%
%   Author: CB, 2/23/25

% Default: Compare contexts 1 and 2 (e.g., active and passive; context 3 is excluded).
context_indices = [1 2];

% Check if an optional significant indices cell array was provided.
if ~isempty(varargin)
    sigIndicesAll = varargin{1};
else
    sigIndicesAll = [];
end

% Initialize output variables.
fracSame_all = [];
sameSideLogical_all = cell(1, length(mod_index_results));

% Loop over each dataset.
for dataset_index = 1:length(mod_index_results)
    
    % Retrieve the 'side' assignments from the first specified context.
    allSides = mod_index_results(dataset_index).context(context_indices(1)).cv_mod_index_separate.side;
    
    % If significant indices are provided, use them; otherwise, use all neuron indices.
    if ~isempty(sigIndicesAll)
        selectedIndices = sigIndicesAll{dataset_index};
    else
        selectedIndices = 1:numel(allSides);
    end
    
    % Only consider the selected neurons.
    nNeurons = numel(selectedIndices);
    nContexts = numel(context_indices);
    
    % Preallocate a matrix to hold the side assignments.
    sidesMatrix = cell(nContexts, nNeurons);
    
    for ci = 1:nContexts
        % Retrieve the side assignments for the current context and select the relevant neurons.
        currentSides = mod_index_results(dataset_index).context(context_indices(ci)).cv_mod_index_separate.side;
        sidesMatrix(ci, :) = currentSides(selectedIndices);
    end
    
    % For each selected neuron, determine if the side is consistent across contexts.
    sameSideLogical = false(1, nNeurons);
    for neuron = 1:nNeurons
        uniqueSides = unique(sidesMatrix(:, neuron));
        sameSideLogical(neuron) = (numel(uniqueSides) == 1);
    end
    
    % Compute the fraction of neurons with consistent side assignments.
    fracSame = sum(sameSideLogical) / nNeurons;
    
    % Store the results for this dataset.
    fracSame_all = [fracSame_all, fracSame];
    sameSideLogical_all{dataset_index} = sameSideLogical;
end
end

