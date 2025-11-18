function response = compute_average_response(data, response_window)
    response = struct();
    response.mean = squeeze(mean(data(:, :, response_window), 1));
    response.sem = squeeze(std(data(:, :, response_window), [], 1)) / sqrt(size(data, 1));
    
    % Time-averaged response for each neuron
    response.time_avg = mean(response.mean(:, response_window), 2);
    response.time_avg_sem = mean(response.sem(:, response_window), 2);
end