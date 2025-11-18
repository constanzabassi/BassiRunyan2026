function globalIndices = convert_indices_local_to_global(current_var, datasetNeuronCounts, varargin)
% CONVERT_INDICES_LOCAL_TO_GLOBAL Converts local neuron indices to global indices.

% This function takes a cell array `current_var`, where each cell contains 
% local indices referring to neurons within a specific dataset. It converts 
% these local indices into global indices by adjusting for dataset offsets.
%
% INPUTS:
%   - current_var: A cell array where each cell contains an array of local indices.
%   - datasetNeuronCounts: A vector containing the number of neurons in each dataset.
%   - vargin: (Optional) dataset index in case it is not in order to make
%   sure we add the correct offset value!
%
% OUTPUT:
%   - globalIndices: A single array containing the converted global indices.

% Initialize an empty array to store global indices
globalIndices = [];

% Initialize the offset, which keeps track of the cumulative neuron count
offset = 0;

% Get the number of datasets
numDatasets = numel(current_var);
offset_values = [0,cumsum(datasetNeuronCounts)'];
if nargin > 2
    offset_values = offset_values(varargin{1,1});
end

% Loop through each dataset
for d = 1:numDatasets
    % Convert local indices to global indices by adding the offset
    globalIndices = [globalIndices, reshape(current_var{d}, 1, []) + offset_values(d)];
end
