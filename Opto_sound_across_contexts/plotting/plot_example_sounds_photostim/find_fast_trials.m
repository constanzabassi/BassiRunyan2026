function fast_trials_per_dataset = find_fast_trials(imaging_st,info,performance,time_to_include)

%do two seconds before
fast_trials_per_dataset = {};
for dataset = 1:length(imaging_st)
    dataset
    alignment_info = load(strcat(info.server{dataset}, '\Connie\ProcessedData\', info.mouse_date{dataset} ,'\alignment_info.mat')).alignment_info;
    parts = regexp(info.mouse_date{dataset}, '[\\/]', 'split');
    start_time = alignment_info(1).sync_sampling_rate*time_to_include(1);
    end_time = alignment_info(1).sync_sampling_rate*time_to_include(2);


    empty_trials = find(cellfun(@isempty,{imaging_st{1,dataset}.good_trial}));
    good_trials =  setdiff(1:length(imaging_st{1,dataset}),empty_trials); %only trials with all imaging data considered!
    imaging_array = [imaging_st{1,dataset}(:).virmen_trial_info];
    imaging_array_info =  [imaging_st{1,dataset}(:).movement_in_imaging_time];

    if ~isempty(performance)
        
        [time,fast_trial] = min(performance(dataset).turn_onset_opto);
        true_fast_trial = good_trials(performance(dataset).trial_ids_opto(fast_trial));

        %get trial info
        file_id = imaging_st{1,dataset}(true_fast_trial).file_num;
        name_file = alignment_info(file_id).sync_id;
        sound_onset = find(imaging_array_info(fast_trial).stimulus,1,'first');
%         trial_frames_relative_to_pclamp = [alignment_info(file_id).frame_times(imaging_st{1, dataset}(true_fast_trial).frame_id(1)),alignment_info(file_id).frame_times(imaging_st{1, dataset}(true_fast_trial).frame_id(end))];
        trial_frames_relative_to_pclamp = [alignment_info(file_id).frame_times(imaging_st{1, dataset}(true_fast_trial).frame_id(sound_onset))-start_time,alignment_info(file_id).frame_times(imaging_st{1, dataset}(true_fast_trial).frame_id(sound_onset))+end_time];


        fast_trials_per_dataset{dataset}.file_name = name_file;
        fast_trials_per_dataset{dataset}.file_times = trial_frames_relative_to_pclamp;
        fast_trials_per_dataset{dataset}.trial_id_true = true_fast_trial;
        fast_trials_per_dataset{dataset}.time = time;
        fast_trials_per_dataset{dataset}.name = parts{1};
        fast_trials_per_dataset{dataset}.date = parts{2};
        fast_trials_per_dataset{dataset}.server = info.server{dataset};
       

    else %find the onset of the sounds
        %find passive folders
        passive_folders = find(cellfun(@(x) contains(x,'passive'), {alignment_info(:).sync_id}));
        fast_trials_per_dataset{dataset}.file_name = alignment_info(passive_folders(1)).sync_id;
        %find first left trial
        left_trials_and_opto = find([imaging_array.condition]== 2 & [imaging_array.is_stim_trial]== 1);
        true_fast_trial = left_trials_and_opto(2); %getting the 2nd one in case I didnt image the first
        frame_sum = length([alignment_info(1:passive_folders(1)-1).frame_times]);
%         trial_frames_relative_to_pclamp = [alignment_info(passive_folders(1)).frame_times(imaging_st{1, dataset}(true_fast_trial).frame_id(1)-frame_sum),alignment_info(passive_folders(1)).frame_times(imaging_st{1, dataset}(true_fast_trial).frame_id(end)-frame_sum)];
        trial_frames_relative_to_pclamp = [alignment_info(passive_folders(1)).frame_times(imaging_st{1, dataset}(true_fast_trial).frame_id(7)-frame_sum)-start_time,alignment_info(passive_folders(1)).frame_times(imaging_st{1, dataset}(true_fast_trial).frame_id(7)-frame_sum)+end_time];

        fast_trials_per_dataset{dataset}.file_times = trial_frames_relative_to_pclamp;
        fast_trials_per_dataset{dataset}.trial_id_true = true_fast_trial;
        fast_trials_per_dataset{dataset}.time = nan;
        fast_trials_per_dataset{dataset}.name = parts{1};
        fast_trials_per_dataset{dataset}.date = parts{2};
        fast_trials_per_dataset{dataset}.server = info.server{dataset};
    end

    % get spont
    spont_folders = find(cellfun(@(x) contains(x,'_stim'), {alignment_info(:).sync_id}));
    fast_trials_per_dataset{dataset}.file_name_spont = alignment_info(spont_folders(1)).sync_id;
    %find first left trial
    trial_frames_relative_to_pclamp = [alignment_info(spont_folders(1)).frame_times(alignment_info(spont_folders(1)).bad_frames(3))-start_time,alignment_info(spont_folders(1)).frame_times(alignment_info(spont_folders(1)).bad_frames(3))+end_time];

    fast_trials_per_dataset{dataset}.file_times_spont = trial_frames_relative_to_pclamp;


end