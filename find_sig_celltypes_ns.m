function [total_sig_cells,total_sig_cells_per_dataset,sig_cells_permouse] = find_sig_celltypes_ns(sig_cells,all_celltypes)
possible_celltypes = fieldnames(all_celltypes{1,1});
total_sig_cells = {};
total_sig_cells_per_dataset = {};
sig_cells_permouse= {};
 for ce = 1:length(possible_celltypes)
     for dataset = 1:length(sig_cells)
        celltypes_permouse = all_celltypes{dataset}.(possible_celltypes{ce});
        sig_cells_permouse_temp = find(ismember(sig_cells{dataset},celltypes_permouse));
        sig_cells_permouse{dataset,ce} = sig_cells{dataset}(sig_cells_permouse_temp);
        total_sig_cells_per_dataset.(possible_celltypes{ce}).(['dataset' num2str(dataset)]) = length(sig_cells_permouse{dataset,ce});
     end
     total_sig_cells.(possible_celltypes{ce}) = length([sig_cells_permouse{:,ce}]); %cumsum(cellfun(@length, {sig_cells_permouse{:,ce}}));
 end