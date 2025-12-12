function [context_mod_all, chosen_pyr, chosen_mcherry, chosen_tdtom, celltypes_ids,chosen_fourth_ct] = ...
    organize_sig_mod_index_contexts_celltypes(chosen_mice, mod_index, sig_mod_boot, all_celltypes,celltype_names)
% ORGANIZE_SIG_MOD_INDEX_CONTEXTS_CELLTYPES organizes modulation indices (across contexts)
% and cell type indices across datasets.
%
%   Inputs:
%     chosen_mice  - Array of dataset indices (e.g., [1 2 3 ...]) to include.
%     mod_index    - Cell array (datasets x contexts) containing modulation indices.
%                    For example, mod_index{m,context} is a vector of modulation indices for dataset m.
%     sig_mod_boot - (Optional) Array or structure containing bootstrap p-values for significance.
%                    If nonempty, significant cells are defined as those whose p-values are <= 0.05.
%     all_celltypes- Cell array (1 x datasets) of cell type structure for each dataset.
%                    For each dataset m, all_celltypes{1,m} should have fields:
%                        .pyr_cells, .som_cells, and .pv_cells (each a vector of cell indices).
%     celltype_names- used for labeling purposes
%
%   Outputs:
%     context_mod_all - A matrix formed by concatenating (vertically) the modulation indices
%                       from all datasets (each dataset’s indices are arranged as [nCells x nContexts]).
%     chosen_pyr      - Indices of significant (or selected) pyramidal cells across datasets.
%     chosen_mcherry  - Indices of significant (or selected) mCherry-labeled cells across datasets.
%     chosen_tdtom    - Indices of significant (or selected) tdTomato-labeled cells across datasets.
%     celltypes_ids   - A cell array where:
%                         celltypes_ids{1} = chosen_pyr,
%                         celltypes_ids{2} = chosen_mcherry,
%                         celltypes_ids{3} = chosen_tdtom.
%
%   The function first (if bootstrap results exist) computes the union of significant cells
%   across contexts (here, context 1 = active, context 2 = passive) using a helper function
%   (union_sig_cells). Then, for each chosen dataset, it organizes the modulation indices and
%   computes the cell type indices. If bootstrap significance is available, it uses the union
%   of significant cells; otherwise, it uses all cells.

% Initialize output containers.
context_modulation_index = {};  
chosen_pyr = []; 
chosen_mcherry = []; 
chosen_tdtom = [];
celltypes_ids = {};
chosen_cells_all = struct();  % Store chosen cells per field

%possible fields
cell_fields = fieldnames(all_celltypes{1,1});
% Compute total cell counts for each chosen dataset using context 1 modulation indices.
% (Assuming mod_index{m,1} is a vector for dataset m.)
all_cellCounts = cellfun(@(x) length(x), mod_index(chosen_mice, 1));

% If bootstrap significance is provided, compute the union of significant cells
% across active (context 1) and passive (context 2) for each dataset.
if ~isempty(sig_mod_boot) && size(sig_mod_boot,2) > 1
    % Here we assume union_sig_cells is a function that returns, for each dataset,
    % the union of significant cell indices (based on p-values <= 0.05) from contexts 1 and 2.
    % We replace mod_indexm with mod_index.
    [combined_sig_cells, ~] = union_sig_cells(sig_mod_boot(:,1)', sig_mod_boot(:,2)', mod_index);
%     [combined_sig_cells, ~] = intersect_sig_cells(sig_mod_boot(:,1)', sig_mod_boot(:,2)', mod_index);
elseif ~isempty(sig_mod_boot)
    combined_sig_cells = sig_mod_boot;
    

end

if ~isempty(sig_mod_boot)
    num_sig_cells =cellfun (@length, combined_sig_cells);
else
    num_sig_cells =all_cellCounts;

end

% Initialize a variable to accumulate cell count offsets from previous datasets.
previous_dataset_cellCount = [];  % will store dataset indices (or cell counts) for offsetting indices
% Loop over each chosen dataset.
for current_dataset = chosen_mice
    fprintf('Processing dataset %d...\n', current_dataset);
    
    % For each dataset, determine the set of cells to use:
    if ~isempty(sig_mod_boot) && ~isempty(sig_mod_boot{current_dataset})
        % Use the union of significant cells from active and passive contexts.
        mod_cells = combined_sig_cells{current_dataset};
    elseif ~isempty(sig_mod_boot) && isempty(sig_mod_boot{current_dataset})
        continue
    else
        % Use all cells for dataset m.
        mod_cells = 1:all_cellCounts(current_dataset);
    end
    
    % For each dataset, combine modulation indices across contexts.
    % Here we assume there are 3 contexts (e.g., active, passive, spontaneous).
    % We'll store them as columns in a matrix.
    current_dataset_mod_index = [];
    for context = 1:size(mod_index,2)
        % Each mod_index{m,context} is assumed to be a column vector.
        % We concatenate them as separate columns.
        current_dataset_mod_index(:, context) = mod_index{current_dataset, context}(mod_cells);
    end
    % Save the combined modulation indices for dataset m.
    context_modulation_index{current_dataset} = current_dataset_mod_index;
    
    % ORGANIZE CELL TYPE INDICES
     % Organize cell type indices
    fields = fieldnames(all_celltypes{1, current_dataset});
    for f = 1:numel(fields)
        field_name = fields{f};
        cell_indices = all_celltypes{1, current_dataset}.(field_name);
        
        if ~isempty(sig_mod_boot)
            idx = find(ismember(mod_cells, cell_indices));
        else
            idx = cell_indices;
        end
        
        % Add offset for subsequent datasets
        if current_dataset ~= chosen_mice(1)
            if ~isempty(sig_mod_boot)
                offset = sum(num_sig_cells(previous_dataset_cellCount));
            else
                offset = sum(all_cellCounts(previous_dataset_cellCount));
            end
            idx = idx + offset;
        end
        
        % Accumulate in struct
        if isfield(chosen_cells_all, field_name)
            chosen_cells_all.(field_name) = [reshape(chosen_cells_all.(field_name), 1, []),  reshape(idx, 1, [])];
        else
            chosen_cells_all.(field_name) = idx;
        end
    end
    % For each dataset, we want to assign indices to different cell types.
    % If bootstrap significance exists, we only use cells that are in mod_cells.
    % Otherwise, we use the full list from all_celltypes.
