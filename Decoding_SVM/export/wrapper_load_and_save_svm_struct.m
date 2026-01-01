function wrapper_load_and_save_svm_struct( ...
    current_mice, do_passive, info, active_events, ...
    version, new_base_dir, plot_info)

% Wrapper that loads SVM results via wrapper_load_process_svm
% and saves selected outputs to a public directory.
%
% Saves:
%   svm_mat
%   svm_mat2
%   svm_mat_pass
%   svm_mat_pass_ctrl
%   bins_to_include
%   event_onsets
%   mdl_param
%
% Directory:
%   new_base_dir/decoding/SVM<version>/

%% ---------------- Call existing loader ----------------
[svm_mat, ...
 svm_mat2, ...
 svm_mat_pass, ...
 svm_mat_pass_ctrl, ...
 ~, ...
 bins_to_include, ...
 event_onsets, ...
 mdl_param, ...
 ~, ~, ~, ~, ~, ~] = ...
    wrapper_load_process_svm(current_mice, do_passive, info, active_events, 0, [],version, plot_info);

%% ---------------- Build save directory ----------------
save_dir = fullfile( ...
    new_base_dir, ['SVM']);

if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

%% ---------------- Package outputs ----------------
svm_outputs = struct();
svm_outputs.svm_mat           = svm_mat;
svm_outputs.svm_mat2          = svm_mat2;
svm_outputs.svm_mat_pass      = svm_mat_pass;
svm_outputs.svm_mat_pass_ctrl = svm_mat_pass_ctrl;
svm_outputs.bins_to_include   = bins_to_include;
svm_outputs.event_onsets      = event_onsets;
svm_outputs.mdl_param         = mdl_param;

% Minimal metadata (optional but recommended)
svm_outputs.meta = struct();
svm_outputs.meta.current_mice = current_mice;
svm_outputs.meta.do_passive   = do_passive;
svm_outputs.meta.version      = version;

%% ---------------- Save ----------------
filename = sprintf('%s_svm_outputs_%s.mat', info.task_event_type,version);

save(fullfile(save_dir, filename), 'svm_outputs', '-v7.3');

end
