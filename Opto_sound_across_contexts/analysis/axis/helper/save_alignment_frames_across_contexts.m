function selected_frames = save_alignment_frames_across_contexts(frames_for_mean, test_trials_all,savepath)

%load alignment frames struc size datasets that has .opto and .ctrl pooled
%(trials x frames)
%test_trials_all has test trials pooled across folds (relative to
%imaging_stucture trial indexing!) for active context - concatenated
%CONTROL THEN STIM!!


%across contexts!
load('V:\Connie\results\opto_sound_2025\context\data_info\alignment_frames.mat');
all_trial_info = load('V:\Connie\results\opto_sound_2025\context\sound_info\active_all_trial_info_sounds.mat').all_trial_info_sounds;
% all_trial_info_pass = load('V:\Connie\results\opto_sound_2025\context\sound_info\passive_all_trial_info_sounds.mat').all_trial_info_sounds;

selected_frames = {};
for current_dataset = 1:length(test_trials_all)
    %load trial IDs
    all_ctrl_trials = [all_trial_info(current_dataset).ctrl(:).trial_id]; %relative to imaging structure alignment
    all_stim_trials = [all_trial_info(current_dataset).opto(:).trial_id];
    all_ctrl_trials_relative_stim = [all_trial_info(current_dataset).ctrl(:).matched_id]; %relative to stim/sound1 alignment
    all_stim_trials_relative_stim = [all_trial_info(current_dataset).opto(:).matched_id];

    % concatenate CONTROL then STIM!
    all_trials = [all_ctrl_trials,all_stim_trials];
%     all_trials_relative_to_stim = [all_ctrl_trials_relative_stim,all_stim_trials_relative_stim];
    %do the same for the imaging structures they should match in size!
    all_data = [alignment_frames{1, current_dataset}.ctrl(all_ctrl_trials_relative_stim,:);alignment_frames{1, current_dataset}.opto(all_stim_trials_relative_stim,:)];

    %get the matching trial ids!
    [~, loc] = ismember(test_trials_all{1,current_dataset},all_trials);
    
    % extract frames
    selected_frames{current_dataset} = all_data(loc, frames_for_mean);

end

save(fullfile('W:\Connie\Analysis\engagement\','selected_frames.mat'),'selected_frames');
