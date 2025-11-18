function [all_celltypes] = process_cell_types(mouse_date, server, deconv_st, dff_st)
%load cell types IDs for each dataset and make sure the total numbers match
    all_celltypes = {};
    
    for dataset_id = 1:length(mouse_date)
        current_dataset = mouse_date{dataset_id};
        ss = server{dataset_id};
        
        % Load and validate cell types
        celltypes = load_cell_classifications(ss, current_dataset);
        if ~isempty(celltypes)
            all_celltypes{dataset_id} = celltypes;

            % Validate cell count consistency
            total_sum = numel(all_celltypes{dataset_id}.som_cells) + numel(all_celltypes{dataset_id}.pyr_cells) + numel(all_celltypes{dataset_id}.pv_cells);
            if total_sum == size(deconv_st{dataset_id}.stim, 2) && total_sum == size(dff_st{dataset_id}.stim, 2)
                fprintf('%s: cell numbers are a match!\n', current_dataset);
            else
                fprintf("%s: cell numbers don't match!\n", current_dataset);
            end

        end
    end
end

