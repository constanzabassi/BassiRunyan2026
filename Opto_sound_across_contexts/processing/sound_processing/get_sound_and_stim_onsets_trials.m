function [sound_onsets_all, alignment_frames_all, control_output_all, opto_output_all, sound_only_all, loc_trial, extra_sound_frames_all] = get_sound_and_stim_onsets_trials(info, context_type, savepath, compute_extra_sounds)
% GET_SOUND_AND_STIM_ONSETS_TRIALS extracts sound onset frames, alignment frames, and trial indices 
% for control and opto conditions from processed data for each dataset.
%
%   Inputs:
%     info         - Structure containing dataset information, including:
%                      .mouse_date : cell array of dataset dates.
%                      .serverid   : cell array of server IDs.
%                      .savepath   : base directory for saving results.
%     context_type - String indicating the context type (e.g., 'passive', 'active').
%     savepath     - (Optional) Directory where the output variables will be saved.
%
%   Outputs:
%     sound_onsets_all     - Cell array; for each dataset, a vector of sound onset frames.
%     alignment_frames_all - Cell array; for each dataset, an [nTrials x 2] matrix with alignment frames.
%     control_output_all   - Cell array; for each dataset, vector of control trial indices.
%     opto_output_all      - Cell array; for each dataset, vector of opto trial indices.
%     opto_output_all      - Cell array; for each dataset, vector of sound only trial indices. 
%     loc_trial            - Cell array; for each dataset, for each sound
%                               location- save the trial?
%
%   The function:
%     1. Constructs the base path for each dataset and loads necessary files.
%     2. Selects the correct trial/frame variable based on context_type.
%     3. Checks that each trial has 3 repeats; if not, identifies excluded trials.
%     4. Determines the context number (e.g., 2 for 'passive').
%     5. Extracts control and opto trial indices via find_control_frames.
%     6. Identifies "sound only" trials (trials that contain sound but no stimulation).
%     7. Sets up alignment frames based on the corrected frames in frames_var.
%     8. Replaces alignment frames for control trials with values from bad_frames.
%
%     **extra step: make sure to use indices from imaging spk good trials
%     (taken from all_trial_info . matched_ids (relative to bad frames))
%
%     9. Saves the outputs if a save path is provided.
%
%   Author: CB, 2/18/25
% Optional:
%   compute_extra_sounds - if true, also computes first/second/third sound
%                          frame locations from alignment_frames_single_mouse
%
% Extra output:
%   extra_sound_frames_all - Cell array; for each dataset, a 3 x nTrials matrix:
%                              row 1 = first sound
%                              row 2 = second sound
%                              row 3 = third sound


if nargin < 4 || isempty(compute_extra_sounds)
    compute_extra_sounds = false;
end

% Preallocate output cell arrays.
sound_onsets_all = cell(1, length(info.mouse_date));
alignment_frames_all = cell(1, length(info.mouse_date));
control_output_all = cell(1, length(info.mouse_date));
opto_output_all = cell(1, length(info.mouse_date));
sound_only_all = cell(1, length(info.mouse_date));
extra_sound_frames_all = cell(1, length(info.mouse_date));


sound_onsets_all_2 = cell(1, length(info.mouse_date));
sound_onsets_all_3 = cell(1, length(info.mouse_date));

total_sound_locations = 2;
loc_trial = cell(length(info.mouse_date), total_sound_locations);