%     if ~isempty(sig_mod_boot)
%         if current_dataset == chosen_mice(1)
%             % For the first dataset, no offset is needed.
%             chosen_pyr = [chosen_pyr, find(ismember(mod_cells,all_celltypes{1,current_dataset}.pyr_cells))] ;
%             chosen_mcherry = [chosen_mcherry, find(ismember(mod_cells,all_celltypes{1,current_dataset}.som_cells))] ;
%             chosen_tdtom = [chosen_tdtom, find(ismember(mod_cells,all_celltypes{1,current_dataset}.pv_cells))] ;
%         else
%             % For subsequent datasets, add an offset equal to the total cell count from previous datasets.
%             temp =sum( num_sig_cells(previous_dataset_cellCount));
%             chosen_pyr = [chosen_pyr, find(ismember(mod_cells,all_celltypes{1,current_dataset}.pyr_cells))+temp] ;
%             chosen_mcherry = [chosen_mcherry, find(ismember(mod_cells,all_celltypes{1,current_dataset}.som_cells))+temp] ;
%             chosen_tdtom = [chosen_tdtom, find(ismember(mod_cells,all_celltypes{1,current_dataset}.pv_cells))+temp] ;
%         end
%     else
%         % If no bootstrap significance is provided, use the original cell indices.
%         if current_dataset == chosen_mice(1)
%             chosen_pyr = [chosen_pyr, all_celltypes{1,current_dataset}.pyr_cells'];
%             chosen_mcherry = [chosen_mcherry, all_celltypes{1,current_dataset}.som_cells'];
%             chosen_tdtom = [chosen_tdtom, all_celltypes{1,current_dataset}.pv_cells'];
%         else
%             temp = sum(all_cellCounts(previous_dataset_cellCount));
%             chosen_pyr = [chosen_pyr, all_celltypes{1,current_dataset}.pyr_cells' + temp];
%             chosen_mcherry = [chosen_mcherry, all_celltypes{1,current_dataset}.som_cells' + temp];
%             chosen_tdtom = [chosen_tdtom, all_celltypes{1,current_dataset}.pv_cells' + temp];
%         end
%     end
    
    % Update the list of previous datasets for offset computation.
    previous_dataset_cellCount = [previous_dataset_cellCount, current_dataset];
end

% % Save cell type indices in a cell array.
% celltypes_ids{1} = chosen_pyr;
% celltypes_ids{2} = chosen_mcherry;
% celltypes_ids{3} = chosen_tdtom;
% 
% 
% % Set cell type names for labeling (e.g., PYR, SOM, PV).
% celltypes_ids{2,1} = celltype_names{1}; % PYR cells
% celltypes_ids{2,2} = celltype_names{2}; % SOM cells
% celltypes_ids{2,3} = celltype_names{3}; % PV cells

% Convert chosen_cells_all struct to cell array for output
field_names = fieldnames(chosen_cells_all);
for f = 1:numel(field_names)
    celltypes_ids{1, f} = chosen_cells_all.(field_names{f});
    if nargin >= 5 && f <= numel(celltype_names)
        celltypes_ids{2, f} = celltype_names{f};
    else
        celltypes_ids{2, f} = field_names{f};  % fallback to field name
    end
end

% Concatenate the modulation indices from all datasets.
% This creates an array where each row corresponds to a dataset's cells
% (stacked vertically) and columns correspond to the contexts.
context_mod_all = cat(1, context_modulation_index{:});

chosen_pyr = chosen_cells_all.(field_names{1});
    if length(field_names)>1
        chosen_mcherry = chosen_cells_all.(field_names{2});
        chosen_tdtom = chosen_cells_all.(field_names{3});
        if length(field_names)>3
            chosen_fourth_ct = chosen_cells_all.(field_names{4});
        else
            chosen_fourth_ct = [];
        end
    else
        chosen_mcherry = [];
        chosen_tdtom = [];
        chosen_fourth_ct = [];
    end
end
