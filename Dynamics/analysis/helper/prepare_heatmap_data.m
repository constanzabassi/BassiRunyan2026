function [data_out, adjusted_onsets] = prepare_heatmap_data(data, left_pad, right_pad, align_number)
% Inserts NaN gaps and adjusts onset markers
% data: neurons × time (after per-mouse concat)
event_onsets = determine_onsets(left_pad, right_pad, align_number);
adjusted_onsets = event_onsets;
data_out = data;
if numel(event_onsets) > 4
    num_nans = 2;
    nan_pos  = 101;
    data_out = include_nans(data_out, num_nans, nan_pos);
    mask = adjusted_onsets > nan_pos;
    adjusted_onsets(mask) = adjusted_onsets(mask) + num_nans - 1;
end
end