function [left_stim_all_updated, left_ctrl_all_updated,  right_stim_all_updated, right_ctrl_all_updated] = find_overlap_trials (left_stim_all, left_ctrl_all,  right_stim_all, right_ctrl_all, stim_to_match,ctrl_to_match)
% from all trials find ones that match selected trials

left_stim_all_updated = left_stim_all(find(ismember(left_stim_all,stim_to_match)));
left_ctrl_all_updated = left_ctrl_all(find(ismember(left_ctrl_all,ctrl_to_match)));
right_stim_all_updated = right_stim_all(find(ismember(right_stim_all,stim_to_match)));
right_ctrl_all_updated = right_ctrl_all(find(ismember(right_ctrl_all,ctrl_to_match)));