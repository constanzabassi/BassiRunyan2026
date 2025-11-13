function combined_string_label = get_condition_labels_updated(condition_values,fields_to_separate)
    % Map condition values to labels
    labels = cell(1, numel(condition_values));

    % Define labels based on condition values
    for i = 1:numel(condition_values)
        if strcmp(fields_to_separate{i},'correct')
            if condition_values(i) == 1
                labels{i} = "Correct" ;
            else
                labels{i} = "Incorrect";
            end
        elseif strcmp(fields_to_separate{i},'left_turn')
            if condition_values(i) == 1
                labels{i} = "Left Turn" ;
            else
                labels{i} = "Right Turn";
            end
        elseif strcmp(fields_to_separate{i},'condition')
            if condition_values(i) == 1
                labels{i} = "Left" ;
            else
                labels{i} = "Right";
            end
        
        elseif strcmp(fields_to_separate{i},'is_stim_trial')
            if condition_values(i) == 1
                labels{i} = "Stim" ;
            else
                labels{i} = "Control";
            end
        end
    end
    % Convert individual strings into a single concatenated string
    combined_string_label = strjoin(string(labels), '/');

end