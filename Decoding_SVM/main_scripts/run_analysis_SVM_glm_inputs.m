addpath(genpath('C:\Code\Github\behavior-analysis2\classifier'))
addpath(genpath('C:\Code\Github\behavior-analysis2'))

%code below to find these numbers although should be the same each time!
passive_events = [7,39,71];%
active_events = [7,39,71,132,146];%
load('V:\Connie\results\opto_2024\context\data_info\info.mat');

%% LOAD THE DATA!
% as if 4/9/25 need to update photostim/outcome
% current_mice = setdiff(1:25,[9,23]);%sounds!! 
% current_mice = setdiff(1:25,[10,12,6,25]);%%photostim to add 10,12,6
% current_mice = setdiff(1:25,[9,23]); %choice
current_mice = setdiff(1:25,[3,8,9,21,22,23]); %outcome


info.chosen_mice = current_mice;
info.task_event_type = 'outcome'; %'sound_category';

acc_active = load_SVM_results(info,'GLM_3nmf_pre',info.task_event_type,'acc','_1'); %_1
shuff_acc_active = load_SVM_results(info,'GLM_3nmf_pre',info.task_event_type,'shuff_acc','_1');
beta_active = load_SVM_results(info,'GLM_3nmf_pre',info.task_event_type,'betas','_1');

%load top neurons
acc_active_top = load_SVM_results(info,'GLM_3nmf_pre',[info.task_event_type '_top'],'acc','_1'); %_1
shuff_acc_active_top = load_SVM_results(info,'GLM_3nmf_pre',[info.task_event_type '_top'],'shuff_acc','_1');

%concatenate with regular svms
acc_active = concatenate_accuracies (acc_active, acc_active_top);
shuff_acc_active = concatenate_accuracies (shuff_acc_active, shuff_acc_active_top);


info.chosen_mice = 2;
all_model_outputs = load_SVM_results(info,'GLM_3nmf_pre','sound_category','all_model_outputs');
info.chosen_mice = current_mice;
%adjust event onsets to bins!
event_onsets = find(histcounts(active_events,all_model_outputs{1,1}{1}.binns+active_events(1)));%find(histcounts(all_model_outputs{1,1}{1}.event_onset,all_model_outputs{1,1}{1}.binns+mdl_param.event_onset(1)));

if strcmp('sound_category',info.task_event_type) || strcmp('photostim',info.task_event_type)
    acc_passive = load_SVM_results(info,'GLM_3nmf_passive',info.task_event_type,'acc');
    shuff_acc_passive = load_SVM_results(info,'GLM_3nmf_passive',info.task_event_type,'shuff_acc');
    beta_passive = load_SVM_results(info,'GLM_3nmf_passive',info.task_event_type,'betas');
    info.chosen_mice = 2;

%     all_model_outputs = load_SVM_results(info,'GLM_3nmf_pre','sound_category','all_model_outputs');
    all_model_outputs = load_SVM_results(info,'GLM_3nmf_passive','sound_category','all_model_outputs');
    info.chosen_mice = current_mice;

    
    %adjust event onsets to bins!
%     event_onsets = find(histcounts(passive_events,all_model_outputs{1,1}{1}.binns+passive_events(1)));%find(histcounts(all_model_outputs{1,1}{1}.event_onset,all_model_outputs{1,1}{1}.binns+mdl_param.event_onset(1)));
    event_onsets = find(histcounts(active_events,all_model_outputs{1,1}{1}.binns+active_events(1)));%find(histcounts(all_model_outputs{1,1}{1}.event_onset,all_model_outputs{1,1}{1}.binns+mdl_param.event_onset(1)));

end

%%
plot_info.colors = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04 % red  
                            0.282, 0.239, 0.545 %dark purple
                            0.16, 0.40, 0.24]; %dark green

% plot_info.colors = [0.282, 0.239, 0.545;0.482, 0.408, 0.933];% [0.780, 0.082, 0.522;1.000, 0.412, 0.706]--'mediumvioletred', 'hotpink'; %[0.275,0.510,0.706;0.529,0.808,0.980];-- 'steelblue', 'lightskyblue'   %[0.545, 0.271, 0.075; 1 0.549 0]--brown and orange %[0.282, 0.239, 0.545;0.482, 0.408, 0.933];--'darkslateblue','mediumslateblue'
plot_info.minmax = [0.45,.9];
plot_info.xlims = [1,length(all_model_outputs{1,1}{1}.binns)]; %32 or 55
plot_info.event_onsets = event_onsets;

