function [unpacked_mod_index,chosen_cells] = unpack_modindexm(mod_index,sig_mod_boot,all_celltypes,varargin)
% Function to unpack modulation index values for selected cells based on 
% significance and cell type criteria.
%
% Inputs:
%   - mod_index: Cell array where each entry contains modulation index values for different contexts.
%   - sig_mod_boot: Cell array of significant modulation neuron indices per dataset.
%   - all_celltypes: Cell array containing cell type categorization (neuron indices) per dataset.
%   - varargin: (Optional) Specifies which datasets to process; defaults to all datasets.
%
% Outputs:
%   - unpacked_mod_index: Cell array containing modulation index values for
%                           selected cells with shape {dataset_index,context,cell type}
%   - chosen_cells: Cell array containing indices of selected cells for each dataset and cell type.

% Extract field names (cell types) from the first dataset
fieldss = fields(all_celltypes{1,1});

% Determine which datasets to process based on input arguments
% Default values
chosen_mice = 1:size(mod_index,2);
min_cells   = 0;

% Overwrite defaults if varargin provided
if length(varargin) >= 1
    chosen_mice = varargin{1};
end

if length(varargin) >= 2
    min_cells = varargin{2};
end

chosen_cells ={};


% Iterate over each chosen dataset
for dataset_index = chosen_mice
    dataset_index
    % Check if significant modulation data exists for the dataset
    if ~isempty(sig_mod_boot) && ~isempty(sig_mod_boot{dataset_index})
        for celltype = 1:length(fieldss)
            % Select cells that are both significant and belong to the given cell type
            chosen_cells{dataset_index,celltype} = sig_mod_boot{dataset_index}(find(ismember(sig_mod_boot{dataset_index},all_celltypes{1,dataset_index}.(fieldss{celltype})))) ;
        end
    elseif isempty(sig_mod_boot)
        % If no significance filtering, use all cells of each type
        for celltype = 1:length(fieldss)
            chosen_cells{dataset_index,celltype} = all_celltypes{1,dataset_index}.(fieldss{celltype});
        end
    elseif ~isempty(sig_mod_boot) && isempty(sig_mod_boot{dataset_index})
        for celltype = 1:length(fieldss)
            % Select cells that are both significant and belong to the given cell type
            chosen_cells{dataset_index,celltype} = [];
        end

    end
    
    % Iterate over each context in the modulation index dataset
    for context = 1:size(mod_index,2)
        for cel = 1:length(fieldss)

            % Ensure there are enough selected cells and trials
            if ~isempty(chosen_cells) && length(chosen_cells{dataset_index,cel})>min_cells && length(mod_index{dataset_index,context}(chosen_cells{dataset_index,cel})) > min_cells %at least 2 cells of this cell type!, at least 3 trials across all contexts for this mouse! % 
                % Store modulation index for selected cells
                unpacked_mod_index{dataset_index,context,cel} = mod_index{dataset_index,context}(chosen_cells{dataset_index,cel});
            else
                % Assign NaN if criteria are not met (no sig cells)
                unpacked_mod_index{dataset_index,context,cel} = nan;
            end
        end
    end
end