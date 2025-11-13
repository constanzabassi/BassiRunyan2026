function imaging_spk = make_imaging_from_trials(condition_array_trials,original_imaging)

for trial = 1:length(condition_array_trials)
    tr = condition_array_trials(trial,1);
    imaging_spk(trial) = original_imaging(tr);
end