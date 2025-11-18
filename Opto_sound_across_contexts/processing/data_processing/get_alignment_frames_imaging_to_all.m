function updated_frames = get_alignment_frames_imaging_to_all(imaging,alignment_frames,alignment_info)
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
current_file_lengths = [0,cumsum(cellfun(@(x) length(x), {alignment_info.frame_times}))];
updated_frames = zeros(size(alignment_frames));
for trial = 1:length(good_trials)
    current_frames = imaging(good_trials(trial)).frame_id(1)+current_file_lengths(imaging(good_trials(trial)).file_num)-1;
    updated_frames(:,trial) = alignment_frames(:,trial)+current_frames;
end