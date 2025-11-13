%load data!!
load('V:\Connie\results\passive\data_info\info.mat');
load('V:\Connie\results\passive\data_info\all_celltypes.mat');
info.server = info.serverid;

%%
%classify data

% get inputs for classifier
alignment.data_type = 'deconv';% 'dff', 'z_dff', else it's deconvolved
alignment.type = 'all'; %'reward','turn','stimulus','ITI'
alignment.events = [1:6]; %1:6 is all
alignment.single_event = 1:6; %align to single event == 1 or 1:6 events (concatenated) not 1
alignment.active_passive = 2;

%update savepath (was dpn
info.savepath = 'V:/Connie/results/task_decoding';
%mdl parameter info
mdl_param.bin = 3; %bin size in terms of frames
mdl_param.fields_to_balance = [2,3]; %{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4
mdl_param.field_to_predict = 3; %{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4
mdl_param.num_iterations = 50; %number of times to subsample
mdl_param.data_type = alignment.data_type;

%use alignment info to get this number!
if alignment.single_event == 1
    [~,~,left_padding,right_padding] = find_align_info (imaging_st{1,1},30,1);

    mdl_param.event_onset = left_padding(alignment.events)+1;%141; %relative to aligned data this are the events in aligned data:(7,42,77,141,176,201)
    mdl_param.frames_around = -left_padding(alignment.events):right_padding(alignment.events);
    mdl_param.binns = -left_padding(alignment.events):mdl_param.bin:right_padding(alignment.events); %bins in terms of event onset

else

    %use alignment from glmdecoder code!!!
    if alignment.active_passive == 2
        load('V:\Connie\ProcessedData\HA11-1R\2023-05-05\passive\imaging.mat')
        [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging,30,alignment.active_passive);
    else
        load('V:\Connie\ProcessedData\HA11-1R\2023-05-05\VR\imaging.mat')
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
    
    mdl_param.frames_around = -mdl_param.event_onset+1:(frame_length)-mdl_param.event_onset+1;%-mdl_param.event_onset+1:mdl_param.event_onset-51 == -140:90; %frames around onset 
    mdl_param.binns = mdl_param.frames_around(1):mdl_param.bin:mdl_param.frames_around(end); %bins in terms of event onset

end



plot_info.colors_celltype = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04 % red  
                            0 0 0.5]; %dark purple
plot_info.labels = {'PYR','SOM','PV','All'};

info.savestr = 'sounds_allaligned_50sub'; %how to save current run

%% RUN CLASSIFIER
[svm, svm_mat] = run_classifier_glm_inputs('GLM_3nmf_passive',all_celltypes,mdl_param, alignment,plot_info,info,alignment.single_event); %last is whether to align to onset of single event

%% plot weight distribution across celltypes for model run with all cells
%[betas] = compare_svm_weights(svm); %uses ce = 4 which is all cells to get betas
load('betas.mat');
load('svm_info.mat');
onset = find(histcounts(svm{1,1,4}.mdl_param.event_onset,svm{1,1,4}.mdl_param.binns+svm{1,1,4}.mdl_param.event_onset)); %gives onset bin of event

plot_dist_weights(onset, betas,all_celltypes,plot_info,mdl_param.data_type,svm_info,[1:3]);

save('betas','betas');

%% average across datasets
% 
% if alignment.single_event == 1
%     [~,~,left_padding,right_padding] = find_align_info (imaging_st{1,1},30,1);
% else
%     [~,~,left_padding,right_padding] = find_align_info (imaging_st{1,1},30);
% end

mdl_param.event_onset_true = determine_onsets(left_padding,right_padding,alignment.events);
event_onsets = find(histcounts(mdl_param.event_onset_true,mdl_param.binns+mdl_param.event_onset));

plot_svm_across_datasets(svm_mat,plot_info,event_onsets,mdl_param,[alignment.data_type '_' info.savestr],['V:/Connie/results/behavior/svm']);
%% bar plots of average across datasets
[~,~,left_padding,right_padding] = find_align_info (imaging_st{1,1},30,1);
mdl_param = all_model_outputs{1,1};
alignment.events = 5;
mdl_param.event_onset_true = determine_onsets(left_padding,right_padding,alignment.events);
event_onsets = find(histcounts(mdl_param.event_onset_true,mdl_param.binns+mdl_param.event_onset(1)));

[svm_box.p_vals,svm_box.combos] = plot_svm_across_datasets_barplots(output_mat,plot_info,event_onsets,[alignment.data_type '_' svm_info.savestr],['V:/Connie/results/behavior/svm']);
%% TESTING SVM REGULARIZATION PARAMETERS
og_svm = output; %load which one you want to rerun
info.savestr = 'box_10_choice_from_attempt2'; %update save string
[output2, output_mat2] = rerun_classifier(og_svm, imaging_st, alignment,plot_info,info);

