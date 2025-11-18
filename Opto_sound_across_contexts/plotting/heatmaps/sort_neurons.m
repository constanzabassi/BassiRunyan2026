function [sorted_idx, sort_vals] = sort_neurons(data, params)
    switch params.sort_method
        case 'peak'
            [sort_vals, sorted_idx] = sort(max(data(:,params.response_window), [], 2));
        case 'latency'
            [~, peak_times] = max(data(:,params.response_window), [], 2);
            [~, sorted_idx] = sort(peak_times);
            sort_vals = peak_times(sorted_idx);
        case 'magnitude'
            sort_vals = mean(abs(data(:,params.response_window)), 2);
            [sort_vals, sorted_idx] = sort(sort_vals);
    end

    sorted_idx = sorted_idx(end:-1:1);
end