function sig_mod_boot_thr = get_thresholded_sig_cells(info, mod_params, mod_indexm, sig_mod_boot, sorted_cells,all_celltypes,mod_savepath,plot_on)
% plot_pie_thresholded_mod_index organizes modulation indices across contexts, applies a threshold,
% and produces plots. It then saves the thresholded significant modulation indices.
%
%   Inputs:
%     info          - Structure containing information including a savepath.
%     mod_params    - Structure with modulation parameters, such as:
%                     .mod_type       - (e.g., 'influence', 'ctrl', or 'prepost')
%                     .mod_threshold  - Numeric threshold to apply to the modulation index (0 means no threshold)
%                     .chosen_mice    - Vector of dataset indices to include (e.g., 1:24)
%                     .current_context- (Will be updated within the function; see below)
%     mod_indexm    - Cell array of modulation indices, organized as {dataset x context}.
%                     For example, mod_indexm{m, context} is a vector of modulation indices for dataset m.
%     sig_mod_boot  - Cell array of significant cell indices (from bootstrap), {dataset x context}.
%     sorted_cells  - Data (or a structure) used by the plotting function to order cells.
%       all_celltypes - cell type indices separated by dataset!
%
%   Output:
%     sig_mod_boot_thr - Cell array {dataset x context} containing the thresholded significant
%                        modulation indices (global indices).
%
%   The function does the following for each context:
%     1. Sets the current context (and threshold) in mod_params.
%     2. Concatenates modulation indices across datasets.
%     3. Converts local significant neuron indices to global indices.
%     4. Calls the plotting function (plot_mod_pie_boot) to create a pie chart (or other plot).
%     5. Applies the modulation threshold by keeping only those indices for which the modulation
%        index exceeds the threshold.
%     6. Saves the thresholded results in a file.
%
%   Example usage:
%     sig_mod_boot_thr = process_and_plot_mod_indices(info, mod_params, mod_indexm, sig_mod_boot, sorted_cells);
%
%   Author: Your Name, Date
% Build the save path for modulation results.
% mod_savepath = fullfile(info.savepath, 'mod', mod_params.mod_type);
% Loop over each context (for example, context 1: active, 2: passive, 3: spontaneous).
for context = 1:size(sig_mod_boot,2)
    context
    % Set current context and threshold parameters.
    mod_params.current_context = context;  % update current context
    % mod_params.mod_threshold should already be set (e.g., 0.1). If set to 0, no threshold is applied.

    % Concatenate modulation indices across datasets for this context.
    mod_index_all = cat(2, mod_indexm{:, context}); %{dataset x context}

    % Extract the significant indices and the modulation indices for the current context.
    current_sig = sig_mod_boot(mod_params.chosen_mice, context);
    current_mod_index = mod_indexm(mod_params.chosen_mice, context);
    current_cell_types = all_celltypes(1,mod_params.chosen_mice);

    % Convert local significant neuron indices to global indices.
    % This helper function should take in the significant indices from each dataset and
    % the number of cells per dataset, and then output a global indexing.
    global_sig_ids = convert_indices_local_to_global(current_sig, cellfun(@length, mod_indexm(:, context)),mod_params.chosen_mice);

    % Call the plotting function to plot the distribution (e.g., a pie chart)of modulation indices and might return sorted cell order if needed.
    total_cells_per_celltype = zeros(1,3);
    if plot_on
        total_cells =  sum(cellfun(@length, mod_indexm(mod_params.chosen_mice, context)));
        celltype_fields = fields(all_celltypes{1,1});
        for celtype = 1:length(celltype_fields)
            field_name = celltype_fields{celtype}; % Extract field name as a string
            total_cells_per_celltype(1, celtype) = sum(cellfun(@(x) length(x.(field_name)), all_celltypes(1,mod_params.chosen_mice)));
        end
        sorted_cells = plot_mod_pie_boot(mod_params, sorted_cells, mod_index_all, global_sig_ids, mod_savepath, total_cells_per_celltype);
    end

    % Now, for each dataset, apply the modulation threshold.
    for dataset_index = 1:length(mod_params.chosen_mice)
        %dataset_index = mod_params.chosen_mice(dataset_id);
        % Get the significant cell indices and the modulation indices for the current dataset.
        current_sig_single_dataset = current_sig{dataset_index, 1};  % local indices
        current_mod_index_single_dataset = current_mod_index{dataset_index, 1};

        % Apply the threshold: retain only those cells whose modulation index (for that dataset)
        % exceeds the threshold. (Assumes that higher modulation means more significant.)
        if mod_params.threshold_single_side == 1
            if mod_params.mod_threshold > 0
            sig_mod_boot_thr{dataset_index, context} = [current_sig_single_dataset( current_mod_index_single_dataset(current_sig_single_dataset) > mod_params.mod_threshold )];
            else
            sig_mod_boot_thr{dataset_index, context} = [current_sig_single_dataset( current_mod_index_single_dataset(current_sig_single_dataset) < (mod_params.mod_threshold) )];
            end
        elseif  mod_params.mod_threshold  == 0
            sig_mod_boot_thr{dataset_index, context} = current_sig_single_dataset;
        else
                    sig_mod_boot_thr{dataset_index, context} = [current_sig_single_dataset( current_mod_index_single_dataset(current_sig_single_dataset) > mod_params.mod_threshold ),...
            current_sig_single_dataset( current_mod_index_single_dataset(current_sig_single_dataset) < (mod_params.mod_threshold*-1) )];
           

        end
    end
end
% Save the thresholded significance results.
if ~isempty(mod_savepath)
    save(fullfile(mod_savepath, 'sig_mod_boot_thr.mat'), 'sig_mod_boot_thr');
end
end