savepath = ['V:\Connie\results\SVM_1_wtop\' info.task_event_type '\'];%['V:\Connie\results\SVM_1\' info.task_event_type '\'];
info.savepath = savepath;

if strcmp('sound_category',info.task_event_type) || strcmp('photostim',info.task_event_type)
    plot_info.labels = {'Active','Passive'};
    plot_info.colors = [0.16, 0.40, 0.24 %green
                               0.30 0.58 0.40 
                               0.13, 0.24, 0.51%blue
                               0.282, 0.239, 0.545
                            0.17 0.35 0.8  
                            0.50, 0.06, 0.10
                            0.82 0.04 0.04
                            0.482, 0.408, 0.933];

    [svm_mat, svm_mat2] = get_SVM_across_datasets(info,acc_active,shuff_acc_active,plot_info,savepath,1,{acc_passive,shuff_acc_passive});
else
    plot_info.labels = {'Active'};
    [svm_mat, svm_mat2] = get_SVM_across_datasets(info,acc_active,shuff_acc_active,plot_info,savepath,1);
end

if strcmp('sound_category',info.task_event_type) || strcmp('photostim',info.task_event_type)
    bins_to_include = 32; %or 
else
    bins_to_include = 55;
end
%% compare active vs passive using all cells
mdl_param = all_model_outputs{1,1}{1};
save_string = info.task_event_type;

if strcmp('sound_category',info.task_event_type) || strcmp('photostim',info.task_event_type)
    if ~isempty(svm_mat2)
        svm_acc= cell(length(svm_mat), 2);
    else
        svm_acc= cell(length(svm_mat), 1);
    end
    
    
    % Loop through the rows to merge A and B
    for i = 1:length(svm_mat)
        svm_acc{i, 1}.accuracy = svm_mat{i, 4}.accuracy(:,1:length(all_model_outputs{1,1}{1}.binns)); % Combine row from A
        svm_acc{i, 1}.shuff_accuracy = svm_mat{i, 4}.shuff_accuracy(:,1:length(all_model_outputs{1,1}{1}.binns)); % Combine row from A
        if ~isempty(svm_mat2)
            svm_acc{i, 2}.accuracy = svm_mat2{i, 4}.accuracy(:,1:length(all_model_outputs{1,1}{1}.binns)); % Combine row from B
            svm_acc{i, 2}.shuff_accuracy = svm_mat2{i, 4}.shuff_accuracy(:,1:length(all_model_outputs{1,1}{1}.binns)); % Combine row from B
        end
    end
    if strcmp('sound_category',info.task_event_type)
        plot_info.colors_celltype = [0.282, 0.239, 0.545;0.482, 0.408, 0.933];% [0.780, 0.082, 0.522;1.000, 0.412, 0.706]--'mediumvioletred', 'hotpink'; %[0.275,0.510,0.706;0.529,0.808,0.980];-- 'steelblue', 'lightskyblue'   %[0.545, 0.271, 0.075; 1 0.549 0]--brown and orange %[0.282, 0.239, 0.545;0.482, 0.408, 0.933];--'darkslateblue','mediumslateblue'
    else
        plot_info.colors_celltype = [0.545, 0.271, 0.075; 1 0.549 0]
    end
end
%%
plot_info.colors = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04 % red  
                            0.282, 0.239, 0.545 %dark purple
                            0.16, 0.40, 0.24]; %dark green
plot_info.colors_celltype = plot_info.colors;

%use passive because shorter
mdl_param = all_model_outputs{1,1}{1};
save_string = info.task_event_type;
% all_model_outputs = load_SVM_results(info,'GLM_3nmf_passive',info.task_event_type,'all_model_outputs');

plot_info.labels = {'Pyr','SOM','PV','All','Top Pyr'}; %{'Active'};

%make plot below to compare all cells across active and passive
%plot_svm_across_datasets(svm_acc,plot_info,plot_info.event_onsets,mdl_param,save_string,savepath,[0.45,.7]);movegui(gcf,'center')

%plot active
plot_svm_across_datasets(svm_mat,plot_info,plot_info.event_onsets,mdl_param,save_string,savepath,[0.45,.8],bins_to_include);movegui(gcf,'center');%

if ~isempty(svm_mat2) %plot passive across cell types
    plot_svm_across_datasets(svm_mat2,plot_info,plot_info.event_onsets,mdl_param,[save_string '_passive'],savepath,[0.45,.8],bins_to_include);movegui(gcf,'center');%
end
%% plot beta weights
load('V:\Connie\results\opto_2024\context\data_info\all_celltypes.mat');
all_celltypes_updated = all_celltypes(info.chosen_mice);
info.savestr = 'betas';
if ~isempty(svm_mat2)
    [beta_mat,beta_mat_pass] = get_SVM_betas_across_datasets(info,beta_active,{beta_passive});
