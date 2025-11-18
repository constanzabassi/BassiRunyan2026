function [local_indices, dataset_ids] = convert_indices_global_to_local(global_indices, datasetNeuronCounts)
    % Convert global neuron indices to local indices and their dataset IDs
    %
    % Inputs:
    %   global_indices       - Vector of global neuron indices
    %   datasetNeuronCounts - Vector containing number of neurons per dataset
    %
    % Outputs:
    %   local_indices - Vector of local indices within their respective datasets
    %   dataset_ids   - Vector identifying which dataset each index belongs to
    
    % Calculate cumulative sum for dataset boundaries
    cumsum_neurons = [0; cumsum(datasetNeuronCounts(:))];
    
    % Initialize output arrays
    n_indices = length(global_indices);
    local_indices = zeros(size(global_indices));
    dataset_ids = zeros(size(global_indices));
    
    % Convert each global index
    for i = 1:n_indices
        global_idx = global_indices(i);
        
        % Find which dataset this neuron belongs to
        dataset_id = find(global_idx <= cumsum_neurons(2:end) & ...
            global_idx > cumsum_neurons(1:end-1));
        
        % Convert to local index
        local_idx = global_idx - cumsum_neurons(dataset_id);
        
        % Store results
        local_indices(i) = local_idx;
        dataset_ids(i) = dataset_id;
    end
end