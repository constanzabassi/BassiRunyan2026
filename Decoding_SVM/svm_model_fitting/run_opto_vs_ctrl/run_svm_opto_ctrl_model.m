%classify data
%load info
load('V:/Connie/results/opto_2024/context/data_info/info.mat');
% % get inputs for classifier
% alignment.single_event = 1; %align to single event == 1 or 1:6 events (concatenated) not 1

alignment = struct();

alignment.active_passive = 1; %1 = active, 2 = passive
alignment.data_type = 'deconv';
if alignment.active_passive == 2
    alignment.active_passive = 2; %1 for ACTIVE || 2 for PASSIVE
    alignment.type = 'stimulus'; %aligns to 3 sounds
    alignment.number = 1:3;
    alignment.events = 1:3;
    mdl_param.fields_to_balance = [3]; %{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4

else
    alignment.active_passive = 1; %1 for ACTIVE || 2 for PASSIVE
    alignment.type = 'pre'; %aligns to all (but 3 sounds are equally aligned as passive)
    alignment.number = 1:5;
    alignment.events = 1:5;
    mdl_param.fields_to_balance = [2,3]; %{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4

end

%mdl parameter info
mdl_param.bin = 3; %bin size in terms of frames
mdl_param.field_to_predict = 3; %{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4
mdl_param.num_iterations = 100; %number of times to subsample
mdl_param.data_type = alignment.data_type;

%use alignment info to get this number!

if alignment.active_passive == 2
    load('V:/Connie/ProcessedData/HA11-1R/2023-05-05/passive/imaging.mat')
    [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging,30,alignment.active_passive);
else
    load('V:/Connie/ProcessedData/HA11-1R/2023-05-05/VR/imaging.mat')
    [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging,30);
end

event_onset = determine_onsets(left_padding,right_padding,alignment.events);
 if mdl_param.field_to_predict == 1
    event_onset_id = 5;
elseif mdl_param.field_to_predict == 2
    event_onset_id = 4;
elseif mdl_param.field_to_predict == 3
    event_onset_id = 1;
elseif mdl_param.field_to_predict == 4
    event_onset_id = 1;
 end
 mdl_param.event_onset = event_onset(event_onset_id);
 if alignment.active_passive == 2
     frame_length = event_onset(3)+right_padding(3)-mdl_param.event_onset;%150 outcome?;%for choice; %used to be 281 with update is 260
 else
    frame_length = event_onset(5)+right_padding(5)-mdl_param.event_onset;%150 outcome?;%for choice; %used to be 281 with update is 260
 end
%updated event onsets! 7 42 77 141 155 180

mdl_param.frames_around = -mdl_param.event_onset+1:frame_length-mdl_param.bin+1;%-mdl_param.event_onset+1:mdl_param.event_onset-51 == -140:90; %frames around onset 
mdl_param.binns = mdl_param.frames_around(1):mdl_param.bin:mdl_param.frames_around(end); %bins in terms of event onset
%updated event onsets! 7 42 77 141 155 180
    

load('V:\Connie\results\opto_2024\context\data_info/all_celltypes.mat'); %datasets organized based on info in the same folder!

info.savepath = 'W:\Connie\results\SVM';

% load minimum set trials so they are the same across contexts/conditions
load("dataset_with_enough_trials.mat");
load("smallest_set_size.mat")
info.datasets_to_model = setdiff(dataset_with_enough_trials,25); %only doing svm for datasets that have at least 4 trials per balanced condition (25 is CONTROL MOUSE!)
info.set_size = smallest_set_size;
%% RUN CLASSIFIER
[svm] = run_classifier_separating_opto_trials(all_celltypes,mdl_param, alignment,info,0); %last is whether to align to onset of single event

%% make quick plots



