function out = process_mouse_data(imaging, alignment, cell_ids, conditions)
% Returns:
%   out.sort_data : trials_sort × neurons × time
%   out.plot_data : neurons × time (mean over trials_plot)
%   out.plot_data_per_condition : trials_plot × neurons × time
%   out.left_pad, out.right_pad : alignment paddings used
if nargin < 4, conditions = []; end
% divide trials if conditions used
if ~isempty(conditions)
    [all_conditions, ~] = divide_trials_updated(imaging, alignment.field_to_separate);
    use_trials = cat(1, all_conditions{conditions,1});
else
    empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
    good_trials  = setdiff(1:length(imaging), empty_trials);
    use_trials   = 1:length(good_trials);
end
% alignment info + aligned data
[align_info, alignment_frames, left_pad, right_pad] = find_align_info_updated(imaging, 30);
aligned = align_behavior_data(imaging, align_info, alignment_frames, left_pad, right_pad, alignment, cell_ids);
% split trials: half for sorting, half for plotting
rng(1);
perm = randperm(length(use_trials));
half = floor(length(use_trials)/2);

if half == 0, half = max(1, floor(length(use_trials)/2)); end
trials_sort = use_trials(perm(1:half));
trials_plot = use_trials(perm(half+1:end));

if isempty(trials_plot), trials_plot = use_trials(perm(1:half)); end
out.sort_data             = aligned(trials_sort,:,:);
out.plot_data             = squeeze(mean(aligned(trials_plot,:,:), 1));
out.plot_data_per_condition = aligned(trials_plot,:,:);
out.left_pad = left_pad;
out.right_pad = right_pad;
end