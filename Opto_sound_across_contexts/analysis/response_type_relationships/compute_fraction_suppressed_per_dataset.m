function [fraction_suppressed, fraction_activated] = compute_fraction_suppressed_per_dataset(sig_mod_boot, all_celltypes, delta_stim)

celltype_fields = fields(all_celltypes{1});
n_celltypes = length(celltype_fields);
n_context = 2;
n_datasets = length(all_celltypes);

fraction_suppressed = cell(n_datasets, n_context, n_celltypes+1);
fraction_activated = cell(n_datasets, n_context, n_celltypes+1);
for ctx = 1:n_context
    for cell_type = 1:n_celltypes+1
        for dataset_index = 1:length(all_celltypes)
            if ~isempty(sig_mod_boot)
                if cell_type == n_celltypes+1 % all cells
                    selected_cells = 1:length(delta_stim{dataset_index,ctx});
                else
                    selected_cells = sig_mod_boot{dataset_index}(ismember(sig_mod_boot{dataset_index}, ...
                        all_celltypes{dataset_index}.(celltype_fields{cell_type})));
                end
            else
                if cell_type == n_celltypes+1 % all cells
                    selected_cells = 1:length(delta_stim{dataset_index,ctx});
                else
                    selected_cells = all_celltypes{dataset_index}.(celltype_fields{cell_type});
                end
            end

            if isempty(selected_cells)
                continue
            end

            delta_values = delta_stim{dataset_index,ctx}(selected_cells);
            delta_values = delta_values(~isnan(delta_values));

            if isempty(delta_values)
                continue
            end
            threshold = 0.0;
            fraction_suppressed{dataset_index, ctx, cell_type} = sum(delta_values < threshold*-1) / length(delta_values);
            fraction_activated{dataset_index, ctx, cell_type} = sum(delta_values > threshold) / length(delta_values);
        end
    end
end
end
