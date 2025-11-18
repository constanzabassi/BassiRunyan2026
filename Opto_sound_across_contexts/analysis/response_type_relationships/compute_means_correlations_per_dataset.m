function [all_corr_across_celltypes_datasets,all_corr_across_celltypes,all_means_across_celltypes_datasets,all_std_across_celltypes_datasets,all_data_celltypes_datasets] = compute_means_correlations_per_dataset(sig_mod_boot, all_celltypes, baseline_sound, delta_stim, stim_sound_response)


celltype_fields = fields(all_celltypes{1});
n_celltypes = length(celltype_fields);
n_context = 2;

%compute correlations between baseline and delta
for ctx = 1:n_context
    for cell_type = 1:n_celltypes+1
        all_x = []; all_y = [];
        for dataset_index = 1:length(all_celltypes)
            if ~isempty(sig_mod_boot)
                    if cell_type == n_celltypes+1 %use all cells
                        selected_cells = 1:length(baseline_sound{dataset_index,1});
                    else
                        selected_cells = sig_mod_boot{dataset_index}(ismember(sig_mod_boot{dataset_index}, ...
                            all_celltypes{dataset_index}.(celltype_fields{cell_type})));
                    end

            else
                if cell_type == n_celltypes+1 %use all cells
                    selected_cells = 1:length(baseline_sound{dataset_index,1});
                else
                    if size(all_celltypes,1) > 1 %assumes it is separated by context!
                        selected_cells = all_celltypes{ctx,dataset_index}.(celltype_fields{cell_type});
                    else
                        selected_cells = all_celltypes{dataset_index}.(celltype_fields{cell_type});
                    end
                end
            end
            
            x = baseline_sound{dataset_index,ctx}(selected_cells)';
            y = delta_stim{dataset_index,ctx}(selected_cells)';
            z = stim_sound_response{dataset_index,ctx}(selected_cells)';

            all_x = [all_x; x(:)];
            all_y = [all_y; y(:)];

                    % Remove NaNs
            valid_idx = ~isnan(x) & ~isnan(y);
            x = x(valid_idx);
            y = y(valid_idx);
            
            %compute correlation between baseline and delta opto
            if ~isempty(x) && std(x) > 0 && std(y) > 0
                r = corr(x, y);
%                 cv = cov(zscore(x), zscore(y));
%                 r = cv(1,2)/var(zscore(y));
%                 x_centered = x - mean(x);
%                 y_centered = y - mean(y);
%                 cv = mean(x_centered .* y_centered);     % manual covariance
%                 v = var(y);                              % variance of y
%                 r = cv / v;

                if r == 1 || r == -1 %only 2 values
                    r = nan;
                end
                sem = std(x) / sqrt(length(x));  % SEM of baseline for now
            else
                r = NaN;
                sem = NaN;
            end

            all_corr_across_celltypes_datasets{dataset_index,ctx,cell_type} = r; %[all_x_across_celltypes;all_x];
            %compute means
            all_means_across_celltypes_datasets{dataset_index,ctx,cell_type,1} = mean(x); % sound (baseline)
            all_means_across_celltypes_datasets{dataset_index,ctx,cell_type,2} = mean(z); % stim+sound
            all_means_across_celltypes_datasets{dataset_index,ctx,cell_type,3} = mean(y); % stim+sound - sound
            %compute std
            all_std_across_celltypes_datasets{dataset_index,ctx,cell_type,1} = std(x); % sound (baseline)
            all_std_across_celltypes_datasets{dataset_index,ctx,cell_type,2} = std(z); % stim+sound
            all_std_across_celltypes_datasets{dataset_index,ctx,cell_type,3} = std(y); % stim+sound - sound

            all_data_celltypes_datasets{dataset_index,ctx,cell_type,1} = x; % sound (baseline)
            all_data_celltypes_datasets{dataset_index,ctx,cell_type,2} = z; % stim+sound
            all_data_celltypes_datasets{dataset_index,ctx,cell_type,3} = y; % stim+sound - sound

        end
        r2 = corr(all_x, all_y);
        sem = std(all_x) / sqrt(length(all_x));
        all_corr_across_celltypes{ctx,cell_type} = r2;
        
        
    end

end
end
