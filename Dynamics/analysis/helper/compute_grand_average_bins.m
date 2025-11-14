function [binned_data_all, adjusted_onsets, nan_positions, num_nans, binss] = ...
    compute_grand_average_bins(imaging_st, alignment, bin_size, sig_cells)
% Computes mice × celltype × time binned means
% use_selected_cells: optional logical; if true, alignment.cells contains the actual indices to use per mouse
num_celltypes = 3;
num_mice = size(imaging_st, 2);
binned_data_all = [];
% derive bins by probing first dataset
[ai0, af0, lp0, rp0] = find_align_info_updated(imaging_st{1,1}, 30);
aligned0 = align_behavior_data(imaging_st{1,1}, ai0, af0, lp0, rp0, alignment, 1:10);
T = size(aligned0, 3);
binss = 1:bin_size:(T - bin_size);
% onsets & NaN insertion locations (binned space)
event_onsets = determine_onsets(lp0, rp0, alignment.number);
new_onsets = find(histcounts(event_onsets, binss));
num_nans = 2;
if numel(event_onsets) > 4
    adjusted_onsets = new_onsets;
    nan_positions = find(histcounts(101, binss));
    for i = 1:length(nan_positions)
        adjusted_onsets(adjusted_onsets > nan_positions(i)) = ...
            adjusted_onsets(adjusted_onsets > nan_positions(i)) + num_nans - 1;
    end
else
    adjusted_onsets = new_onsets;
    nan_positions = [];
end
% compute
for m = 1:num_mice
    for ce = 1:num_celltypes
        celltype_m = alignment.cells{ce, m};
        imaging    = imaging_st{1, m};
        [all_conditions, ~] = divide_trials_updated(imaging, alignment.field_to_separate);
        [align_info, alignment_frames, left_pad, right_pad] = find_align_info_updated(imaging, 30);
        
        if ~isempty(sig_cells)
            celltypes_permouse = celltype_m;
            sig_cells_permouse_temp = find(ismember(sig_cells{m},celltypes_permouse));
            sig_cells_permouse = sig_cells{m}(sig_cells_permouse_temp);
            aligned = align_behavior_data(imaging, align_info, alignment_frames, left_pad, right_pad, alignment, sig_cells_permouse);
        else
            [aligned] = align_behavior_data (imaging,align_info,alignment_frames,left_pad,right_pad,alignment,celltype_m);
        end
        
        for b = 1:length(binss)
            fr = binss(b):binss(b)+bin_size-1;
            if ~isempty(alignment.conditions) && length(alignment.conditions) >= 1
                trials = cat(1, all_conditions{alignment.conditions,1});
                binned_data(ce,b) = mean(aligned(trials,:,fr), 'all', 'omitnan');
            else
                binned_data(ce,b) = mean(aligned(:,:,fr),      'all', 'omitnan');
            end
        end
    end
    binned_data_all(m,:,:) = binned_data; %
end
end