function avg_speed_axis_data = organize_speed_cdf_data( ...
    mouse_vel_context, ...
    mouse_acc_context, ...
    mouse_vel_context_roll, ...
    mouse_vel_context_pitch, ...
    chosen_datasets, ...
    use_abs)

% OUTPUT FORMAT:
% avg_speed_axis_data{context, movement}
%
% movement:
% 1 = Pitch
% 2 = Roll
% 3 = Speed
% 4 = Acceleration

nContexts = size(mouse_vel_context,2);

avg_speed_axis_data = cell(nContexts,4);

for context = 1:nContexts

    pitch_vals = [];
    roll_vals = [];
    speed_vals = [];
    acc_vals = [];

    for dataset = chosen_datasets

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % COMBINE STIM + CTRL
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        speed_data = [ ...
            mouse_vel_context{dataset,context}.stim(:); ...
            mouse_vel_context{dataset,context}.ctrl(:)];

        acc_data = [ ...
            mouse_acc_context{dataset,context}.stim(:); ...
            mouse_acc_context{dataset,context}.ctrl(:)];

        roll_data = [ ...
            mouse_vel_context_roll{dataset,context}.stim(:); ...
            mouse_vel_context_roll{dataset,context}.ctrl(:)];

        pitch_data = [ ...
            mouse_vel_context_pitch{dataset,context}.stim(:); ...
            mouse_vel_context_pitch{dataset,context}.ctrl(:)];

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ABS OPTION
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if use_abs == 1
            speed_data = abs(speed_data);
            acc_data = abs(acc_data);
            roll_data = abs(roll_data);
            pitch_data = abs(pitch_data);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % DATASET AVERAGES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        speed_vals(end+1) = mean(speed_data,'omitnan');
        acc_vals(end+1) = mean(acc_data,'omitnan');
        roll_vals(end+1) = mean(roll_data,'omitnan');
        pitch_vals(end+1) = mean(pitch_data,'omitnan');

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % STORE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    avg_speed_axis_data{context,1} = pitch_vals;
    avg_speed_axis_data{context,2} = roll_vals;
    avg_speed_axis_data{context,3} = speed_vals;
    avg_speed_axis_data{context,4} = acc_vals;

end