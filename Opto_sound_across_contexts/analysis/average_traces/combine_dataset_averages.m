function combined_results = combine_dataset_averages(results_by_dataset,params)
    % Combines results across datasets maintaining same structure as individual datasets
    % Output: combined_results{1,context}.condition structure
    
    [nDatasets, nContexts] = size(results_by_dataset);
    combined_results = cell(1, nContexts);
    
    for context = 1:nContexts
        combined_results{1,context} = struct();
        
        if strcmpi(params.mode, 'separate')
            if context == 3
            % Spontaneous context uses stim/ctrl conditions
                conditions = {'stim', 'ctrl'};
            else
                % Active/Passive contexts use left/right conditions
                conditions = {'left', 'right'};
            end
            
            for cond = 1:length(conditions)
                cond_label = conditions{cond};
                % Initialize arrays
                all_neuron_means = [];
                all_neuron_sems = [];
                
                % Concatenate across datasets
                for dataset = 1:nDatasets
                    curr_data = results_by_dataset{dataset,context}.(cond_label);
                    all_neuron_means = [all_neuron_means; curr_data.neuron_mean];
                    all_neuron_sems = [all_neuron_sems; curr_data.neuron_sem];
                end
                
                % Store in same structure as individual datasets
                combined_results{1,context}.(cond_label).neuron_mean = all_neuron_means;
                combined_results{1,context}.(cond_label).neuron_sem = all_neuron_sems;
                combined_results{1,context}.(cond_label).pop_mean = ...
                    mean(all_neuron_means, 1);
                combined_results{1,context}.(cond_label).pop_sem = ...
                    std(all_neuron_means, [], 1) / sqrt(size(all_neuron_means, 1));
            end
        else
            % For pooled mode
            all_neuron_means = [];
            all_neuron_sems = [];
            
            for dataset = 1:nDatasets
                curr_data = results_by_dataset{dataset,context};
                all_neuron_means = [all_neuron_means; curr_data.neuron_mean];
                all_neuron_sems = [all_neuron_sems; curr_data.neuron_sem];
            end
            
            combined_results{1,context}.neuron_mean = all_neuron_means;
            combined_results{1,context}.neuron_sem = all_neuron_sems;
            combined_results{1,context}.pop_mean = mean(all_neuron_means, 1);
            combined_results{1,context}.pop_sem = ...
                std(all_neuron_means, [], 1) / sqrt(size(all_neuron_means, 1));
        end
    end
end