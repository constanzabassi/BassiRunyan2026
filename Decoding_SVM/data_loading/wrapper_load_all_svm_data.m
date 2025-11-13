function [acc_active, shuff_acc_active, beta_active, acc_active_top, shuff_acc_active_top] = wrapper_load_all_svm_data(info, model_type, task_event_type, top_suffix, svm_suffix)

%load accuracies for each dataset
[acc_active, shuff_acc_active, beta_active, acc_active_top, shuff_acc_active_top] = ...
    load_svm_data(info, model_type, task_event_type, top_suffix, svm_suffix);

%if we loaded top neurons concatenate with the rest of the arrays
if ~isempty(top_suffix)
    [acc_active, shuff_acc_active] = merge_with_top_cells(acc_active, acc_active_top, shuff_acc_active, shuff_acc_active_top);
end