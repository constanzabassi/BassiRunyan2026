function sorting_id_updated_datasets = get_sorting_indices_only(imaging_st, alignment, bin_size, sig_mod_boot, active_passive)

% OUTPUT:
% sorting_id_updated_datasets{con, ce} = sorting index for that condition (con)
% and celltype (ce). If no conditions, it's {1, ce}.

% This is pulled from heatmaps_avg_combined_selected_cells but with all plotting removed.

%% alignment info setup (same as original)
if active_passive == 1
    [align_info,alignment_frames,left_padding,right_padding] = ...
        find_align_info_updated(imaging_st{1,1},30);
else
    [align_info,alignment_frames,left_padding,right_padding] = ...
        find_align_info_updated(imaging_st{1,1},30,2);
end

% align once just to get dims
[aligned_imaging] = align_behavior_data( ...
    imaging_st{1,1},align_info,alignment_frames,left_padding,right_padding,alignment,1:10);

binss = 1:bin_size:size(aligned_imaging,3)-bin_size;
num_nans = 2;

% find event onsets if using bins (you used this to shift/insert NaNs)
event_onsets = determine_onsets(left_padding,right_padding,alignment.number);
new_onsets   = find(histcounts(event_onsets,binss));
if length(event_onsets) > 4
    adjusted_event_onsets = new_onsets;
    nan_insert_positions = [find(histcounts(101,binss))];
    for i = 1:length(nan_insert_positions)
        shift = num_nans * i;
        adjusted_event_onsets(adjusted_event_onsets >= nan_insert_positions(i)) = ...
            adjusted_event_onsets(adjusted_event_onsets >= nan_insert_positions(i)) + num_nans - 1;
    end
else
    adjusted_event_onsets = new_onsets;
    nan_insert_positions = [];
end

%% loop over mice to compute binned_data_all like before
for m = 1:length(sig_mod_boot)
    for ce = 1:3
        celltype = {alignment.cells{ce,:}};
        imaging  = imaging_st{1,m};

        [all_conditions, ~] = divide_trials_updated(imaging,alignment.field_to_separate);
        celltypes_permouse = celltype{m};
        sig_cells_permouse_temp = find(ismember(sig_mod_boot{m},celltypes_permouse));
        sig_cells_permouse = sig_mod_boot{m}(sig_cells_permouse_temp);

        if active_passive == 1
            [align_info,alignment_frames,left_padding,right_padding] = ...
                find_align_info_updated(imaging,30);
        else
            [align_info,alignment_frames,left_padding,right_padding] = ...
                find_align_info_updated(imaging,30,2);
        end

        [aligned_imaging_mouse] = align_behavior_data( ...
            imaging,align_info,alignment_frames,left_padding,right_padding,alignment,sig_cells_permouse);

        % bin across time like original
        for b = 1:length(binss)
            if length(alignment.conditions) >= 1
                for con = 1:length(alignment.conditions)
                    con_trials = all_conditions{alignment.conditions(con),1};
                    binned_data(con,ce,b) = squeeze(mean( ...
                        aligned_imaging_mouse(con_trials,:,binss(b):binss(b)+bin_size-1), ...
                        [1,2,3]));
                end
            else
                binned_data(ce,b) = squeeze(mean( ...
                    aligned_imaging_mouse(:,:,binss(b):binss(b)+bin_size-1), ...
                    [1,2,3]));
            end
        end
    end

    if length(alignment.conditions) >= 1
        binned_data_all(m,:,:,:) = binned_data;
    else
        binned_data_all(m,:,:)   = binned_data;
    end
end

%% Now compute sorting indices for each condition / celltype with your trial-halving logic
sorting_id_updated_datasets = {};

