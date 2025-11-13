function [acc_active_updated, shuff_acc_active_updated] = remove_specific_celltype(acc_active, shuff_acc_active, ce_to_delete)
%function to remove specified cell types from acc_active structure which is
% acc_active{1,dataset}{splits,shuffles,celltypes}
num_datasets = size(acc_active,2);
total_celltypes = size(acc_active{1,1},3);
celltypes_to_keep = setdiff(1:total_celltypes,ce_to_delete)
acc_active_updated = cell(1,num_datasets);
shuff_acc_active_updated = cell(1,num_datasets);

for dataset = 1:num_datasets
    acc_active_updated{1,dataset} = acc_active{1,dataset}(:,:,celltypes_to_keep);
    shuff_acc_active_updated{1,dataset} = shuff_acc_active{1,dataset}(:,:,celltypes_to_keep);
end