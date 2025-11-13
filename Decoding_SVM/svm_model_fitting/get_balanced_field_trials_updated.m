function [selected_trials, balanced_indices] = get_balanced_field_trials(imaging, selected_field_num, varargin)
    fieldss = fieldnames(imaging(1).virmen_trial_info);
    empty_trials = find(cellfun(@isempty, {imaging.good_trial}));
    good_trials = setdiff(1:length(imaging), empty_trials); % only trials with all imaging data considered!
    selected_trials = false(1, length(good_trials));
    virmen_trial_info = [imaging(good_trials).virmen_trial_info];
    if length(selected_field_num) == 1
        condition = [virmen_trial_info.(fieldss{selected_field_num})];
        % Adjust condition values if field is 'condition' or field number 3
        if strcmp(fieldss{selected_field_num}, 'condition') || selected_field_num == 3
            condition = condition - 1; % Convert 1s and 2s to 0s and 1s
        end
        unique_cond = unique(condition);
        conds = cell(length(unique_cond), 1);
        for c = 1:length(unique_cond)
            conds{c} = find(condition == unique_cond(c));
        end
        % Ensure that each group is equally represented in the training trials
        if nargin > 2
            smallest_set_size = varargin{1,1};
        else
            smallest_set_size = min(cellfun(@length, conds));
        end
        balanced_indices = cell(length(unique_cond), 1);
        for c = 1:length(unique_cond)
            balanced_indices{c} = randsample(conds{c}, smallest_set_size);
            selected_trials(balanced_indices{c}) = true;
        end
    else
        conditions = cell(1, length(selected_field_num));
        for i = 1:length(selected_field_num)
            conditions{i} = [virmen_trial_info.(fieldss{selected_field_num(i)})];
            % Adjust condition values if field is 'condition' or field number 3
            if strcmp(fieldss{selected_field_num(i)}, 'condition') || selected_field_num(i) == 3
                conditions{i} = conditions{i} - 1; % Convert 1s and 2s to 0s and 1s
            end
        end
        % Extract unique combinations of condition values across the selected fields
        unique_comb = unique(cell2mat(conditions'), 'rows');
        % Initialize a cell array to store indices of trials that match each unique combination
        comb_conds = cell(size(unique_comb, 1), 1);
        % Loop over each unique combination of conditions
        for c = 1:size(unique_comb, 1)
            % Initialize a logical array to track trials that match the current combination
            conds_match = true(size(conditions{1}));  % All trials initially match
            % Loop over each condition within the current combination
            for i = 1:length(conditions);%size(unique_comb, 2)
                % Update the logical array to keep only trials that match the current condition
                conds_match = conds_match & (conditions{i} == unique_comb(c, i));
            end
            % Store the indices of trials that match the current combination
            comb_conds{c} = find(conds_match);
        end
        % Ensure that each group is equally represented in the training trials
        if nargin > 2
            smallest_set_size = varargin{1,1};
        else
            smallest_set_size = min(cellfun(@length, comb_conds));
        end
        balanced_indices = cell(size(unique_comb, 1), 1);
        for c = 1:size(unique_comb, 1)
            balanced_indices{c} = randsample(comb_conds{c}, smallest_set_size);
            selected_trials(balanced_indices{c}) = true;
        end
    end
end