function valid_trials = find_relevant_frames(alignment_frames,bad_frames)
valid_trials = [];
for trial = 1:length(alignment_frames)
    valid_trials = [valid_trials,find(abs(alignment_frames(1,trial) - bad_frames(:,1)) < 6)];
end