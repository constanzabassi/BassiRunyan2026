function [control_output, opto_output, excludedIndices, control_output_bad_frames, opto_output_bad_frames] = find_control_opto_relative_to_bad_frames(passive_frames, bad_frames, context_tr, context_num)
% FIND_CONTROL_opto_relative_to_FRAMES identifies trial indices for control and opto conditions 
% based on corrected frame information.
%
%   Inputs:
%     passive_frames - Structure containing trial information including:
%                      .corr_frames: [nTrials x ?] matrix of corrected frame numbers.
%                      .trial_num  : Vector of trial numbers.
%     bad_frames     - Cell array containing bad frame indices.
%     context_tr     - Cell array where each row corresponds to a context. 
%                      The first column contains indices for opto trials, and 
%                      the second column for control trials.
%     context_num    - Scalar specifying which row of context_tr to use.
%
%   Outputs:
%     control_output            - Sorted vector of trial indices (from passive_frames)
%                                 that correspond to control conditions.
%     opto_output               - Sorted vector of trial indices (from passive_frames)
%                                 that correspond to opto conditions.
%       extra_output            - Sorted vector of trial indices that
%                                   include bad frames that were excluded (i.e. markpoint early triggers or not having full imaging trials)
%     control_output_bad_frames - Sorted vector of indices (into bad_frames) for control.
%     opto_output_bad_frames    - Sorted vector of indices (into bad_frames) for opto.
%
%   The function performs the following:
%     1. Loops over a set of shifts (1:3) and for each shift, adjusts the corrected
%        frame numbers by adding (1 - shift).
%     2. Finds the indices in these adjusted frame numbers that appear in the bad_frames
%        for control (using context_tr{context_num,2}) and opto (using context_tr{context_num,1}).
%     3. Sorts and returns the indices from passive_frames as well as the corresponding
%        indices from bad_frames.
%
%   Author: Your Name, Date

%get excluded bad_frames
min_frames_current_context = min(passive_frames.corr_frames(:,1));
max_frames_current_context = max(passive_frames.corr_frames(:,2));
last_value = find([bad_frames(:,2) - max_frames_current_context]>=0);
first_value = find([bad_frames(:,1) - min_frames_current_context]>=0);
bad_frames_within_context = [first_value(1):last_value(1)-1];
all_trials_current_context = [context_tr{context_num,1},context_tr{context_num,2}];
excluded_trials = setdiff(bad_frames_within_context,all_trials_current_context)'; %excluded for different reasons like not having full imaging trials!


% Initialize containers for indices found from passive_frames.
controlIndices = [];
optoIndices = [];
excludedIndices = [];

% Loop over shifts (1 to 3).
for shift = 1:4
    % Adjust corrected frame numbers by subtracting (shift-1) 
    % (i.e. adding 1-shift).
    adjustedFrames = passive_frames.corr_frames(:,1) + 2 - shift;
    
    % Find indices in adjustedFrames that are present in bad_frames for control.
    % context_tr{context_num,2} are the indices to use for control.
    controlIndices = [controlIndices; find(ismember(adjustedFrames, bad_frames(context_tr{context_num,2})))];
    
    % Similarly, for opto (context_tr{context_num,1}).
    optoIndices = [optoIndices; find(ismember(adjustedFrames, bad_frames(context_tr{context_num,1})))];

    %do it for exclulded trials too
    excludedIndices = [excludedIndices; find(ismember(adjustedFrames,bad_frames(excluded_trials)))];
end

% Sort the trial indices (from passive_frames) for control and opto.
control_output = sort(controlIndices);
opto_output = sort(optoIndices);

% Now, for the corresponding indices in bad_frames, do the reverse:
controlBadIndices = [];
optoBadIndices = [];
for shift = 1:4
    % Again, adjust the corrected frames.
    adjustedFrames = passive_frames.corr_frames(:,1) + 2 - shift;
    
    % For control: find indices in bad_frames (using context_tr{context_num,2})
    % that are members of the adjustedFrames.
    controlBadIndices = [controlBadIndices, find(ismember(bad_frames(context_tr{context_num,2}), adjustedFrames))];
    
    % For opto: do the same using context_tr{context_num,1}.
    optoBadIndices = [optoBadIndices, find(ismember(bad_frames(context_tr{context_num,1}), adjustedFrames))];
end

% Sort the indices from bad_frames and output as column vectors.
control_output_bad_frames = sort(controlBadIndices)';
opto_output_bad_frames = sort(optoBadIndices)';



end
