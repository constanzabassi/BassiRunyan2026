function [svm_mat, svm_mat2] = wrapper_plot_svm_acc_trace_individual_datasets(info, acc_active, shuff_acc_active, acc_passive, shuff_acc_passive, all_model_outputs, savepath, doplot, event_onsets)
%create time series plots of svm accuracy across celltypes    
plot_info = default_plot_info(all_model_outputs);
plot_info.event_onsets =  event_onsets;
    if ~isempty(acc_passive)
        plot_info.labels = {'Active','Passive'};
            plot_info.colors = plot_info.colors_active_passive;

        [svm_mat, svm_mat2] = get_SVM_across_datasets(info, acc_active, shuff_acc_active, plot_info, savepath, doplot, {acc_passive, shuff_acc_passive});
    else
        plot_info.labels = {'Active'};
        [svm_mat, svm_mat2] = get_SVM_across_datasets(info, acc_active, shuff_acc_active, plot_info, savepath, doplot);
    end
end
