addpath(genpath('C:\Code\Github\behavior-analysis2\classifier'))
addpath(genpath('C:\Code\Github\behavior-analysis2'))


load('V:\Connie\results\opto_2024\context\data_info\info.mat');
info.task_event_type = 'sound_category';
%code below to find these numbers although should be the same each time!
[current_mice,onset_id, active_events, passive_events] = default_data_info(info.task_event_type);
plot_info = default_plot_info(all_model_outputs);
do_passive = 1;
if do_passive == 0
    acc_passive = [];
    shuff_acc_passive = [];
    beta_passive = [];
end
%% 1) load data
[svm_mat, svm_mat2,svm_mat_pass, svm_mat_pass_ctrl] = load_SVM_output_datasets('W:\Connie\results\SVM\',plot_info, [],0, do_passive);

all_model_outputs = load('W:\Connie\results\SVM\sound_category_active_opto0all_model_outputs.mat').all_model_outputs;
if do_passive == 1
    all_model_outputs = load('W:\Connie\results\SVM\sound_category_passive_opto0all_model_outputs.mat').all_model_outputs;
    bins_to_include = 32;
    [svm_mat, svm_mat2,svm_mat_pass, svm_mat_pass_ctrl] = load_SVM_output_datasets('W:\Connie\results\SVM\',plot_info, [],0, 1);

else
    bins_to_include = 55;
end
info.chosen_mice = current_mice;
event_onsets = find(histcounts(active_events,all_model_outputs{1,1,1}.binns+active_events(1)));%find(histcounts(all_model_outputs{1,1}{1}.event_onset,all_model_outputs{1,1}{1}.binns+mdl_param.event_onset(1)));

%% plot individual datasets and find means across shuffles
doplot = 0;

savepath = 'W:\Connie\results\Bassi2025\fig2\SVM_1\opto_ctrl'; %W:\Connie\results\SVM\opto_ctrl'; % ['V:\Connie\results\SVM_1_wtop\active_passive\' info.task_event_type '\'];%['V:\Connie\results\SVM_1\' info.task_event_type '\'];
info.savepath = savepath;
%% plot all datasets together

mdl_param = all_model_outputs{1,1,1};
save_string = info.task_event_type;

wrapper_plot_svm_acc_trace_all_datasets(svm_mat, mdl_param, save_string, savepath, [.45,.85],svm_mat2,event_onsets);
if do_passive == 1
    wrapper_plot_svm_acc_trace_all_datasets(svm_mat_pass, mdl_param, save_string, savepath, [.45,.85],svm_mat_pass_ctrl,event_onsets);
end
%% Boxplot of mean across datasets
celltype_peak_comparison = 4; %which celltype max peak location to use (1 = pyr, 2 = som, 3 = pv, 4 = all, 5 = top pyr)
wrapper_plot_accuracy_boxplots(svm_mat, svm_mat2,event_onsets, mdl_param, savepath, event_onsets(onset_id),bins_to_include,celltype_peak_comparison, [.45,1]);

%% trace and boxplot comparing active and passive
celltypes_to_comp = [4,5]; %(1 = pyr, 2 = som, 3 = pv, 4 = all, 5 = top pyr)
celltype_peak_comparison = 1; %[concatenated 1,concatenated 2,concatenated 1 passive,concatenated 2 passive];
acc_peaks_stats = wrapper_plot_svm_acc_trace_and_boxplots_actpass(svm_mat, mdl_param, [save_string 'stimctrl_act'],savepath, [.45,.85],svm_mat2,event_onsets, celltypes_to_comp,celltype_peak_comparison, {'Stim','Ctrl'});

acc_peaks_stats = wrapper_plot_svm_acc_trace_and_boxplots_actpass(svm_mat_pass, mdl_param, [save_string 'stimctrl_pass'],savepath, [.45,.85],svm_mat_pass_ctrl,event_onsets, celltypes_to_comp,celltype_peak_comparison, {'Stim (P)','Ctrl (P)'});

acc_peaks_stats = wrapper_plot_svm_acc_trace_and_boxplots_actpass(svm_mat, mdl_param, [save_string 'actpass_stim'],savepath, [.45,.85],svm_mat_pass,event_onsets, celltypes_to_comp,celltype_peak_comparison);

acc_peaks_stats = wrapper_plot_svm_acc_trace_and_boxplots_actpass(svm_mat2, mdl_param, [save_string 'actpass_ctrl'],savepath, [.45,.85],svm_mat_pass_ctrl,event_onsets, celltypes_to_comp,celltype_peak_comparison,{'Active Ctrl','Passive Ctrl'});

%% PLOT BETA WEIGHTS
load('V:\Connie\results\opto_2024\context\data_info\all_celltypes.mat');
all_celltypes_updated = all_celltypes(info.chosen_mice);
info.event_onsets = event_onsets;

[beta_mat,beta_mat_pass] = wrapper_mean_betas(info,beta_active,beta_passive); %mean across iterations

%
bin_id = event_onsets(onset_id); %time when to get betas from
wrapper_plot_betas_distributions(info,bin_id, beta_mat, all_celltypes_updated,  mdl_param, onset_id, [],[]);

% PLOT WEIGHT EVOLUTION OVER TIME
info.savestr = 'betas';
plot_weights_over_time([1:bins_to_include], event_onsets(onset_id), beta_mat,all_celltypes_updated,event_onsets,mdl_param.data_type,info,[1:3],mdl_param,savepath);

if do_passive == 1
    wrapper_plot_betas_distributions(info,bin_id, beta_mat_pass, all_celltypes_updated,  mdl_param, onset_id, [],[]);

    % PLOT WEIGHT EVOLUTION OVER TIME
    info.savestr = 'betas';
    plot_weights_over_time([1:bins_to_include], event_onsets(onset_id), beta_mat_pass,all_celltypes_updated,event_onsets,mdl_param.data_type,info,[1:3],mdl_param,[savepath '/passive']);

end

