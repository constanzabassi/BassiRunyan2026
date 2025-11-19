function mean_mouse_data_celltypes = compute_avg_across_neurons_and_alignment(imaging_st, sig_mod_boot, con, alignment,celltype,active_passive,avg_across_datasets)

for dataset = 1:length(sig_mod_boot)
    imaging = imaging_st{1,dataset};
    [all_conditions, ~] = divide_trials_updated(imaging, alignment.field_to_separate);
    % selected cells = intersection of sig_mod_boot with pool for this celltype/mouse
    pool_ids = celltype{dataset};
    sel_in_pool = find(ismember(sig_mod_boot{dataset}, pool_ids));
    sel_cells   = sig_mod_boot{dataset}(sel_in_pool);
    if isempty(sel_cells), continue; end
    if active_passive == 1
        [ai, af, lp, rp] = find_align_info_updated(imaging, 30);
    else
        [ai, af, lp, rp] = find_align_info_updated(imaging, 30, 2);
    end
    aligned_imaging = align_behavior_data(imaging, ai, af, lp, rp, alignment, sel_cells);

    %get trials in this condition                        
    trials_all = all_conditions{con,1}
    % Save trials used for sorting separately (for each mouse and con)
    mouse_data{dataset,con} = aligned_imaging(trials_all,:,:);
end

mean_mouse_data = {}; 
for dataset = 1:length(mouse_data)
    if ~isempty(mouse_data{dataset, con})
        mean_mouse_data{dataset} = squeeze(mean(mouse_data{dataset, con}, 1, 'omitnan'));
    else
        mean_mouse_data{dataset} = nan;  % or skip depending on your logic
    end
end

if avg_across_datasets
    tmp = cellfun(@(x) mean(x,1), mean_mouse_data, 'UniformOutput', false);
    mean_mouse_data_celltypes = cat(1, tmp{:});   % concatenate along rows
else %average across neurons
    mean_mouse_data_celltypes = concat_neuron_data(mean_mouse_data);
end