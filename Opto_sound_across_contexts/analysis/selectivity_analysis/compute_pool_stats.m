function stats = compute_pool_stats(pool_data)
    % Compute summary statistics for a pool combining active and passive data
    %
    % Input:
    %   pool_data - Structure containing:
    %               .active_left_mod, .active_right_mod
    %               .passive_left_mod, .passive_right_mod
    %               .active_preferred, .passive_preferred
    %
    % Output:
    %   stats    - Structure with summary statistics for both contexts
    
    stats = struct();
    
    % Active context statistics
    stats.active.mean_left = mean(pool_data.active_left_mod);
    stats.active.mean_right = mean(pool_data.active_right_mod);
    stats.active.std_left = std(pool_data.active_left_mod);
    stats.active.std_right = std(pool_data.active_right_mod);
    stats.active.percent_left_pref = sum(strcmp(pool_data.active_preferred, 'left')) / ...
        length(pool_data.active_preferred) * 100;
    
    % Passive context statistics
    stats.passive.mean_left = mean(pool_data.passive_left_mod);
    stats.passive.mean_right = mean(pool_data.passive_right_mod);
    stats.passive.std_left = std(pool_data.passive_left_mod);
    stats.passive.std_right = std(pool_data.passive_right_mod);
    stats.passive.percent_left_pref = sum(strcmp(pool_data.passive_preferred, 'left')) / ...
        length(pool_data.passive_preferred) * 100;
    
    % General pool statistics
    stats.num_cells = length(pool_data.cell_indices);
    
    % Context consistency
    stats.side_consistency = mean(strcmp(pool_data.active_preferred, ...
        pool_data.passive_preferred)) * 100;
end