function combined_results = combine_dataset_results(all_results, total_cells_per_dataset, all_celltypes)
    % Initialize result structures
    combined_results = struct();
    contexts = {'active', 'passive', 'both'}; % Contexts for selectivity categorization
    pool_types = {'left', 'right', 'nonsel'};
    
    % Calculate cumulative sum for global indexing
    cells_cumsum = [0; cumsum(total_cells_per_dataset)];
    
    % Process data for each context and pool type
    [combined_results, all_pool_indices] = process_pool_data(all_results, cells_cumsum, contexts, pool_types);
    
    % Add cell type information if provided
    if nargin > 2 && ~isempty(all_celltypes)
        combined_results.celltypes = categorize_celltypes_by_pool(all_pool_indices, all_celltypes, cells_cumsum);
    end
end

function [combined_results, all_pool_indices] = process_pool_data(all_results, cells_cumsum, contexts, pool_types)
    % Initialize structures
    combined_results = struct();
    all_pool_indices = struct();
    
    % Process each selectivity categorization context
    for ctx_idx = 1:length(contexts)
        context = contexts{ctx_idx};
        for p_idx = 1:length(pool_types)
            pool_type = pool_types{p_idx};
            
            % Initialize arrays for current pool
            pool_data = struct(...
                'active_left_mod', [], ...
                'active_right_mod', [], ...
                'passive_left_mod', [], ...
                'passive_right_mod', [], ...
                'active_max_mod', [], ...
                'passive_max_mod', [], ...
                'active_preferred', {{}}, ...
                'passive_preferred', {{}}, ...
                'cell_indices', [], ...
                'relative_cell_indices', [], ...
                'dataset_ids', []);
            indices = [];
            
            % Concatenate data across datasets
            for d_idx = 1:length(all_results)
                dataset = all_results{d_idx};
                curr_pool = dataset.(context).(pool_type);
                
                % Adjust indices for global reference
                global_indices = curr_pool.cell_indices + cells_cumsum(d_idx);
                
                % Accumulate data
                pool_data = accumulate_pool_data(pool_data, curr_pool, global_indices, d_idx);
                indices = [indices; global_indices(:)];
            end
            
            % Store combined results
            combined_results.(context).(pool_type) = create_pool_struct(pool_data);
            all_pool_indices.(context).(pool_type) = indices;
        end
    end
end

function pool_data = accumulate_pool_data(pool_data, curr_pool, global_indices, dataset_id)
    % Accumulate modulation data from both contexts
    pool_data.active_left_mod = [pool_data.active_left_mod; curr_pool.active_left_mod(:)];
    pool_data.active_right_mod = [pool_data.active_right_mod; curr_pool.active_right_mod(:)];
    pool_data.passive_left_mod = [pool_data.passive_left_mod; curr_pool.passive_left_mod(:)];
    pool_data.passive_right_mod = [pool_data.passive_right_mod; curr_pool.passive_right_mod(:)];
    pool_data.active_max_mod = [pool_data.active_max_mod; curr_pool.active_max_mod(:)];
    pool_data.passive_max_mod = [pool_data.passive_max_mod; curr_pool.passive_max_mod(:)];
    pool_data.active_preferred = [pool_data.active_preferred; curr_pool.active_preferred(:)];
    pool_data.passive_preferred = [pool_data.passive_preferred; curr_pool.passive_preferred(:)];
    pool_data.cell_indices = [pool_data.cell_indices; global_indices(:)];
    n_cells = numel(curr_pool.cell_indices);
    pool_data.relative_cell_indices = [pool_data.relative_cell_indices; curr_pool.cell_indices(:)];
    pool_data.dataset_ids = [pool_data.dataset_ids; repmat(dataset_id, n_cells, 1)];

end

function pool_struct = create_pool_struct(pool_data)
    % Create final structure with all modulation data
    pool_struct = struct(...
        'active_left_mod', pool_data.active_left_mod, ...
        'active_right_mod', pool_data.active_right_mod, ...
        'passive_left_mod', pool_data.passive_left_mod, ...
        'passive_right_mod', pool_data.passive_right_mod, ...
        'active_max_mod', pool_data.active_max_mod, ...
        'passive_max_mod', pool_data.passive_max_mod, ...
        'active_preferred', {pool_data.active_preferred}, ...
        'passive_preferred', {pool_data.passive_preferred}, ...
        'cell_indices', pool_data.cell_indices, ...
        'relative_cell_indices', pool_data.relative_cell_indices, ...
        'dataset_ids', pool_data.dataset_ids);
    
    % Add statistics
    pool_struct.stats = compute_pool_stats(pool_struct);
end
function celltype_pools = categorize_celltypes_by_pool(all_pool_indices, all_celltypes, cells_cumsum)
    % Initialize cell type tracking structure
    celltype_pools = struct();
    celltypes = {'pyr', 'som', 'pv'};
    contexts = {'active', 'passive','both'};
    pool_types = {'left', 'right', 'nonsel'};
    
    for ctx_idx = 1:length(contexts)
        context = contexts{ctx_idx};
        for pool_idx = 1:length(pool_types)
            pool = pool_types{pool_idx};
            
            % Get global indices for current pool
            pool_indices = all_pool_indices.(context).(pool);
            
            % Categorize by cell type
            for type_idx = 1:length(celltypes)
                ctype = celltypes{type_idx};
                celltype_pools.(ctype).(context).(pool) = ...
                    find_celltype_in_pool(pool_indices, all_celltypes, ctype, cells_cumsum);
            end
        end
    end
end

function type_indices = find_celltype_in_pool(pool_indices, all_celltypes, celltype, cells_cumsum)
    type_indices = [];
    field_name = [celltype '_cells'];
    
    for dataset_idx = 1:length(all_celltypes)
        % Get cells of this type in current dataset
        dataset_cells = all_celltypes{1,dataset_idx}.(field_name);
        
        % Adjust indices for global reference
        global_cells = dataset_cells + cells_cumsum(dataset_idx);
        
        % Find intersection with pool indices
        type_indices = [type_indices; intersect(pool_indices, global_cells)];
    end
end