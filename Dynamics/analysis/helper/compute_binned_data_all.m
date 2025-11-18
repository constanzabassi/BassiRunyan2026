function binned_data_all = compute_binned_data_all (context_data,ncelltypes,alignment,sig_mod_boot,possible_conditions)
% binned_data_all: mean across trials & cells for each dataset/condition/celltype
for conditions = 1:2
    for celltypes = 1:ncelltypes
        celltype = {alignment.cells{celltypes,:}};
        for dataset = 1:length(sig_mod_boot)
            % context_data.dff{3,dataset}.(possible_conditions{conditions+2})
            % is trials × cells × time
            if strcmp(alignment.data_type,'z_dff')
                binned_data_all(dataset,conditions,celltypes,:) = ...
                squeeze(mean(context_data.dff{3, dataset}.(possible_conditions{conditions+2}),[1,2]));
            else
                binned_data_all(dataset,conditions,celltypes,:) = ...
                squeeze(mean(context_data.dff{3, dataset}.(possible_conditions{conditions}),[1,2]));

            end
        end
    end
end