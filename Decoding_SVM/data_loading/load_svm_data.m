function [acc, shuff_acc, beta, acc_top, shuff_acc_top] = load_svm_data(info, model_str, event_type,top_suffix, suffix)
    acc = load_SVM_results(info, model_str, event_type, 'acc', suffix);
    shuff_acc = load_SVM_results(info, model_str, event_type, 'shuff_acc', suffix);
    beta = load_SVM_results(info, model_str, event_type, 'betas', suffix);
    if ~isempty(top_suffix)
        acc_top = load_SVM_results(info, model_str, [event_type top_suffix], 'acc', suffix);
        shuff_acc_top = load_SVM_results(info, model_str, [event_type top_suffix], 'shuff_acc', suffix);
    else
        acc_top = [];
        shuff_acc_top = [];
    end
end
