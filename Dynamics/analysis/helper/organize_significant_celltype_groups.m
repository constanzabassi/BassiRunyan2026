function all_celltypes_updated = organize_significant_celltype_groups (all_celltypes,sig_mod_boot)
possible_celltypes = fieldnames(all_celltypes{1,1});
all_celltypes_updated = {};
for m = 1:length(sig_mod_boot)
    for ce = 1:length(possible_celltypes)
        %Initialize variables
        celltype = all_celltypes{1,m}.(possible_celltypes{ce});
    
        celltypes_permouse = celltype;
        sig_cells_permouse_temp = find(ismember(sig_mod_boot{m},celltypes_permouse));
        all_celltypes_updated{1,m}.(possible_celltypes{ce}) = sig_mod_boot{m}(sig_cells_permouse_temp);
    end
end