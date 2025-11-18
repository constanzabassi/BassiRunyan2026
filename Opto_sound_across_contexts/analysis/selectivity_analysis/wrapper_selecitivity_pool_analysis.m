function [selectivity_results_by_dataset_all,selectivity_results_all] = wrapper_selecitivity_pool_analysis(base, params, mod_indexm, mod_indexm2, sig_mod_boot, mod_index_results, selectivity_index_results, avg_results, sorted_cells, all_celltypes, selectivity_indexm, data_type, varargin)
    % WRAPPER FUNCTION FOR SELECTIVITY POOL ANALYSIS
    %
    % Inputs:
    %   base - Base directory for saving results
    %   params - Structure containing analysis parameters
    %   mod_indexm - Modulation index matrix
    %   sig_mod_boot -Indices of modulated neurons (datasets,contexts)
    %   mod_index_results - Results of modulation index calculations (has
    %                       them separated by left and righ sounds)
    %   avg_results - Average results for modulation analysis
    %   sorted_cells - Sorted list of cell indices
    %   all_celltypes - Cell type classifications
    %   selectivity_indexm - Selectivity index matrix
    %   data_type - String specifying the context ('sound' or other)
    %
    % The function iterates over different modulation parameter sets and
    % performs selectivity analysis, saving results to specified directories.
    
    % Define the parameter sets
    param_sets = { 
        struct('mod_threshold', 0.1, 'threshold_single_side', 1, 'savepath', [base 'positive_modulated']),
        struct('mod_threshold', -0.1, 'threshold_single_side', 1, 'savepath', [base 'negative_modulated']),
        struct('mod_threshold', 0.1, 'threshold_single_side', 0, 'savepath', [base 'all_modulated'])
    };

    % Initialize containers
    selectivity_results_all = cell(1, length(param_sets));
    selectivity_results_by_dataset_all = cell(1, length(param_sets));
    
    for i = 1:length(param_sets)
        mod_params = param_sets{i};
        if contains(data_type, 'sound')
            mod_params.chosen_mice = 1:25;
            params.chosen_mice = 1:25;
        else
            mod_params.chosen_mice = 1:24;
            params.chosen_mice = 1:24;
        end
        
        selectivity_params.savepath = mod_params.savepath;
        mkdir(selectivity_params.savepath);

        
%         current_sig_cells = get_thresholded_sig_cells(params.info, mod_params, mod_indexm, sig_mod_boot, sorted_cells, all_celltypes, selectivity_params.savepath, 0);
        
        %decide which contexts to use to define significant neurons
        if contains(data_type, 'sound')
            mod_params.data_type = 'sounds';
            %separate sig cells based on threshold (and single side or not)
            [current_sig_cells,switching_cells] = get_thresholded_sig_cells_simple( mod_params, mod_indexm, sig_mod_boot);
            sig_cells = get_significant_neurons(current_sig_cells, mod_indexm, 'union'); %union of active and passive
        else
            mod_params.data_type = 'opto';
            %separate sig cells based on threshold (and single side or not)
            [current_sig_cells,switching_cells] = get_thresholded_sig_cells_simple( mod_params, mod_indexm2, sig_mod_boot); %using mod_indexm2 because using prepost instead of ctrl for opto
            sig_cells = get_significant_neurons(current_sig_cells, mod_indexm, 'spont');
        end
        
        %separate neurons into left/right/non selective based on their
        %selecvitiy index (currently using .1 as threshold)
        [sel_by_dataset, sel_results] = analyze_selectivity_pools(selectivity_indexm, mod_indexm, mod_index_results, selectivity_index_results ,sig_cells', all_celltypes, params);
        
        % Plot modulation indices for each pool
        [sel_results.both.flagged_neurons, sel_results.both.scatter_stats] = generate_selectivity_pool_plots(sel_results, selectivity_indexm,mod_index_results, avg_results, all_celltypes, sig_cells, params, selectivity_params.savepath, varargin);
        selectivity_results_all{i} = sel_results;
        selectivity_results_by_dataset_all{i} = sel_by_dataset;

        %plot switching cells (switch modulation between contexts)
        %heatmap separated by selectivity
        if contains(data_type, 'sound')
            [~, sel_results_switch] = analyze_selectivity_pools(selectivity_indexm, mod_indexm, mod_index_results, selectivity_index_results ,switching_cells, all_celltypes, params);
            plot_selectivity_comparison(sel_results_switch, [selectivity_params.savepath '/switching_cells/']); 
        end
    end 

end