% Loop through each dataset.
for dataset_index = 1:length(info.mouse_date)

    fprintf('Processing dataset %d/%d...\n', dataset_index, length(info.mouse_date));

    ss = info.serverid{dataset_index};
    base_path = fullfile(num2str(ss), 'Connie', 'ProcessedData', info.mouse_date{dataset_index});
    
    %%% 1) Load Data %%%
    load(fullfile(base_path, 'context_stim', 'updated', 'context_tr.mat'));
    load(fullfile(base_path, 'context_stim', 'updated', 'bad_frames.mat'));
    
    %%% 2) Select Appropriate Frames Variable %%%
    if strcmpi(context_type, 'passive')

        load(fullfile(base_path, context_type, [context_type '_frames.mat']));
        load('V:\Connie\results\opto_sound_2025\context\sound_info\passive_all_trial_info.mat');

        frames_var = passive_frames;
        passive_sounds = {};

    elseif strcmpi(context_type, 'active')

        load(fullfile(base_path, 'VR', ['vr_sound_frames.mat']));
        load('V:\Connie\results\opto_sound_2025\context\sound_info\active_all_trial_info.mat');

        frames_var = vr_sound_frames;
        active_sounds = {};

    else

        frames_var = [];
        warning('Context type "%s" not explicitly handled. Proceeding with empty frames variable.', context_type);

    end
    
    %%% 3) Check Trial Repeats %%%
    if strcmpi(context_type, 'passive')

        rem_3 = rem(length(frames_var.trial_num), frames_var.trial_num(end));

        if rem_3 > 0

            fprintf('Dataset %d has excluded trials\n', dataset_index);

            temp = []; 
            unique_trials = unique(frames_var.trial_num);

            for n = 1:length(unique_trials)
                a = find(frames_var.trial_num == unique_trials(n));
                temp = [temp, length(a)];
            end

            [~, locs_not_3] = unique(frames_var.trial_num);
            not_3 = locs_not_3(diff(temp) < 0) + 3;

            excluded_trials = frames_var.trial_num(not_3);

            if isempty(not_3)
                excluded_trials = 1;
            end

        else
            excluded_trials = [];
        end

    else
        excluded_trials = [];
    end

    %%% 4) Determine Context Number %%%
    if strcmpi(context_type, 'passive')
        context_num = 2;
    else
        context_num = 1;
    end
    
    %%% 5) Extract Control and Opto Trials %%%
    [control_output, opto_output, excluded_output] = find_control_opto_relative_to_bad_frames(frames_var, bad_frames, context_tr, context_num);
    
    %%% 6) Identify Sound-Only Trials %%%
    [repeatloc, first_repeat] = unique(frames_var.trial_num);
    first_repeat = first_repeat(setdiff(repeatloc, excluded_trials));

    sound_only_output = setdiff(first_repeat, [control_output; opto_output; excluded_output]);

    %%% 7) Compute Sound Onsets and Alignment Frames %%%
    alignment_frames = [frames_var.corr_frames(:,1)-1, frames_var.corr_frames(:,1)+2];

    %%% get rid of trials that are too short active context
    short_trials = find(alignment_frames(:,1) < 61);
    alignment_frames(short_trials,:) = nan;

    nan_Frames = find(isnan(alignment_frames(control_output,1)));
    control_output(nan_Frames) = [];

    nan_Frames = find(isnan(alignment_frames(sound_only_output,1)));
    sound_only_output(nan_Frames) = [];

    %%% Load alignment data
    load(fullfile(base_path, 'alignment_info.mat'));

    %%% Select imaging structure to make sure sounds have imaging trials
    if strcmpi(context_type, 'passive')
        load(fullfile(base_path, 'passive', 'imaging.mat'));
    else
        load(fullfile(base_path, 'VR', 'imaging.mat'));
    end

    %%% Get frame lengths across t-series files
    frame_lengths = [];
    frame_lengths = cellfun(@length, {alignment_info.frame_times});
    frame_lengths = [0, cumsum(frame_lengths)];

    empty_trials = find(cellfun(@isempty, {imaging.good_trial}));
    good_trials = setdiff(1:length(imaging), empty_trials);

    if strcmpi(context_type, 'passive')
        [~, alignment_frames_single_mouse, ~, ~] = find_align_info(imaging, 30, 2);
    else
        [~, alignment_frames_single_mouse, ~, ~] = find_align_info(imaging, 30);
    end

    %%% OPTIONAL: compute first, second, and third sound frame locations
    extra_sound_frames = [];
    

    if compute_extra_sounds

        extra_sound_frames = nan(3, size(alignment_frames,1));

        count_extra = 0;

        for trial = good_trials

            count_extra = count_extra + 1;

            for sound_num = 1:min(3, size(alignment_frames_single_mouse,1))

                frames_to_add = alignment_frames_single_mouse(sound_num, count_extra) + ...
                    frame_lengths(imaging(trial).file_num) - 1;

                if strcmpi(context_type, 'passive')
                    frames_to_add = alignment_frames_single_mouse(sound_num, count_extra);
                end

                candidate_frame = imaging(trial).frame_id(1) + frames_to_add;

                matched_trial = find(abs(candidate_frame - alignment_frames(:,1)) < 4);

                if ~isempty(matched_trial)
                    extra_sound_frames(sound_num, matched_trial(1)) = candidate_frame;
                end
            end
        end
    end

    %%% check to make sure sound only trials DO have imaging trials
    trials_with_imaging = [];
    count2 = 0;

    for trial = good_trials

        count2 = count2 + 1;

        frames_to_add = alignment_frames_single_mouse(1,count2) + ...
            frame_lengths(imaging(trial).file_num) - 1;

        if strcmpi(context_type, 'passive')
            frames_to_add = alignment_frames_single_mouse(1,count2);
        end

        trials_with_imaging = [trials_with_imaging, ...
            find(abs(imaging(trial).frame_id(1) + frames_to_add - alignment_frames(sound_only_output,1)) < 4)];
    end

    sound_only_output = sound_only_output(trials_with_imaging);

    %%% 8) Replace Alignment for Control Trials %%%
    alignment_based_on_control_opto = ...
        [bad_frames(context_tr{context_num,2},1), bad_frames(context_tr{context_num,2},2)];

    if alignment_based_on_control_opto(end,1) > alignment_frames(end,2)
        alignment_frames(control_output,:) = alignment_based_on_control_opto(1:end-1,:);
    else
        alignment_frames(control_output,:) = alignment_based_on_control_opto;
    end

    alignment_based_on_opto = ...
        [bad_frames(context_tr{context_num,1},1), bad_frames(context_tr{context_num,1},2)];

    if alignment_based_on_opto(end,1) > alignment_frames(end,2)
        alignment_frames(opto_output,:) = alignment_based_on_opto(1:end-1,:);
    else
        alignment_frames(opto_output,:) = alignment_based_on_opto;
    end

    %%% Get only good trials from imaging spk
    if strcmpi(context_type, 'passive')

        if length(control_output) ~= length(context_tr{2,4}) || length(opto_output) ~= length(context_tr{2,3})
            disp('not equal in length!')
        end

        opto_output = opto_output(find(ismember(context_tr{2,3}, [all_trial_info(dataset_index).opto.matched_id])));
        control_output = control_output(find(ismember(context_tr{2,4}, [all_trial_info(dataset_index).ctrl.matched_id])));

    else

        if length(control_output) ~= length(context_tr{1,4}) || length(opto_output) ~= length(context_tr{1,3})
            disp('not equal in length!')
        end

        opto_output = opto_output(find(ismember(context_tr{1,3}, [all_trial_info(dataset_index).opto.matched_id])));
        control_output = control_output(find(ismember(context_tr{1,4}, [all_trial_info(dataset_index).ctrl.matched_id])));

    end

    %%% put all sounds only and control trials into single array
    sound_onsets = [control_output; sound_only_output];

    
    %%% Optional second and third sound onsets
    sound_onsets_2 = [];
    sound_onsets_3 = [];
    
    if compute_extra_sounds
    
        if ~isempty(extra_sound_frames)
    
            valid_2 = find(~isnan(extra_sound_frames(2,:)));
            valid_3 = find(~isnan(extra_sound_frames(3,:)));
    
            %%% keep only trials close to valid sound_onsets trials
            valid_2 = valid_2(arrayfun(@(x) any(abs(sound_onsets - x) <= 1), valid_2));
            valid_3 = valid_3(arrayfun(@(x) any(abs(sound_onsets - x) <= 2), valid_3));
    
            sound_onsets_2 = valid_2(:);
            sound_onsets_3 = valid_3(:);

            sound_onsets_all_2{dataset_index} = sound_onsets_2;
            sound_onsets_all_3{dataset_index} = sound_onsets_3;
    
        end
    end
    %%% 9) Store Results
    sound_onsets_all{dataset_index} = sound_onsets;
    alignment_frames_all{dataset_index} = alignment_frames;
    control_output_all{dataset_index} = control_output;
    opto_output_all{dataset_index} = opto_output;
    sound_only_all{dataset_index} = sound_only_output;
    extra_sound_frames_all{dataset_index} = extra_sound_frames;

    %%% get the sound location for each trial
    for locs = 1:total_sound_locations
        loc_trials = find(ismember(sound_onsets, find(frames_var.condition == locs)));
        loc_trial{dataset_index, locs} = loc_trials;
    end

