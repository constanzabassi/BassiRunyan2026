function selectivity_results = analyze_mod_by_selectivity_pool(mod_index_results, pools)
% Analyzes modulation indices for different selectivity pools (left/right/non-selective)
    %
    % Inputs:
    %   mod_index_results - Structure containing modulation indices for each context
    %                       Fields: context(1:2).cv_mod_index_separate
    %   pools            - Structure containing cell indices for each selectivity pool
    %                      Fields: active/passive.left/right/nonsel
    %
    % Output:
    %   selectivity_results - Structure containing modulation analysis by context and pool
    %                        Format: context.pool_type.{left_mod,right_mod,max_mod,
    %                                preferred_side,cell_indices,stats}

    % Initialize structure for both contexts
    contexts = {'active', 'passive'};
    contexts_pool = {'active', 'passive','both'};
    pool_types = {'left', 'right', 'nonsel'};
    
    for context_idx = 1:length(contexts)
        context = contexts{context_idx};
        
        % Get modulation indices for current context
        mod_data = mod_index_results.context(context_idx).cv_mod_index_separate;
        
        for context_pool_index = 1:length(contexts_pool)
            context_pool = contexts_pool{context_pool_index};

            % For each pool type (left/right/nonsel)
            for p_idx = 1:length(pool_types)
                pool_type = pool_types{p_idx};
                pool_cells = pools.(context_pool).(pool_type);
                
                % Store modulation indices for this pool
                selectivity_results.(context_pool).(pool_type) = struct(...
                    'left_mod', mod_data.left(pool_cells), ...
                    'right_mod', mod_data.right(pool_cells), ...
                    'max_mod', mod_data.max(pool_cells), ...
                    'preferred_side', {mod_data.side(pool_cells)}, ...
                    'cell_indices', pool_cells);
                
                % Calculate summary statistics
                selectivity_results.(context_pool).(pool_type).stats = compute_pool_stats(...
                    selectivity_results.(context_pool).(pool_type));
            end
        end
    end
end
