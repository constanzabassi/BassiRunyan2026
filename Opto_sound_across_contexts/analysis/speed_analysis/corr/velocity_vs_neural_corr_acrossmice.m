function [mouse_corr_stats, trial_indices_right_all, trial_indices_left_all] = velocity_vs_neural_corr_acrossmice(chosen_mice, mouse_date, server, mouse_vel, dff_st, frames_before, frames_after, function_params,trials, save_data_directory)
    % Initialize output variables
    mouse_corr_stats = struct(); %cell(length(chosen_mice), 4);
    trial_indices_right_all = cell(length(chosen_mice), 1);
    trial_indices_left_all = cell(length(chosen_mice), 1);
    
    % Load cell type IDs if needed
    load('V:\Connie\results\opto_2024\context\data_info\all_celltypes.mat');

    %Process across vel types
    for vel_types_index = 1:length(function_params.vel_types)
        current_vel_type = function_params.vel_types{vel_types_index};
        %Process across contexts
        for context_idx = function_params.context
            current_context = function_params.context(context_idx);
        
            % Process each mouse
            for current_dataset_index = 1:length(chosen_mice)
                current_dataset_index
    
                % Get mouse info
                current_mouse = chosen_mice(current_dataset_index);
                current_mouse_date = mouse_date{current_dataset_index};
                current_server = server{current_dataset_index};
                
                % Get current dataset's cell types
                function_params.current_celltypes = all_celltypes{1, current_dataset_index};
                
                % Get trial indices based on context
                [trials_left, trials_right] = get_trial_indices_contexts(trials, current_dataset_index, current_context);
                
                % Store trial indices
                trial_indices_left_all{current_dataset_index} = trials_left;
                trial_indices_right_all{current_dataset_index} = trials_right;
                
                % Process correlations
                [corr_left, corr_right, p_left, p_right] = process_speed_trials_neural_corr(...
                    chosen_mice, current_dataset_index, mouse_date, current_vel_type, mouse_vel, dff_st, ...
                    frames_before, frames_after, trials_left, trials_right, function_params, save_data_directory);
                
%                 % Store correlation stats
%                 mouse_corr_stats{vel_types_index,current_context,current_dataset, 1} = corr_left;
                % Store correlation stats
                mouse_corr_stats.(current_vel_type){current_dataset_index, context_idx, 1} = corr_left;
                mouse_corr_stats.(current_vel_type){current_dataset_index, context_idx, 2} = corr_right;
                mouse_corr_stats.(current_vel_type){current_dataset_index, context_idx, 3} = p_left;
                mouse_corr_stats.(current_vel_type){current_dataset_index, context_idx, 4} = p_right;

            end
        end
    end
end
