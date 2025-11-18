function [all_exp, all_nonexp, updated_context_trials] = get_valid_stim_onsets_trials(info)
% GET_VALID_STIM_ONSETS_TRIALS extracts and validates stimulation onset trials 
% for both control and optogenetic conditions, ensuring they align with imaging data.
%
%   Inputs:
%     info         - Structure containing dataset information:
%                      .mouse_date : Cell array of dataset identifiers (dates).
%                      .serverid   : Cell array of server locations.
%                      .savepath   : Base directory for saving processed results.
%
%   Outputs:
%     all_exp                 - Combined list of valid experimental trials across datasets.
%     all_nonexp              - Combined list of valid non-experimental (control) trials.
%     updated_context_trials  - Cell array organizing trials by context:
%                               {context_num,1} -> Valid experimental trials.
%                               {context_num,2} -> Valid non-experimental trials.
%                               {context_num,3} -> Adjusted trial indices for experimental.
%                               {context_num,4} -> Adjusted trial indices for non-experimental.
%
%   Processing Steps:
%     1. Load relevant dataset files (trial data, alignment info, imaging data).
%     2. Identify valid trials based on imaging availability.
%     3. Extract control and opto trial indices.
%     4. Ensure sound-only trials are included.
%     5. Update trial structures and save processed results.
%
%   Author: CB, 2/24/25


% Track trial counts across contexts
lengths_exp_nonexp = zeros(2,3);

% Define context types
context_types = {'active', 'passive'};

% Iterate through each dataset
for dataset_index = 1:length(info.mouse_date)
    fprintf('Processing dataset %d/%d...\n', dataset_index, length(info.mouse_date));

    % Initialize output variables
    all_exp = [];
    all_nonexp = [];
    updated_context_trials = {};

    
    % Define dataset path
    ss = info.serverid{dataset_index};
    base_path = fullfile(num2str(ss), 'Connie', 'ProcessedData', info.mouse_date{dataset_index});
    
    % --- Load required data files ---
    load(fullfile(base_path, 'context_stim', '60', 'context_tr.mat')); % Trial context separation
    load(fullfile(base_path, 'context_stim', '60', 'bad_frames.mat'));  % Frames with artifacts
    exp = load(fullfile(base_path, 'context_stim', '60', 'exp.mat')).exp;
    nonexp = load(fullfile(base_path, 'context_stim', '60', 'nonexp.mat')).nonexp;

    % Process each context type separately
    for context_type = context_types
        % Determine numeric context identifier
        context_num = strcmpi(context_type, 'passive') + 1;

        % --- Extract Control and Opto Trials ---
        alignment_frames = bad_frames;  % Use bad frames as alignment reference
        
        % Load alignment info for trial events
        load(fullfile(base_path, 'alignment_info.mat'));

        % Select imaging data based on context type
        if strcmpi(context_type, 'passive')
            load(fullfile(base_path, 'passive', 'imaging.mat'));
        else
            load(fullfile(base_path, 'VR', 'imaging.mat'));
        end

        % Determine imaging file frame lengths
        frame_lengths = cellfun(@length, {alignment_info.frame_times});
        frame_lengths = [0, cumsum(frame_lengths)];

        % Identify valid trials with available imaging data
        empty_trials = find(cellfun(@isempty, {imaging.good_trial}));
        good_trials = setdiff(1:length(imaging), empty_trials);

        % Extract alignment frames for trial events
        if strcmpi(context_type, 'passive')
            [~, alignment_frames_single_mouse, ~, ~] = find_align_info(imaging, 30, 2);
        else
            [~, alignment_frames_single_mouse, ~, ~] = find_align_info(imaging, 30);
        end

        % --- Validate and Filter Trials Based on Imaging Data ---
        trials_with_imaging = [];
        count2 = 0;

        % Process experimental (opto) trials
        for trial = good_trials
            count2 = count2 + 1;
            frames_to_add = alignment_frames_single_mouse(1, count2) + frame_lengths(imaging(trial).file_num) - 1;
            if strcmpi(context_type, 'passive')
                frames_to_add = alignment_frames_single_mouse(1, count2);
            end
            trials_with_imaging = [trials_with_imaging, find(abs(imaging(trial).frame_id(1) + frames_to_add - alignment_frames(exp, 1)) < 3)];
        end
        new_exp = exp(trials_with_imaging);
        all_exp = [all_exp, new_exp];

        % Process non-experimental (control) trials
        trials_with_imaging = [];
        count2 = 0;
        for trial = good_trials
            count2 = count2 + 1;
            frames_to_add = alignment_frames_single_mouse(1, count2) + frame_lengths(imaging(trial).file_num) - 1;
            if strcmpi(context_type, 'passive')
                frames_to_add = alignment_frames_single_mouse(1, count2);
            end
            trials_with_imaging = [trials_with_imaging, find(abs(imaging(trial).frame_id(1) + frames_to_add - alignment_frames(nonexp, 1)) < 3)];
        end
        new_nonexp = nonexp(trials_with_imaging);
        all_nonexp = [all_nonexp, new_nonexp];

        % Update trial count records
        lengths_exp_nonexp(1, context_num+1) = length(new_exp);
        lengths_exp_nonexp(2, context_num+1) = length(new_nonexp);

        % Compute cumulative trial sums
        exp_sums = cumsum(lengths_exp_nonexp(1, :));
        nonexp_sums = cumsum(lengths_exp_nonexp(2, :));

        % --- Update Context Trial Structure ---
        updated_context_trials{context_num, 1} = new_exp;
        updated_context_trials{context_num, 2} = new_nonexp;
        updated_context_trials{context_num, 3} = (1:length(new_exp)) + exp_sums(context_num);
        updated_context_trials{context_num, 4} = (1:length(new_nonexp)) + nonexp_sums(context_num);
    end

    % --- Process Spontaneous Context ---
    context_num = 3;
    updated_context_trials{context_num, 1} = context_tr{context_num, 1};
    updated_context_trials{context_num, 2} = context_tr{context_num, 2};
    updated_context_trials{context_num, 3} = (1:length(context_tr{context_num, 1})) + exp_sums(context_num);
    updated_context_trials{context_num, 4} = (1:length(context_tr{context_num, 2})) + nonexp_sums(context_num);

    all_exp = [all_exp, context_tr{context_num, 1}];
    all_nonexp = [all_nonexp, context_tr{context_num, 2}];

    % --- Save Processed Data ---
    outdir = fullfile(base_path, 'context_stim', 'updated');
    if ~exist(outdir, 'dir')
        mkdir(outdir);
    end

    %update variables with valid variables
    exp = all_exp;
    nonexp = all_nonexp;
    save(fullfile(outdir, 'exp.mat'), 'exp');
    save(fullfile(outdir, 'nonexp.mat'), 'nonexp');
    context_tr = updated_context_trials;
    save(fullfile(outdir, 'context_tr.mat'), 'context_tr');
    save(fullfile(outdir, 'bad_frames.mat'), 'bad_frames');

    clear exp nonexp bad_frames context_tr

end

end

