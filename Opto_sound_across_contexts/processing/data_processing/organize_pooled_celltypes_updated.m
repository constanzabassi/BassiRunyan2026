function [num_cells, sorted_cells] = organize_pooled_celltypes_updated(dff_st, all_celltypes)
%ORGANIZE_POOLED_CELLTYPES generalizes cell-type index pooling across datasets.
%
%   [num_cells, sorted_cells] = organize_pooled_celltypes(dff_st, all_celltypes)
%
%   INPUTS:
%       dff_st        - cell array of datasets, each with a field 'stim'
%       all_celltypes - cell array of structs with cell-type fields 
%                       (e.g., pyr_cells, som_cells, pv_cells, etc.)
%
%   OUTPUTS:
%       num_cells     - total number of cells per dataset
%       sorted_cells  - struct containing concatenated indices for each cell type
%                       (e.g., sorted_cells.pyr, sorted_cells.som, etc.)
%
%   The function automatically detects all *_cells fields in all_celltypes
%   and creates pooled index vectors for each across all datasets.

    % Initialize outputs
    num_cells = [];
    sorted_cells = struct();

    % Detect all cell-type fieldnames (ending in '_cells') from first dataset
    all_fields = fieldnames(all_celltypes{1});
    celltype_fields = all_fields(endsWith(all_fields, '_cells'));

    % Initialize fields in output structure
    for f = 1:numel(celltype_fields)
        sorted_cells.(erase(celltype_fields{f}, '_cells')) = [];
    end

    % Loop through datasets
    for dataset_index = 1:numel(dff_st)
        % Number of cells in this dataset
        if isfield(dff_st{dataset_index}, 'stim')
            num_cells(dataset_index) = size(dff_st{dataset_index}.stim, 2);
        else
            % Fallback if stim missing
            counts = cellfun(@(f) numel(all_celltypes{dataset_index}.(f)), celltype_fields);
            num_cells(dataset_index) = sum(counts);
        end

        % Offset to maintain global indexing
        offset = sum(num_cells(1:dataset_index-1));

        % Append indices for each cell type
        for f = 1:numel(celltype_fields)
            fieldname = celltype_fields{f};
            base_name = erase(fieldname, '_cells'); % e.g., "pyr_cells" → "pyr"
            cell_indices = all_celltypes{dataset_index}.(fieldname) + offset;
            sorted_cells.(base_name) = [sorted_cells.(base_name); cell_indices(:)];
        end
    end
end
