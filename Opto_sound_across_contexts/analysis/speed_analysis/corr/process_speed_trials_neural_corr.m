function [corr_left_neuron_speed, corr_right_neuron_speed, p_values_left, p_values_right] = process_speed_trials_neural_corr(chosen_mice, current_dataset, mouse_date, vel_type, mouse_vel, dff_st, frames_before, frames_after, trials_left, trials_right, function_params, save_data_directory)
    
    % LOAD ALIGNED RUNNING DATA
    if strcmp(vel_type, 'roll')
        field_name = [function_params.field_name_vel '_roll'];
    elseif strcmp(vel_type, 'pitch')
        field_name = [function_params.field_name_vel '_pitch'];
    else
        field_name = function_params.field_name_vel;
    end
    
    vel_aligned_left = mouse_vel(current_dataset).(field_name)(trials_left, [frames_before,frames_after]);
    vel_aligned_right = mouse_vel(current_dataset).(field_name)(trials_right, [frames_before,frames_after]);
    
    if function_params.abs == 1
        vel_aligned_left = abs(vel_aligned_left);
        vel_aligned_right = abs(vel_aligned_right);
    end
    
    % LOAD ALIGNED NEURAL DATA
    field_name_neural = function_params.field_name_neural;
    aligned_neural_data = dff_st{1, current_dataset}.(field_name_neural);
    data_norm = normalize_aligned_data(aligned_neural_data, 'zscore', []);

    %get specified cell type
    if strcmp(function_params.chosen_cells, 'all')
        cellCount = size(dff_st{1,current_dataset}.(field_name_neural),2); %loading from control which does not have opto so only sounds!
        mod_cells = 1:cellCount;
        sig_mod_boot{1,current_dataset} = mod_cells;
    elseif strcmp(function_params.chosen_cells, 'sig')
        sig_mod_boot{1,current_dataset} = combined_thres{1,current_dataset};
    elseif strcmp(function_params.chosen_cells, 'som')
        sig_mod_boot{1,current_dataset} = function_params.current_celltypes.som_cells;
    elseif strcmp(function_params.chosen_cells, 'pv')
        sig_mod_boot{1,current_dataset} = function_params.current_celltypes.pv_cells;
    elseif strcmp(function_params.chosen_cells, 'pyr')
        sig_mod_boot{1,current_dataset} = function_params.current_celltypes.pyr_cells;
    end
    
    left_matrix = data_norm(trials_left, sig_mod_boot{1,current_dataset}, [frames_before,frames_after]);
    right_matrix = data_norm(trials_right, sig_mod_boot{1,current_dataset}, [frames_before,frames_after]);
    
%     % Binning option
%     if function_params.corr_bins > 0
%         bin_size = function_params.corr_bins;
%         
%         % Bin speed data
%         vel_aligned_left = movmean(vel_aligned_left, bin_size, 2, 'Endpoints', 'discard');
%         vel_aligned_right = movmean(vel_aligned_right, bin_size, 2, 'Endpoints', 'discard');
%         
%         % Bin neural data
%         left_matrix = movmean(left_matrix, bin_size, 3, 'Endpoints', 'discard');
%         right_matrix = movmean(right_matrix, bin_size, 3, 'Endpoints', 'discard');
%     end

% Binning option
    if function_params.corr_bins > 0
        bin_size = function_params.corr_bins;
    
        if function_params.nonoverlap_bins == 1
            % Non-overlapping binning
            num_bins = floor(size(vel_aligned_left, 2) / bin_size);
            
            % Reshape and take mean for speed data
            vel_aligned_left = squeeze(mean(reshape(vel_aligned_left(:, 1:num_bins * bin_size), [], bin_size, num_bins), 2));
            vel_aligned_right = squeeze(mean(reshape(vel_aligned_right(:, 1:num_bins * bin_size), [], bin_size, num_bins), 2));
            
            % Reshape and take mean for neural data
            left_matrix = squeeze(mean(reshape(left_matrix(:, :, 1:num_bins * bin_size), [], size(left_matrix, 2), bin_size, num_bins), 3));
            right_matrix = squeeze(mean(reshape(right_matrix(:, :, 1:num_bins * bin_size), [], size(right_matrix, 2), bin_size, num_bins), 3));
            
        else
            % Overlapping binning using movmean
            vel_aligned_left = movmean(vel_aligned_left, bin_size, 2, 'Endpoints', 'discard');
            vel_aligned_right = movmean(vel_aligned_right, bin_size, 2, 'Endpoints', 'discard');
            
            left_matrix = movmean(left_matrix, bin_size, 3, 'Endpoints', 'discard');
            right_matrix = movmean(right_matrix, bin_size, 3, 'Endpoints', 'discard');
        end
    end

    
    % CONCATENATE TRIALS HORIZONTALLY
    left_concatenated_speed = reshape(vel_aligned_left', 1, []);
    right_concatenated_speed = reshape(vel_aligned_right', 1, []);
    
    left_concatenated_neural = reshape(permute(left_matrix, [3, 1, 2]), [], size(left_matrix, 2));
    right_concatenated_neural = reshape(permute(right_matrix, [3, 1, 2]), [], size(right_matrix, 2));
    
    % COMPUTE PEARSON CORRELATIONS
    corr_left_neuron_speed = zeros(1, size(left_concatenated_neural, 2));
    corr_right_neuron_speed = zeros(1, size(right_concatenated_neural, 2));
    p_values_left = zeros(1, size(left_concatenated_neural, 2));
    p_values_right = zeros(1, size(right_concatenated_neural, 2));
    
    for neuron = 1:size(left_concatenated_neural, 2)
        [r, p] = corrcoef(left_concatenated_speed', left_concatenated_neural(:, neuron));
        corr_left_neuron_speed(neuron) = r(1, 2);
        p_values_left(neuron) = p(1, 2);
        
        [r, p] = corrcoef(right_concatenated_speed', right_concatenated_neural(:, neuron));
        corr_right_neuron_speed(neuron) = r(1, 2);
        p_values_right(neuron) = p(1, 2);
    end
    
    % SAVE DATA IF NEEDED
    if ~isempty(save_data_directory)
        save(fullfile(save_data_directory, sprintf('%s_%s_speed_corr.mat', chosen_mice{current_dataset}, mouse_date{current_dataset})), 'corr_left_neuron_speed', 'corr_right_neuron_speed', 'p_values_left', 'p_values_right');
    end
end

    


   