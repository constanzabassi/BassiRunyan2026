function best_interval = find_x_ticks(xticks_min,xticks_max,possible_intervals)

% % Possible intervals to try
% possible_intervals = [ 15, 20, 25];
% Find the interval that gives the most round ticks
best_interval = possible_intervals(1); % Start with the first interval
max_ticks = 0; % Initialize the maximum number of ticks
for interval = possible_intervals
    % Generate ticks for the current interval
    xticks_values = xticks_min:interval:xticks_max;
    % Check if the ticks are round numbers and count them
    if all(mod(xticks_values, 1) == 0) % Ensure they are integers
        num_ticks = length(xticks_values);
        if num_ticks > max_ticks
            max_ticks = num_ticks;
            best_interval = interval;
        end
    end
end