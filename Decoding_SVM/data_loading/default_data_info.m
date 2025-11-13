function [current_mice,onset_id, active_events, passive_events] = default_data_info(task_event_type)
    % Default event times
    passive_events = [7, 39, 71];
    active_events = [7, 39, 71, 132, 146];

    % Default current_mice based on task_event_type
    switch lower(task_event_type)
        case 'sound_category'
            current_mice = setdiff(1:25, [9, 23]);
            onset_id = 1;
        case 'choice'
            current_mice = setdiff(1:25, [9, 23]);
            onset_id = 4;
        case 'photostim'
            current_mice = setdiff(1:25, [10, 12, 6, 25]);
            onset_id = 1;
        case 'outcome'
            current_mice = setdiff(1:25, [3, 8, 9, 21, 22, 23]);
            onset_id = 5;
        otherwise
            error('Unknown task_event_type: %s', task_event_type);
    end
end

