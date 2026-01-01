function plot_final_svm_traces_boxplots_updated(version,event_type,do_passive,savepath,stim_ctrl_label,info,varargin)

info.task_event_type = event_type;
%code below to find these numbers although should be the same each time!
[current_mice,onset_id, active_events, passive_events] = default_data_info(info.task_event_type);
plot_info = default_plot_info([]);

do_passive = do_passive;
if do_passive == 0
    acc_passive = [];
    shuff_acc_passive = [];
    beta_passive = [];
end
% 1) load data
info.chosen_mice = current_mice;
if nargin > 6
    shareFolder = varargin{1};
else
    shareFolder = [];
end
% Load share struct from folder if needed
if ~isempty(shareFolder)
    shareFile = fullfile(shareFolder, ...
        sprintf('%s_svm_outputs_%s.mat', info.task_event_type, version));
    tmp = load(shareFile);
    if isfield(tmp,'shareS')
        shareS = tmp.shareS;
    elseif isfield(tmp,'S')
        shareS = tmp.S;
    else
        f = fieldnames(tmp);
        shareS = tmp.(f{1}); % assume single struct
    end
end
% Choose data source
if ~isempty(shareS)
    svm_mat           = shareS.svm_mat;
    svm_mat2          = shareS.svm_mat2;
    bins_to_include   = shareS.bins_to_include;
    event_onsets      = shareS.event_onsets;
    mdl_param         = shareS.mdl_param;
    svm_mat_pass      = [];
    svm_mat_pass_ctrl = [];
    if isfield(shareS,'svm_mat_pass'),      svm_mat_pass = shareS.svm_mat_pass; end
    if isfield(shareS,'svm_mat_pass_ctrl'), svm_mat_pass_ctrl = shareS.svm_mat_pass_ctrl; end
else
    %load data from server
    info.chosen_mice = current_mice;
    [svm_mat, svm_mat2, svm_mat_pass, svm_mat_pass_ctrl, ~, ...
        bins_to_include, event_onsets, mdl_param, ~, ~, ~, ~, ~, ~] = ...
        wrapper_load_process_svm(current_mice, do_passive, info, active_events, ...
                                 0, savepath, version, plot_info);
end


%2) plot all datasets together
if strcmp(version,'full') || strcmp(version,'nmatch') && do_passive == 0
    save_string = info.task_event_type;
    wrapper_plot_svm_acc_trace_all_datasets(svm_mat, mdl_param, save_string, savepath, [.44,.85],svm_mat2,event_onsets);
    
    % Boxplot of mean across datasets
    celltype_peak_comparison = 1; %which celltype max peak location to use (1 = pyr, 2 = som, 3 = pv, 4 = all, 5 = top pyr)
    wrapper_plot_accuracy_boxplots(svm_mat, svm_mat2,event_onsets, mdl_param, savepath, event_onsets(onset_id),bins_to_include,celltype_peak_comparison, [.45,.90]);
    wrapper_plot_svm_acc_trace_all_datasets(svm_mat, mdl_param, save_string, savepath, [.44,.85],svm_mat2,event_onsets);
elseif strcmp(version,'nmatch') && do_passive == 1
    celltypes_to_comp = [4]; 
    celltype_peak_comparison = 1;
    save_string = info.task_event_type;
    acc_peaks_stats = wrapper_plot_svm_acc_trace_and_boxplots_actpass(svm_mat, mdl_param, [save_string '_active_passive'],savepath, [.45,.85],svm_mat2,event_onsets, celltypes_to_comp,celltype_peak_comparison);

elseif strcmp(version,'stimctrl')
    save_string = info.task_event_type;
    wrapper_plot_svm_acc_trace_all_datasets(svm_mat, mdl_param, save_string, savepath, [.44,.85],svm_mat2,event_onsets);
    
    % Boxplot of mean across datasets
    celltypes_to_comp = [4,5]; %(1 = pyr, 2 = som, 3 = pv, 4 = all, 5 = top pyr)
    celltype_peak_comparison = 1; %[concatenated 1,concatenated 2,concatenated 1 passive,concatenated 2 passive];
    acc_peaks_stats = wrapper_plot_svm_acc_trace_and_boxplots_actpass(svm_mat, mdl_param, [save_string 'stimctrl_act'],savepath, [.45,.85],svm_mat2,event_onsets, celltypes_to_comp,celltype_peak_comparison, stim_ctrl_label);
    acc_peaks_stats = wrapper_plot_svm_acc_trace_and_boxplots_actpass(svm_mat_pass, mdl_param, [save_string 'stimctrl_pass'],savepath, [.45,.85],svm_mat_pass_ctrl,event_onsets, celltypes_to_comp,celltype_peak_comparison, stim_ctrl_label);

end



