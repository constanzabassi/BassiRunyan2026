function [stim_trials_combined, dff_combined] = combine_stim_info_dff_st(stim_info1, stim_info2, dff1, dff2)
% COMBINE_STIM_INFO_DFF_ST vertically stacks two contexts together 
% and keeps track of trial indices while combining dF/F data.
%
% Inputs:
%   stim_info1 - Cell array containing stimulus info for the first context.
%   stim_info2 - Cell array containing stimulus info for the second context.
%   dff1       - Cell array containing dF/F data for the first context.
%   dff2       - Cell array containing dF/F data for the second context.
%
% Outputs:
%   stim_trials_combined - Cell array with combined stimulus trial indices.
%   dff_combined         - Structure array with merged dF/F data.
%
% Author: CB 03/04/2025

stim_trials_combined = {};  % Initialize combined stimulus trials structure

for current_datast = 1:length(stim_info1)
    % Combine stimulus trial indices
    stim_trials_combined{current_datast,1} = [stim_info1{current_datast,1}; stim_info2{current_datast,1}];
    
    % Adjust trial indices to prevent overlap
    stim_trials_combined{current_datast,2} = [stim_info1{current_datast,2}, ...
                                              stim_info2{current_datast,2} + length(stim_info1{current_datast,1})]; %stim trials
    stim_trials_combined{current_datast,3} = [stim_info1{current_datast,3}, ...
                                              stim_info2{current_datast,3} + length(stim_info1{current_datast,1})]; %control trials

    % Combine dF/F data for stimulus and control conditions
    dff_combined{1, current_datast}.stim = [dff1{1, current_datast}.stim; dff2{1, current_datast}.stim];
    dff_combined{1, current_datast}.ctrl = [dff1{1, current_datast}.ctrl; dff2{1, current_datast}.ctrl];

    % Ensure z-scored data exists before merging
    if isfield(dff1{1, current_datast}, 'z_stim') && isfield(dff2{1, current_datast}, 'z_stim')
        dff_combined{1, current_datast}.z_stim = [dff1{1, current_datast}.z_stim; dff2{1, current_datast}.z_stim];
        dff_combined{1, current_datast}.z_ctrl = [dff1{1, current_datast}.z_ctrl; dff2{1, current_datast}.z_ctrl];
    end
end

end
