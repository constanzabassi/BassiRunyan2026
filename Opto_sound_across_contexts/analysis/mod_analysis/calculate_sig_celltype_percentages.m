function percent_cells = calculate_sig_celltype_percentages(sig_mod_boot, celltypes, celltype_names)
% CALCULATE_SIG_CELLTYPE_PERCENTAGES computes the percentage of significant
% cells within each cell type for each dataset.
%
% Inputs:
%   sig_mod_boot   - Cell array {1,datasets}, each containing indices of significant cells
%   celltypes      - Cell array {1,datasets}, each an array of structs with fields for celltype names
%   celltype_names - Cell array of strings with the celltype fieldnames to evaluate
%
% Output:
%   percent_cells  - Matrix (#datasets x #celltypes) of percentages

nDatasets = numel(sig_mod_boot);
if isempty(celltype_names)
    celltype_names = fieldnames(celltypes{1,1});
end
nCelltypes = numel(celltype_names);

percent_cells = nan(nDatasets, nCelltypes);

for d = 1:nDatasets
    sig_cells = sig_mod_boot{d};
    for ct = 1:nCelltypes
        type_name = celltype_names{ct};
        type_cells = celltypes{d}.(type_name);
        
        if isempty(type_cells)
            percent_cells(d,ct) = NaN; % no cells of this type
        else
            n_total = numel(type_cells);
            n_sig   = numel(intersect(sig_cells, type_cells));
            percent_cells(d,ct) = n_sig / n_total;
        end
    end
end

end
