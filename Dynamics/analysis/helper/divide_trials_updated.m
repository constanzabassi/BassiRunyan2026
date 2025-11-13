%fieldss = fieldnames(ex_imaging(1).virmen_trial_info);
%field_to_separate = {fields{2:3}};

function [all_conditions, condition_array] = divide_trials_updated (imaging,fields_to_separate)
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!

condition_array = [];
count = 0;
for t = 1:length(good_trials)
    count = count+1;

    condition_array(count,1) = good_trials(t); %index of good trials

    for f = 1:length(fields_to_separate)  
        condition_array(count,f+1) = imaging(good_trials(t)).virmen_trial_info.(fields_to_separate{f}); %f+1 bc first column is always the good trials

        %For now binarize stimuli: Convert stimuli to left (odd) or right (even)! (1 or 0)
        if strcmp(fields_to_separate{f},'condition')
            condition_array(count,f+1) = rem(condition_array(count,f+1),2);
        end

    end
    
end

%find trials that match each condtion
num_conditions = size(condition_array, 2) -1; % Number of conditions

% Generate all possible combinations of conditions
all_combinations = dec2bin(0:(2^num_conditions - 1)) - '0';

% Initialize a cell array to store matching trials for each combination
all_conditions = cell(size(all_combinations, 1), 2);


% Find trials for each combination of conditions
for i = 1:size(all_combinations, 1)
    condition_values = all_combinations(i, :);

        
    % data: Your matrix/array where rows represent trials and columns represent conditions
    % condition_values: A vector representing the condition values that can occur to check for each column
    
    % Get labels for the current combination of conditions
    labels = get_condition_labels_updated(condition_values,fields_to_separate);

    % find condition that matches each trial
    matching_trials = (condition_array(:, 2:end) == condition_values);

    %add them up- if it's equal to the condition the sum should equal the
    %number of conditions 
    sum_matching_trials = sum(matching_trials,2);

    all_conditions{i,1} = find(sum_matching_trials == num_conditions);
    all_conditions{i,2} = {condition_values};
    all_conditions{i,3} = labels;
end