end

% Store into big structure
if strcmpi(context_type, 'passive')

    passive_sounds.sound_onsets_all = sound_onsets_all;
    passive_sounds.alignment_frames_all = alignment_frames_all;
    passive_sounds.control_output_all = control_output_all;
    passive_sounds.opto_output_all = opto_output_all;
    passive_sounds.sound_only_all = sound_only_all;
    passive_sounds.loc_trial = loc_trial;
    if compute_extra_sounds
    passive_sounds.extra_sound_frames_all = extra_sound_frames_all;
    passive_sounds.sound_onsets_all_2 = sound_onsets_all_2;
    passive_sounds.sound_onsets_all_3 = sound_onsets_all_3;
    end
else

    active_sounds.sound_onsets_all = sound_onsets_all;
    active_sounds.alignment_frames_all = alignment_frames_all;
    active_sounds.control_output_all = control_output_all;
    active_sounds.opto_output_all = opto_output_all;
    active_sounds.sound_only_all = sound_only_all;
    active_sounds.loc_trial = loc_trial;
    if compute_extra_sounds
    active_sounds.extra_sound_frames_all = extra_sound_frames_all;
    active_sounds.sound_onsets_all_2 = sound_onsets_all_2;
    active_sounds.sound_onsets_all_3 = sound_onsets_all_3;
    end

end

% Save variables if a save path is provided.
if ~isempty(savepath)

    outdir = fullfile(savepath);

    if ~exist(outdir, 'dir')
        mkdir(outdir);
    end

    if strcmpi(context_type, 'passive')
        save(fullfile(outdir, 'passive_sounds.mat'), 'passive_sounds');
    else
        save(fullfile(outdir, 'active_sounds.mat'), 'active_sounds');
    end
end

end