if length(alignment.conditions) >= 1
    % multiple conditions case
    for con_i = 1:length(alignment.conditions)
        for ce = 1:3

            % collect mean activity per mouse for this (condition, celltype)
            mean_mouse_data = {};
            mean_mouse_sort = {};

            for m = 1:length(sig_mod_boot)
                imaging = imaging_st{1,m};
                [all_conditions, ~] = divide_trials_updated(imaging,alignment.field_to_separate);

                celltype = {alignment.cells{ce,:}};
                celltypes_permouse = celltype{m};
                sig_cells_permouse_temp = find(ismember(sig_mod_boot{m},celltypes_permouse));
                sig_cells_permouse = sig_mod_boot{m}(sig_cells_permouse_temp);
                if isempty(sig_cells_permouse_temp); continue; end

                if active_passive == 1
                    [align_info,alignment_frames,left_padding,right_padding] = ...
                        find_align_info_updated(imaging,30);
                else
                    [align_info,alignment_frames,left_padding,right_padding] = ...
                        find_align_info_updated(imaging,30,2);
                end

                [aligned_imaging_mouse,~] = align_behavior_data( ...
                    imaging,align_info,alignment_frames,left_padding,right_padding,alignment,sig_cells_permouse);

                % take only trials for this condition
                trials_all = all_conditions{alignment.conditions(con_i),1};
                n_trials   = length(trials_all);

                rng(1); % keep same behavior you had
                perm  = randperm(n_trials);
                half  = floor(n_trials/2);

                trials_sort = trials_all(perm(1:half));
                trials_plot = trials_all(perm(half+1:end)); %#ok<NASGU> (not used here now)

                mouse_data_sort = aligned_imaging_mouse(trials_sort,:,:);

                % average across sorting trials
                mean_mouse_sort{m} = squeeze(mean(mouse_data_sort,1,'omitnan'));
                % (your old code did squeeze(mean(mouse_data_sort,1)) without omitnan on one branch,
                % using omitnan here is safe / consistent with other averaging)
            end

            % concatenate neurons across mice (concat_neuron_data)
            sorting_data = concat_neuron_data(mean_mouse_sort);

            % get peak time per neuron
            [~, sorting_peaks] = max(sorting_data, [], 2);
            [~, sorting_id_updated] = sort(sorting_peaks, 'ascend');

            sorting_id_updated_datasets{con_i, ce} = sorting_id_updated;
        end
    end

else
    % no explicit conditions case
    con_i = 1;
    for ce = 1:3
        mean_mouse_sort = {};

        for m = 1:length(sig_mod_boot)
            imaging = imaging_st{1,m};
            [~, ~] = divide_trials_updated(imaging,alignment.field_to_separate);

            celltype = {alignment.cells{ce,:}};
            celltypes_permouse = celltype{m};
            sig_cells_permouse_temp = find(ismember(sig_mod_boot{m},celltypes_permouse));
            sig_cells_permouse = sig_mod_boot{m}(sig_cells_permouse_temp);
            if isempty(sig_cells_permouse_temp); continue; end

            if active_passive == 1
                [align_info,alignment_frames,left_padding,right_padding] = ...
                    find_align_info_updated(imaging,30);
            else
                [align_info,alignment_frames,left_padding,right_padding] = ...
                    find_align_info_updated(imaging,30,2);
            end

            [aligned_imaging_mouse,~] = align_behavior_data( ...
                imaging,align_info,alignment_frames,left_padding,right_padding,alignment,sig_cells_permouse);

            trials_all = 1:size(aligned_imaging_mouse,1);
            n_trials   = length(trials_all);

            rng(1);
            perm  = randperm(n_trials);
            half  = floor(n_trials/2);

            trials_sort = trials_all(perm(1:half));
            mouse_data_sort = aligned_imaging_mouse(trials_sort,:,:);

            mean_mouse_sort{m} = squeeze(mean(mouse_data_sort,1,'omitnan'));
        end

        sorting_data = concat_neuron_data(mean_mouse_sort);

        [~, sorting_peaks] = max(sorting_data, [], 2);
        [~, sorting_id_updated] = sort(sorting_peaks, 'ascend');

        sorting_id_updated_datasets{con_i, ce} = sorting_id_updated;
    end
end

end
