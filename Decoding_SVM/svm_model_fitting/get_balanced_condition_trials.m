function [selected_trials,lc_selected,rc_selected] = get_balanced_condition_trials(imaging)
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!


selected_trials = false(1, length(good_trials));
virmen_trial_info = [imaging(good_trials).virmen_trial_info];
condition = [virmen_trial_info.condition];

unique_cond = unique(condition);
for c = 1:length(unique_cond)
    conds{c} = find(condition == unique_cond(c));
end


% make sure that each of these groups is equally represented in
% the training trials, to ensure that stimulus category and
% behavioural choice are uncorrelated.
smallest_set_size = min(cellfun(@length ,conds));
lc_selected = randsample(conds{1}, smallest_set_size);
rc_selected = randsample(conds{2}, smallest_set_size);
selected_trials(lc_selected) = true;
selected_trials(rc_selected) = true;
 
smallest_set_size
end