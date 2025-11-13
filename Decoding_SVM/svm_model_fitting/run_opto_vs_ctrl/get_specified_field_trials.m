function selected_trials = get_specified_field_trials (current_mouse,active_passive, imaging,selected_field_num)
% fieldss = fieldnames(imaging(1).virmen_trial_info);
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
% virmen_trial_info = [imaging(good_trials).virmen_trial_info];

% would work except that control trials vs no control are not distinguished
% here
% selected_trials =  find([virmen_trial_info.(fieldss{selected_field_num(1)})]==selected_field_num(2)) ;

%use this which used the photostim signal to determine control vs sound
%only trials!
if active_passive == 1
    load('V:\Connie\results\opto_sound_2025\context\sound_info\active_all_trial_info_sounds.mat');
else
    load('V:\Connie\results\opto_sound_2025\context\sound_info\passive_all_trial_info_sounds.mat');
end

if selected_field_num == 0
    selected_trials = [all_trial_info_sounds(current_mouse).ctrl.trial_id]; %find(ismember(good_trials,[all_trial_info_sounds(current_mouse).ctrl.trial_id]));
else
    selected_trials = [all_trial_info_sounds(current_mouse).opto.trial_id]; %find(ismember(good_trials,[all_trial_info_sounds(current_mouse).opto.trial_id]));
end
