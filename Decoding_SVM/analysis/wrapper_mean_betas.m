function [beta_mat,beta_mat_pass] = wrapper_mean_betas(info,beta_active,beta_passive)
%finds means across iterations and organizes beta into betas{split, dataset_idx, bin}
if ~isempty(beta_passive)
    [beta_mat,beta_mat_pass] = get_SVM_betas_across_datasets(info,beta_active,{beta_passive});
else
    [beta_mat] = get_SVM_betas_across_datasets(info,beta_active);
    beta_mat_pass =[];
end