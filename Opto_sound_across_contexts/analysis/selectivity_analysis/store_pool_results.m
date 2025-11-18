function results = store_pool_results(pools, active_mod, passive_mod)
    % Stores modulation data for cells categorized by their selectivity in different contexts
    %
    % Inputs:
    %   pools       - Structure containing cell indices categorized by:
    %                 - active: cells selective in active context
    %                 - passive: cells selective in passive context
    %                 - both: cells selective in both contexts
    %   active_mod  - Structure with modulation indices from active context
    %   passive_mod - Structure with modulation indices from passive context
    %
    % Output:
    %   results - Structure organized as:
    %            .active/.passive/.both (selectivity categorization)
    %               .left/.right/.nonsel (pool types)
    %                   .active_left_mod  - Modulation to left sounds in active
    %                   .active_right_mod - Modulation to right sounds in active
    %                   .passive_left_mod - Modulation to left sounds in passive
    %                   .passive_right_mod- Modulation to right sounds in passive

    % Initialize structure
    results = struct();

    pool_context = {'active','passive', 'both'};

    pool_types = {'left', 'right', 'nonsel'};

    % Loop through each context used for categorizing selectivity
    for pool_contexts = 1:length(pool_context)
        pool_context_type = pool_context{pool_contexts};

        % For each selectivity type (left/right/non-selective)
        for p_idx = 1:length(pool_types)
            pool_type = pool_types{p_idx};

            % Get indices of cells in this pool
            pool_cells = pools.(pool_context_type).(pool_type);
            
            % Store modulation from both contexts for these cells
            results.(pool_context_type).(pool_type) = struct(...
                'active_left_mod', active_mod.left(pool_cells), ...
                'active_right_mod', active_mod.right(pool_cells), ...
                'passive_left_mod', passive_mod.left(pool_cells), ...
                'passive_right_mod', passive_mod.right(pool_cells), ...
                'active_max_mod', active_mod.max(pool_cells), ...
                'passive_max_mod', passive_mod.max(pool_cells), ...
                'active_preferred', {active_mod.side(pool_cells)}, ...
                'passive_preferred', {passive_mod.side(pool_cells)}, ...
                'cell_indices', pool_cells);
        end
    end
end
