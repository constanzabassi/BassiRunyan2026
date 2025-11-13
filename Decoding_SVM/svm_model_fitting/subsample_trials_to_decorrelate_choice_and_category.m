function selected_trials = subsample_trials_to_decorrelate_choice_and_category(condition_array_trials)

% empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
% good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
% imaging_array = [imaging(good_trials).virmen_trial_info]; %convert to array for easier indexing


selected_trials = false(1, length(condition_array_trials));
correctness = condition_array_trials(:,2);
left_choice_ness = condition_array_trials(:,3);

% find out left/correct, left/incorrect, right/correct,
% right/incorrect trials in the fitting subset
lc = left_choice_ness & correctness;
li = left_choice_ness & ~correctness;
rc = ~left_choice_ness & correctness;
ri = ~left_choice_ness & ~correctness;
% make sure that each of these groups is equally represented in
% the training trials, to ensure that stimulus category and
% behavioural choice are uncorrelated.
smallest_set_size = min([nnz(lc), nnz(li), nnz(rc), nnz(ri)]);
lc_selected = randsample(find(lc), smallest_set_size);
li_selected = randsample(find(li), smallest_set_size);
rc_selected = randsample(find(rc), smallest_set_size);
ri_selected = randsample(find(ri), smallest_set_size);
selected_trials(lc_selected) = true;
selected_trials(li_selected) = true;
selected_trials(rc_selected) = true;
selected_trials(ri_selected) = true;
 
smallest_set_size
end
