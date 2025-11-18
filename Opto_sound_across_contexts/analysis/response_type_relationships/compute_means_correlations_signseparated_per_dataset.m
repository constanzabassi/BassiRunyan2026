function [all_corr_across_celltypes_datasets, all_corr_across_celltypes, ...
          all_means_across_celltypes_datasets, all_std_across_celltypes_datasets, ...
          all_data_celltypes_datasets] = compute_means_correlations_signseparated_per_dataset(sig_mod_boot, all_celltypes, baseline_sound, delta_stim, stim_sound_response)

celltype_fields = fields(all_celltypes{1});
n_celltypes = length(celltype_fields);
n_context = 2;

% compute correlations between baseline and delta, separated by y sign
for ctx = 1:n_context
    for cell_type = 1:n_celltypes+1
        all_x = []; all_y = [];
        
        for dataset_index = 1:length(all_celltypes)
            % Select cells
            if ~isempty(sig_mod_boot)
                if cell_type == n_celltypes+1 % use all cells
                    selected_cells = 1:length(baseline_sound{dataset_index,1});
                else
                    selected_cells = sig_mod_boot{dataset_index}(ismember(sig_mod_boot{dataset_index}, ...
                        all_celltypes{dataset_index}.(celltype_fields{cell_type})));
                end
            else
                if cell_type == n_celltypes+1
                    selected_cells = 1:length(baseline_sound{dataset_index,1});
                else
                    selected_cells = all_celltypes{dataset_index}.(celltype_fields{cell_type});
                end
            end
            
            % Extract data
            x = baseline_sound{dataset_index,ctx}(selected_cells)';
            y = delta_stim{dataset_index,ctx}(selected_cells)';
            z = stim_sound_response{dataset_index,ctx}(selected_cells)';
            
            % Store all for across-dataset correlation
            all_x = [all_x; x(:)];
            all_y = [all_y; y(:)];
            
            % Remove NaNs
            valid_idx = ~isnan(x) & ~isnan(y);
            x = x(valid_idx);
            y = y(valid_idx);
            
            % Split by sign of y
            x_pos = x(y >= 0);
            y_pos = y(y >= 0);
            
            x_neg = x(y < 0);
            y_neg = y(y < 0);
            
            % Compute correlations
            r_pos = NaN; r_neg = NaN;
            if numel(x_pos) > 1 && std(x_pos) > 0 && std(y_pos) > 0
                r_pos = corr(x_pos, y_pos);
            end
            if numel(x_neg) > 1 && std(x_neg) > 0 && std(y_neg) > 0
                r_neg = corr(x_neg, y_neg);
            end
            
            % Save correlations
            all_corr_across_celltypes_datasets{dataset_index,ctx,cell_type,1} = [r_pos];
            all_corr_across_celltypes_datasets{dataset_index,ctx,cell_type,2} = [r_neg];
            
            % Compute means
            all_means_across_celltypes_datasets{dataset_index,ctx,cell_type,1} = mean(x);
            all_means_across_celltypes_datasets{dataset_index,ctx,cell_type,2} = mean(z);
            all_means_across_celltypes_datasets{dataset_index,ctx,cell_type,3} = mean(y);
            
            % Compute std
            all_std_across_celltypes_datasets{dataset_index,ctx,cell_type,1} = std(x);
            all_std_across_celltypes_datasets{dataset_index,ctx,cell_type,2} = std(z);
            all_std_across_celltypes_datasets{dataset_index,ctx,cell_type,3} = std(y);
            
            % Save data
            all_data_celltypes_datasets{dataset_index,ctx,cell_type,1} = x;
            all_data_celltypes_datasets{dataset_index,ctx,cell_type,2} = z;
            all_data_celltypes_datasets{dataset_index,ctx,cell_type,3} = y;
        end
        
        % Compute overall correlation across all datasets for positive and negative y
        x_pos_all = all_x(all_y >= 0);
        y_pos_all = all_y(all_y >= 0);
        
        x_neg_all = all_x(all_y < 0);
        y_neg_all = all_y(all_y < 0);
        
        r_pos_all = NaN; r_neg_all = NaN;
        if numel(x_pos_all) > 1 && std(x_pos_all) > 0 && std(y_pos_all) > 0
            r_pos_all = corr(x_pos_all, y_pos_all);
        end
        if numel(x_neg_all) > 1 && std(x_neg_all) > 0 && std(y_neg_all) > 0
            r_neg_all = corr(x_neg_all, y_neg_all);
        end
        
        all_corr_across_celltypes{ctx,cell_type} = struct( ...
            'r_pos_all', r_pos_all, ...
            'r_neg_all', r_neg_all);
    end
end

end
