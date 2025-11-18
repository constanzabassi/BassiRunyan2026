function mean_mouse_data_celltypes = compute_avg_across_neurons(context_data, sig_mod_boot, con,possible_conditions, alignment,celltype)

for dataset = 1:length(sig_mod_boot)
    imaging = context_data.dff{3, dataset};
    celltypes_permouse = celltype{dataset};
    sig_cells_permouse_temp = find(ismember(sig_mod_boot{dataset},celltypes_permouse));
    sig_cells_permouse = sig_mod_boot{dataset}(sig_cells_permouse_temp);
    if isempty(sig_cells_permouse_temp); continue; end

    if strcmp(alignment.data_type,'z_dff')
        aligned_imaging = imaging.(possible_conditions{con+2})(:,sig_cells_permouse,:);
    else
        aligned_imaging = imaging.(possible_conditions{con})(:,sig_cells_permouse,:);
    end
                                            
    % Save trials used for sorting separately (for each mouse and con)
    mouse_data{dataset,con} = aligned_imaging;
end

mean_mouse_data = {}; mean_mouse_sort= {};
for dataset = 1:length(mouse_data)
    if ~isempty(mouse_data{dataset, con})
        mean_mouse_data{dataset} = squeeze(mean(mouse_data{dataset, con}, 1, 'omitnan'));
    else
        mean_mouse_data{dataset} = nan;  % or skip depending on your logic
    end
end

mean_mouse_data_celltypes = concat_neuron_data(mean_mouse_data);
