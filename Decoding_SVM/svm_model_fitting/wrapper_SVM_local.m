function wrapper_SVM_local(current_mouse,save_string_glm,save_string_imaging,decoding_type,varargin)
%decoding_type; %{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4
%set-up paths!
load('V:\Connie\results\opto_2024\context\data_info/info.mat'); %datasets organized based on info in the same folder!

addpath(genpath('C:\Code\Github\behavior-analysis2\classifier')) %add all functions used in this code to the path

current_mouse = double(current_mouse) +1; %adapt to MATLAB indexing!
decoding_type = double(decoding_type);
dataPath = strcat(num2str(info.serverid{1,current_mouse}), '\Connie/ProcessedData/',num2str(info.mouse_date{1,current_mouse}),'/',save_string_glm,'/');
addpath(genpath(dataPath));

% Alignment settings
alignment = struct();
alignment.data_type = 'deconv';
if strcmp(save_string_imaging,"passive")
    alignment.active_passive = 2; %1 for ACTIVE || 2 for PASSIVE
    alignment.type = 'stimulus'; %aligns to 3 sounds
    alignment.number = 1:3;
    alignment.events = 1:3;
else
    alignment.active_passive = 1; %1 for ACTIVE || 2 for PASSIVE
    alignment.type = 'pre'; %aligns to all (but 3 sounds are equally aligned as passive)
    alignment.number = 1:5;
    alignment.events = 1:5;
end
alignment.single_event = 0;
mdl_param.bin = 3; %bin size in terms of frames
% mdl_param.fields_to_balance = [2,3]; %{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4
mdl_param.field_to_predict = decoding_type; %{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4
mdl_param.num_iterations = 10; %number of times to subsample (normally 50)
mdl_param.data_type = alignment.data_type;


alignment.single_balance = 1; %default to one!

%use alignment info to get this number!
if alignment.single_event == 1
    load('V:/Connie/ProcessedData/HA11-1R/2023-05-05/passive/imaging.mat')
    [~,~,left_padding,right_padding] = find_align_info (imaging,30,1);

    mdl_param.event_onset = left_padding(alignment.events)+1;%141; %relative to aligned data this are the events in aligned data:(7,42,77,141,176,201)
    mdl_param.frames_around = -left_padding(alignment.events):right_padding(alignment.events);
    mdl_param.binns = -left_padding(alignment.events):mdl_param.bin:right_padding(alignment.events); %bins in terms of event onset

else

    %use alignment from glmdecoder code!!!
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

    load('V:\Connie\results\opto_2024\context\data_info/all_celltypes.mat'); %datasets organized based on info in the same folder!

    %model_params will be of the last dataset run
    [output,output_shuff, model_params] = run_classifier_glm_inputs_local(current_mouse , save_string_glm,all_celltypes,mdl_param, alignment,info);
%     [output,output_shuff] = run_classifier_glm_inputs_local_test(current_mouse , save_string_glm,all_celltypes,mdl_param, alignment,info);

end
