function [data1_fold_avg, data2_fold_avg] = compute_fold_averages(data_fold,data2_fold, response_range, mod_type)
%compute average across frames for data!

% Compute averages based on mod_type
if (strcmp(mod_type, 'prepost') || strcmp(mod_type,  'prepost_abs')) || strcmp(mod_type,  'prepost_num') && length(response_range) > 1 
    data1_fold_avg = mean(data_fold(:, :, response_range{1}), 3); %use first only (assuming stim)
    data2_fold_avg = mean(data_fold(:, :, response_range{2}), 3); %use first only (assuming stim)
elseif strcmp(mod_type, 'prepost_sound') || strcmp(mod_type, 'prepost_sound_num') && length(response_range) > 1
    data1_fold_avg = mean(data2_fold(:, :, response_range{1}), 3); %use first only (assuming ctrl) for sounds
    data2_fold_avg = mean(data2_fold(:, :, response_range{2}), 3); %use first only (assuming ctrl) for sounds
elseif strcmp(mod_type, 'prepost_ctrl') || strcmp(mod_type, 'prepost_ctrl_abs') || strcmp(mod_type,'signed_ctrl')
    % Ensure your data is in double precision
    data_subset1 = double(data_fold);
    data_subset2 = double(data2_fold);
    data1_fold_avg = mean(data_fold(:, :, response_range{1}), 3) - mean(data_fold(:, :, response_range{2}), 3); %difference of values pre-post
    data2_fold_avg = mean(data2_fold(:, :, response_range{1}), 3)- mean(data2_fold(:, :, response_range{2}), 3);
elseif strcmp(mod_type,'pre_engagement') || strcmp(mod_type,'pre_engagement_num')
    data1_fold_avg = mean(data_fold(:, :, response_range{2}), 3); %take mean across pre stim period!
    data2_fold_avg = mean(data2_fold(:, :, response_range{2}), 3);
else
    data1_fold_avg = mean(data_fold(:, :, response_range{1}), 3);
    data2_fold_avg = mean(data2_fold(:, :, response_range{1}), 3);
end
end