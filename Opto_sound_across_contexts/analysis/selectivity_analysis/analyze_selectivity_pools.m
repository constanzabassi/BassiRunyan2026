function [selectivity_results_by_dataset,selectivity_results_all] = analyze_selectivity_pools(selectivity_indexm, mod_indexm, mod_index_results,selectivity_index_results, sig_mod_boot_thr,all_celltypes, params)

    
    % Get significant cells across active and passive contexts
    if size(sig_mod_boot_thr,2)>1
        [combined_sig_cells, ~] = union_sig_cells(sig_mod_boot_thr(:,1)', ...
            sig_mod_boot_thr(:,2)', mod_indexm);
    else
        combined_sig_cells = sig_mod_boot_thr';
    end

    % Initialize results structure for all datasets
    selectivity_results_by_dataset = cell(1, length(combined_sig_cells));

    
    % Set selectivity threshold
    selectivity_threshold = 0.1; %params.selectivity.threshold || 0.1;
    
    % Loop through datasets
    for dataset_index = 1:length(combined_sig_cells)
        % Get selectivity indices for current dataset
        selectivity_active = selectivity_indexm{dataset_index,1};
        selectivity_passive = selectivity_indexm{dataset_index,2};

        %Get significantly selective neurons for current dataset (use
        %uniont of active and passive)
        sig_selective_neurons = union(selectivity_index_results(dataset_index).context(1).sig_neurons,selectivity_index_results(dataset_index).context(2).sig_neurons);
        
        % Categorize into selectivity pools
        pools{dataset_index} = categorize_selective_cells(selectivity_active, ...
            selectivity_passive, selectivity_threshold, ...
            combined_sig_cells{1,dataset_index},sig_selective_neurons, params);
        
%         % Analyze modulation indices for each pool
%         selectivity_results_by_dataset{dataset_index} = analyze_mod_by_selectivity_pool(...
%             mod_index_results(dataset_index), pools{dataset_index});

    % Get modulation data for both contexts
            active_mod = mod_index_results(dataset_index).context(1).cv_mod_index_separate;
            passive_mod = mod_index_results(dataset_index).context(2).cv_mod_index_separate;
        
        % Store results for each pool including both contexts' modulation
        selectivity_results_by_dataset{dataset_index} = store_pool_results(...
            pools{dataset_index}, active_mod, passive_mod);

    end
    
    %get total cells per context (for global indexing)
    % Use the first context to obtain total cell counts for each dataset.
    total_cells_per_dataset = cellfun(@length, selectivity_indexm(:, 1));
    % Combine results across datasets if needed
    selectivity_results_all = combine_dataset_results(selectivity_results_by_dataset, total_cells_per_dataset,all_celltypes);
    
    % Generate plots
%     if params.plot.enabled
%         plot_selectivity_pools(selectivity_results_all, pools, params);
%     end
end