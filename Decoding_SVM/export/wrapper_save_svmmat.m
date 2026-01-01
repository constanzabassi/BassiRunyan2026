function wrapper_save_svmmat(version,event_type,do_passive,new_base_dir,stim_ctrl_label,varargin)

if nargin > 5
    info = varargin{1};
else
    load('V:\Connie\results\opto_2024\context\data_info\info.mat');
end
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

wrapper_load_and_save_svm_struct( ...
    current_mice, do_passive, info, active_events, ...
    version, new_base_dir, plot_info)
end