function response = compute_neuron_averages(data,valid_trials, response_window)
    % Compute per-neuron averages and SEMs
    % Output maintains neuron-specific responses
    
    response = struct();
    n_neurons = size(data, 2);
    n_frames = length(response_window);
    
    % Initialize arrays for per-neuron statistics
    response.neuron_mean = nan(n_neurons, n_frames);
    response.neuron_sem = nan(n_neurons, n_frames);
    
    % Compute statistics for each neuron
    for n = 1:n_neurons
        neuron_data = squeeze(data(valid_trials, n, response_window));
        response.neuron_mean(n, :) = mean(neuron_data, 1);
        response.neuron_sem(n, :) = std(neuron_data, [], 1) / sqrt(size(neuron_data, 1));
    end
    
    % Also compute population statistics
    response.pop_mean = mean(response.neuron_mean, 1);
    response.pop_sem = std(response.neuron_mean, [], 1) / sqrt(n_neurons);
end