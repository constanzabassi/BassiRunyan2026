function performance = get_opto_performance_simple(imaging_st,behav_param,alignment)
    for dataset_index = 1:length(imaging_st)
        dataset_index
        ex_imaging = imaging_st{1,dataset_index};
        [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
        [aligned_imaging,imaging_array,~] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
%         [selected_trials,~,~] = get_balanced_field_trials(ex_imaging,behav_param.fields_to_balance);

        [~, condition_array] = divide_trials_updated (ex_imaging,{'correct','left_turn','condition','is_stim_trial'});
%         trial_ids = find(selected_trials);
        trial_ids = 1:size(aligned_imaging,1);
        trial_ids_opto = trial_ids(find(condition_array(trial_ids,5)));
        trial_ids_ctrl = trial_ids(find(condition_array(trial_ids,5)==0));

        correct_or_no = condition_array(trial_ids,2);
        left_or_no = condition_array(trial_ids,3);
        turn_onsets = [imaging_array.turn_frame];
        performance(dataset_index).correct_all = sum(correct_or_no)/length(correct_or_no);
        performance(dataset_index).left_all = sum(left_or_no)/length(correct_or_no);
        performance(dataset_index).turn_onset_all = turn_onsets/30;

        performance(dataset_index).correct_opto = sum(condition_array(trial_ids_opto,2))/length(trial_ids_opto);
        performance(dataset_index).left_opto = sum(condition_array(trial_ids_opto,3))/length(trial_ids_opto);
        performance(dataset_index).correct_ctrl = sum(condition_array(trial_ids_ctrl,2))/length(trial_ids_ctrl);
        performance(dataset_index).left_ctrl = sum(condition_array(trial_ids_ctrl,3))/length(trial_ids_ctrl);
        performance(dataset_index).turn_onset_opto = turn_onsets(trial_ids_opto)/30;
        performance(dataset_index).turn_onset_ctrl = turn_onsets(trial_ids_ctrl)/30;

        %find mean measurements for other metrics including x/y velocity
        %and view angle changes!
        temp =[];
        temp2 =[];
        temp3 =[];
        for trial = trial_ids_opto
            current_trial = imaging_array(trial);
            temp = [temp,nanmean(current_trial.y_velocity(current_trial.maze_frames))];
            temp2 = [temp,nanmean(abs(current_trial.x_velocity(current_trial.maze_frames)))];
            temp3 = [temp,nanmean(abs(current_trial.view_angle(current_trial.maze_frames)))];
        end
        performance(dataset_index).y_vel = temp;
        performance(dataset_index).x_vel = temp2;
        performance(dataset_index).view_angle = temp3;

        temp =[];
        temp2 =[];
        temp3 =[];
        for trial = trial_ids_ctrl
            current_trial = imaging_array(trial);
            temp = [temp,nanmean(current_trial.y_velocity(current_trial.maze_frames))];
            temp2 = [temp,nanmean(abs(current_trial.x_velocity(current_trial.maze_frames)))];
            temp3 = [temp,nanmean(abs(current_trial.view_angle(current_trial.maze_frames)))];
        end
        performance(dataset_index).y_vel_ctrl = temp;
        performance(dataset_index).x_vel_ctrl = temp2;
        performance(dataset_index).view_angle_ctrl = temp3;

%         performance(m).y_vel = cellfun(@(x) nanmean(x),{imaging_array(trial_ids_opto).y_velocity});
%         performance(m).x_vel = cellfun(@(x) nanmean(abs(x)),{imaging_array(trial_ids_opto).x_velocity});

        performance(dataset_index).trial_ids_opto = trial_ids_opto;
        performance(dataset_index).trial_ids_ctrl = trial_ids_ctrl;
end