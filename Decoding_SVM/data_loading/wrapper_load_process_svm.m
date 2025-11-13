function [svm_mat, svm_mat2,svm_mat_pass, svm_mat_pass_ctrl, all_model_outputs,bins_to_include, event_onsets, mdl_param, beta_active, acc_active_top, shuff_acc_active_top, beta_passive, acc_passive_top, shuff_acc_passive_top] = wrapper_load_process_svm(current_mice, do_passive, info, active_events, doplot, savepath, version, varargin)
%RUN_SVM_ANALYSIS Run SVM decoding and extract outputs for active/passive data
%
% Usage:
%   [svm_mat, svm_mat2, event_onsets, mdl_param] = run_svm_analysis(current_mice, do_passive, info, active_events, doplot, savepath)
%
% Inputs:
%   current_mice : array or scalar specifying mice to include
%   do_passive   : 1 to include passive data, 0 for active only
%   info         : struct with at least field info.task_event_type
%   active_events: array of event onset times
%   doplot       : logical flag to control plotting (0 or 1)
%   savepath     : directory to save figures/results
%
% Outputs:
%   svm_mat, svm_mat2 : SVM accuracy matrices (active vs passive)
%   event_onsets      : frame indices of stimulus onsets
%   mdl_param         : model parameters from SVM results
%
% Dependencies:
%   wrapper_load_all_svm_data.m
%   remove_specific_celltype.m
%   load_SVM_results.m
%   wrapper_plot_svm_acc_trace_individual_datasets.m

svm_mat_pass = [];
svm_mat_pass_ctrl = [];
acc_active = []; shuff_acc_active = []; beta_active = []; acc_active_top = []; shuff_acc_active_top = [];
if nargin > 7
    plot_info = varargin{1,1};
end
    %% --- 1) Load ACTIVE data ---
    info.chosen_mice = current_mice;
    if strcmp(version,'full')
        [acc_active, shuff_acc_active, beta_active, acc_active_top, shuff_acc_active_top] = ...
            wrapper_load_all_svm_data(info, 'GLM_3nmf_pre', [info.task_event_type '_all'], [], '_1');
        % Remove unwanted celltype (4 = all?)
        celltype_to_delete = 4;
        [acc_active, shuff_acc_active] = remove_specific_celltype(acc_active, shuff_acc_active, celltype_to_delete);
            % --- 2) Load full model outputs (for active) ---

    elseif strcmp(version,'stimctrl')
            [svm_mat, svm_mat2,svm_mat_pass, svm_mat_pass_ctrl] = load_SVM_output_datasets('W:\Connie\results\SVM\',plot_info, [],0, do_passive);
    else
        [acc_active, shuff_acc_active, beta_active, acc_active_top, shuff_acc_active_top] = wrapper_load_all_svm_data(info, 'GLM_3nmf_pre', info.task_event_type, '_top', '_1');

    end
    %% --- 2) Load full model outputs (for active) ---
        info.chosen_mice = 2;
        all_model_outputs = load_SVM_results(info, 'GLM_3nmf_pre','sound_category', 'all_model_outputs', '_1');


    %% --- 3) Passive data (optional) ---
    info.chosen_mice = current_mice;
    if do_passive == 1
        if strcmp(version,'full')
            [acc_passive, shuff_acc_passive, beta_passive, acc_passive_top, shuff_acc_passive_top] = ...
                wrapper_load_all_svm_data(info, 'GLM_3nmf_passive', 'sound_category', '_all', '_1');
        else
            [acc_passive, shuff_acc_passive, beta_passive, acc_passive_top, shuff_acc_passive_top] = wrapper_load_all_svm_data(info, 'GLM_3nmf_passive', info.task_event_type, '_top', '_1');
        end
        info.chosen_mice = 2;
        all_model_outputs = load_SVM_results(info, 'GLM_3nmf_passive','sound_category', 'all_model_outputs');
        bins_to_include = 32;
    else
        acc_passive = [];
        shuff_acc_passive = [];
        beta_passive = [];
        acc_passive_top = [];
        shuff_acc_passive_top= [];
        bins_to_include = 55;
    end

    %% --- 4) Extract event onsets and model parameters ---
    if isempty(active_events)
        error('active_events input is empty. Please provide an array of event onset times.');
    end

    event_onsets = find(histcounts(active_events, all_model_outputs{1,1}{1}.binns + active_events(1)));

    if isfield(all_model_outputs{1,1}{1}, 'mdl_param')
        mdl_param = all_model_outputs{1,1}{1}.mdl_param;
    elseif strcmp(version,'full') 
        mdl_param = all_model_outputs{1,1,1}{1};
    else
        all_model_outputs = load('W:\Connie\results\SVM\sound_category_passive_opto0all_model_outputs.mat').all_model_outputs;
        mdl_param = all_model_outputs{1,1,1};
    end

    %% --- 5) Plot and summarize SVM accuracies ---
    if ~exist(savepath, 'dir')
        mkdir(savepath);
    end
    info.savepath = savepath
    info.chosen_mice = current_mice;

    if strcmp(version,'full') || strcmp(version,'nmatch')
        [svm_mat, svm_mat2] = wrapper_plot_svm_acc_trace_individual_datasets( ...
            info, acc_active, shuff_acc_active, acc_passive, shuff_acc_passive, ...
            all_model_outputs, savepath, doplot, event_onsets);
    end

end
