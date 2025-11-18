function pools = categorize_selective_cells(selectivity_active, selectivity_passive, threshold, sig_cells,sig_selective_neurons, params)
    % Categorizes neurons into selectivity pools for both active and passive contexts
    %
    % Inputs:
    %   selectivity_active  - Vector of selectivity indices from active context
    %   selectivity_passive - Vector of selectivity indices from passive context
    %   threshold          - Numeric threshold for determining selectivity
    %                       (typically 0.1 or 0.2)
    %   sig_cells         - Indices of significantly modulated cells to analyze
    %
    % Output:
    %   pools - Structure with fields:
    %           .active.{left, right, nonsel}  - Cell indices for active context
    %           .passive.{left, right, nonsel} - Cell indices for passive context
    %           .both.{left, right, nonsel}    - Cell indices selective in both contexts
    
    % Initialize output structure
    pools = struct();
    
    % Categorize cells in active context
    [pools.active.left, pools.active.right, pools.active.nonsel] = ...
        categorize_selectivity_context(selectivity_active, threshold, sig_cells, sig_selective_neurons);
    
    % Categorize cells in passive context
    [pools.passive.left, pools.passive.right, pools.passive.nonsel] = ...
        categorize_selectivity_context(selectivity_passive, threshold, sig_cells, sig_selective_neurons);
    
%     % Find cells selective in both contexts
%     pools.both.left = union(pools.active.left, pools.passive.left);
%     pools.both.right = union(pools.active.right, pools.passive.right);
%     
%     % Find consistently non-selective cells
%     pools.both.nonsel = union(pools.active.nonsel, pools.passive.nonsel);

    % Find cells selective in both contexts
    % Ensure neurons do not switch selectivity between contexts
    common_left = intersect(pools.active.left, pools.passive.left);
    common_right = intersect(pools.active.right, pools.passive.right);
    
    % Find neurons that switch from left to right or vice versa
    switchers = intersect(pools.active.left, pools.passive.right);
    switchers = union(switchers, intersect(pools.active.right, pools.passive.left));
    
    % Define selective pools based on mode
    if strcmp(params.selectivity_sounds.selectivity_sig_mode, 'union')
        % Union, but remove switchers
        pools.both.left = setdiff(union(pools.active.left, pools.passive.left), switchers);
        pools.both.right = setdiff(union(pools.active.right, pools.passive.right), switchers);
    elseif strcmp(params.selectivity_sounds.selectivity_sig_mode, 'intersect')
        % Strict intersection
        pools.both.left = common_left;
        pools.both.right = common_right;
    else
        error('Invalid selectivity_sig_mode. Choose ''union'' or ''intersect''.');
    end

    % Non-selective pool: Anything that isn't in left or right
    pools.both.nonsel = setdiff(sig_cells, [pools.both.left, pools.both.right]);
    
    % Add metadata about selectivity consistency
%     pools.stats.consistency = compute_selectivity_consistency(pools);
end
% 
% function consistency = compute_selectivity_consistency(pools)
%     % Compute statistics about selectivity consistency across contexts
%     consistency = struct();
%     
%     % Calculate total cells in each category
%     consistency.total_cells = length([pools.active.left, pools.active.right, pools.active.nonsel]);
%     
%     % Calculate numbers of consistent cells
%     consistency.consistent_left = length(pools.both.left);
%     consistency.consistent_right = length(pools.both.right);
%     consistency.consistent_nonsel = length(pools.both.nonsel);
%     
%     % Calculate percentages
%     consistency.percent_consistent_left = 100 * length(pools.both.left) / length(pools.active.left);
%     consistency.percent_consistent_right = 100 * length(pools.both.right) / length(pools.active.right);
%     consistency.percent_consistent_nonsel = 100 * length(pools.both.nonsel) / length(pools.active.nonsel);
%     
%     % Calculate overall consistency
%     total_consistent = length(pools.both.left) + length(pools.both.right) + length(pools.both.nonsel);
%     consistency.overall_consistency = 100 * total_consistent / consistency.total_cells;
% end