else
    [beta_mat] = get_SVM_betas_across_datasets(info,beta_active);
end
onset_id = [];
if strcmp('sound_category',info.task_event_type) || strcmp('photostim',info.task_event_type)
    onset_id = 1;
elseif strcmp('choice',info.task_event_type)
    onset_id = 4;
else
    onset_id = 5;
end

onset = event_onsets(onset_id);%event_onsets(find(ismember(mdl_param.event_onset,active_events)));
plot_dist_weights(onset, beta_mat,all_celltypes_updated,plot_info,mdl_param.data_type,info,[1:3],savepath);

%also plot one bin after the onset
onset = event_onsets(onset_id)+1;%event_onsets(find(ismember(mdl_param.event_onset,active_events)))+1;
plot_dist_weights(onset, beta_mat,all_celltypes_updated,plot_info,mdl_param.data_type,info,[1:3],savepath);
%also plot one bin before the onset
onset = event_onsets(onset_id)-1;%event_onsets(find(ismember(mdl_param.event_onset,active_events)))-1;
plot_dist_weights(onset, beta_mat,all_celltypes_updated,plot_info,mdl_param.data_type,info,[1:3],savepath);

if ~isempty(svm_mat2)
    onset = event_onsets(onset_id);%event_onsets(find(ismember(mdl_param.event_onset,active_events)));
    plot_dist_weights(onset, beta_mat_pass,all_celltypes_updated,plot_info,mdl_param.data_type,info,[1:3],savepath,'_passive');
end
%% PLOT BOX PLOTS OF OVERALL ACCURACY ACROSS CELL TYPES
[acc_peaks,acc_peaks_shuff,acc_peaks_stats] = find_decoding_acc_peaks(svm_mat,1: bins_to_include);
save('acc_peaks_results','acc_peaks','acc_peaks_shuff','acc_peaks_stats')
comp_window = 0; %1sec bc bins of 3
%acc_peaks(4,1) is the peak using 'all' cells
[svm_box.p_vals,svm_box.combos] = plot_svm_across_datasets_barplots(svm_mat,plot_info,acc_peaks(4,1),comp_window,[mdl_param.data_type],savepath,[.4,1]);

wrapper_plot_accuracy_boxplots(svm_mat, svm_mat2,event_onsets, mdl_param, savepath, event_onsets(onset_id),bins_to_include,1, [.45,1]);

if ~isempty(svm_mat2)
    [~,~] = plot_svm_across_datasets_barplots(svm_mat2,plot_info,event_onsets(onset_id),comp_window,[mdl_param.data_type '_passive'],savepath,[.4,1]);
end

% svm_box.p_vals{2,:} are p vals relative to shuffled
%% PLOT WEIGHT EVOLUTION OVER TIME?
info.savestr = 'betas';
plot_weights_over_time([1:bins_to_include], event_onsets(onset_id), beta_mat,all_celltypes_updated,plot_info,mdl_param.data_type,info,[1:3],mdl_param);

% %% to determine events
% if alignment.active_passive == 2
%     load('V:\Connie\ProcessedData\HA11-1R\2023-05-05\passive\imaging.mat')
%     [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging,30,2);
%     events = determine_onsets(left_padding,right_padding,1:3);
%         alignment.type = 'stimulus';
%     alignment.data_type = 'deconv';
%     [aligned_imaging,imaging_array,align_info] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment); % sample_data is n_trials x n_cells x n_frames
% 
% else
%     load('V:\Connie\ProcessedData\HA11-1R\2023-05-05\VR\imaging.mat')
%     [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging,30);
%     events = determine_onsets(left_padding,right_padding,1:5);
%     alignment.type = 'pre';
%     alignment.data_type = 'deconv';
%     [aligned_imaging,imaging_array,align_info] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment); % sample_data is n_trials x n_cells x n_frames
% end
% 
% mdl_param.event_onset = events(4);
% if alignment.active_passive == 2
%  frame_length =  events(3)+right_padding(3)-mdl_param.event_onset;%150 outcome?;%for choice; %used to be 281 with update is 260
% else
% frame_length =  events(5)+right_padding(5)-mdl_param.event_onset;%150 outcome?;%for choice; %used to be 281 with update is 260
% end
% 
% mdl_param.frames_around = -mdl_param.event_onset+1:frame_length; %-mdl_param.event_onset+1:(frame_length)-mdl_param.event_onset+1;%-mdl_param.event_onset+1:mdl_param.event_onset-51 == -140:90; %frames around onset 
% mdl_param.binns = mdl_param.frames_around(1):3:mdl_param.frames_around(end); %bins in terms of event onset
