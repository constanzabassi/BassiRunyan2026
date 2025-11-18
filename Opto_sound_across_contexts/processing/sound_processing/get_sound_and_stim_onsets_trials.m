function [sound_onsets_all, alignment_frames_all, control_output_all, opto_output_all,sound_only_all, loc_trial] = get_sound_and_stim_onsets_trials(info, context_type, savepath)
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

% Preallocate output cell arrays.
sound_onsets_all = cell(1, length(info.mouse_date));
alignment_frames_all = cell(1, length(info.mouse_date));
control_output_all = cell(1, length(info.mouse_date));
opto_output_all = cell(1, length(info.mouse_date));
total_sound_locations = 2;
loc_trial = cell(length(info.mouse_date),total_sound_locations); %2 is number of locations!

% Loop through each dataset.
for dataset_index = 1:length(info.mouse_date)
    fprintf('Processing dataset %d/%d...\n', dataset_index, length(info.mouse_date));
    ss = info.serverid{dataset_index};  % Assume serverid is a cell array.
    base_path = fullfile(num2str(ss), 'Connie', 'ProcessedData', info.mouse_date{dataset_index});
    
    %%% 1) Load Data %%%
    load(fullfile(base_path, 'context_stim', 'updated', 'context_tr.mat')); %trials separated by context
    load(fullfile(base_path, 'context_stim', 'updated', 'bad_frames.mat'));
    
    %%% 2) Select Appropriate Frames Variable %%%
    % Depending on context_type, the loaded variable name may differ.
    if strcmpi(context_type, 'passive')
        % Load the frames variable corresponding to context_type.
        load(fullfile(base_path, context_type, [context_type '_frames.mat']));
        load('V:\Connie\results\opto_sound_2025\context\sound_info\passive_all_trial_info.mat');
%         load('V:\Connie\results\opto_2024\context\data_info\all_trial_info_passive.mat'); %from get_trial_info_contexts
%         all_trial_info = all_trial_info_passive;

        frames_var = passive_frames;  % Assuming passive_frames is loaded.
        passive_sounds = {};
    elseif strcmpi(context_type, 'active')
        % Load the frames variable corresponding to context_type.
        load(fullfile(base_path, 'VR', ['vr_sound_frames.mat']));
        load('V:\Connie\results\opto_sound_2025\context\sound_info\active_all_trial_info.mat');
%         load('V:\Connie\results\opto_2024\context\data_info\all_trial_info.mat'); %from get_trial_info_contexts

        frames_var = vr_sound_frames;   % Assuming active_frames is loaded.
        active_sounds = {};
    else
        % For other contexts, adjust accordingly.
        frames_var = [];
        warning('Context type "%s" not explicitly handled. Proceeding with empty frames variable.', context_type);
    end
    
    %%% 3) Check Trial Repeats %%% only relevant for passive (making sure
    %%% we have at least 3 repeats!)
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
            not_3 = locs_not_3(diff(temp) < 0) + 3; % Assumes groups of 3 repeats.
            excluded_trials = frames_var.trial_num(not_3);
            if isempty(not_3) % For very first trial, if needed.
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
    %get indices of opto and control that match bad_frames
    [control_output, opto_output,excluded_output] = find_control_opto_relative_to_bad_frames(frames_var, bad_frames, context_tr, context_num);
    
    %%% 6) Identify Sound-Only Trials %%%
    [repeatloc, first_repeat] = unique(frames_var.trial_num);
    first_repeat = first_repeat(setdiff(repeatloc, excluded_trials));
    sound_only_output = setdiff(first_repeat, [control_output; opto_output; excluded_output]);

    %%% 7) Compute Sound Onsets and Alignment Frames %%%
    alignment_frames = [frames_var.corr_frames(:,1)-1, frames_var.corr_frames(:,1)+2];

    %%% get rid of trials that are too short (in active context)
    short_trials = find(alignment_frames(:,1)<(61)); %2 second min!
    alignment_frames(short_trials,:) = nan;
    nan_Frames = find(isnan(alignment_frames(control_output,1)));
    control_output(nan_Frames) = [];
    nan_Frames = find(isnan(alignment_frames(sound_only_output,1)));
    sound_only_output(nan_Frames) = [];

    %load alignment data
        load(fullfile(base_path, 'alignment_info.mat'));
        %%%  Select imaging structure to make sure sounds have imaging
        %%%  trials
        % Depending on context_type, the loaded variable name may differ.
        if strcmpi(context_type, 'passive')
            load(fullfile(base_path, 'passive','imaging.mat'));
        else
            load(fullfile(base_path, 'VR','imaging.mat'));
        end

        %get frame lengths across t series files to make sure frame indices
        %make sense!
        frame_lengths = [];
        frame_lengths = cellfun(@length,{alignment_info.frame_times}); %across all imaged files 
        frame_lengths = [0,cumsum(frame_lengths)];

        empty_trials = find(cellfun(@isempty, {imaging.good_trial}));
        good_trials = setdiff(1:length(imaging), empty_trials); % Only trials with all imaging data considered
        if strcmpi(context_type, 'passive')
            [~,alignment_frames_single_mouse,~,~] = find_align_info (imaging,30,2); %gets alignment frames for trial events (stimulus, turn, iti etc)
        else
            [~,alignment_frames_single_mouse,~,~] = find_align_info (imaging,30);
        end

    %%% check to make sure sound only trials DO have imaging trials!!
    trials_with_imaging = [];
    count = 0;
    count2 = 0;
    % Process opto trials
    for trial = good_trials
        count2 = count2+1;
        frames_to_add = alignment_frames_single_mouse(1,count2)+frame_lengths(imaging(trial).file_num)-1; %first row is sound onset which is opto onset!
        if strcmpi(context_type, 'passive')
            frames_to_add = alignment_frames_single_mouse(1,count2);
        end
        trials_with_imaging = [trials_with_imaging,find(abs(imaging(trial).frame_id(1)+frames_to_add - alignment_frames(sound_only_output,1)) < 4)]; % Onset of opto
    end

    sound_only_output = sound_only_output(trials_with_imaging);

    
    %%% 8) Replace Alignment for Control Trials %%%
    alignment_based_on_control_opto = [bad_frames(context_tr{context_num,2},1), bad_frames(context_tr{context_num,2},2)];%last number is ctrl (2) and stim (1)
    if alignment_based_on_control_opto(end,1) > alignment_frames(end,2) %if the very last sound is smaller than the end of alignment_frames (from bad_frames) do not include- probably not a full trial
        alignment_frames(control_output,:) = alignment_based_on_control_opto(1:end-1,:);
    else
        alignment_frames(control_output,:) = alignment_based_on_control_opto;
    end

    alignment_based_on_opto = [bad_frames(context_tr{context_num,1},1), bad_frames(context_tr{context_num,1},2)];%last number is ctrl (2) and stim (1)
    if alignment_based_on_opto(end,1) > alignment_frames(end,2) %if the very last sound is smaller than the end of alignment_frames (from bad_frames) do not include- probably not a full trial
        alignment_frames(opto_output,:) = alignment_based_on_opto(1:end-1,:);
    else
        alignment_frames(opto_output,:) = alignment_based_on_opto;
    end

    %%% GET ONLY GOOD TRIALS FROM IMAGING SPK (relative to opto (EXP) or
    %%% control (NONEXP)
    if strcmpi(context_type, 'passive')
        if length(control_output) ~= length(context_tr{2,4}) || length(opto_output) ~= length(context_tr{2,3})
            disp('not equal in length!')
        end
        opto_output =opto_output(find(ismember(context_tr{2,3},[all_trial_info(dataset_index).opto.matched_id])));
        control_output = control_output(find(ismember(context_tr{2,4},[all_trial_info(dataset_index).ctrl.matched_id])));

    else
        if length(control_output) ~= length(context_tr{1,4}) || length(opto_output) ~= length(context_tr{1,3})
            disp('not equal in length!')
        end
        opto_output = opto_output(find(ismember(context_tr{1,3},[all_trial_info(dataset_index).opto.matched_id])));
        control_output = control_output(find(ismember(context_tr{1,4},[all_trial_info(dataset_index).ctrl.matched_id])));
    end

    %%% put all sounds only and control trials into single array
    sound_onsets = [control_output; sound_only_output];

        

    %%% 9) Store Results %%%
    sound_onsets_all{dataset_index} = sound_onsets;
    alignment_frames_all{dataset_index} = alignment_frames;
    control_output_all{dataset_index} = control_output;
    opto_output_all{dataset_index} = opto_output;
    sound_only_all{dataset_index} = sound_only_output; %without control

    %get the sound location for each trial! very important
    for locs = 1:total_sound_locations
        loc_trials = find(ismember(sound_onsets,find(frames_var.condition == locs)));
        loc_trial{dataset_index,locs} = loc_trials;
    end
end

%store into big structure
if strcmpi(context_type, 'passive')
    passive_sounds.sound_onsets_all = sound_onsets_all;
    passive_sounds.alignment_frames_all = alignment_frames_all;
    passive_sounds.control_output_all = control_output_all;
    passive_sounds.opto_output_all = opto_output_all;
    passive_sounds.sound_only_all = sound_only_all;
    passive_sounds.loc_trial = loc_trial;
else
    active_sounds.sound_onsets_all = sound_onsets_all;
    active_sounds.alignment_frames_all = alignment_frames_all;
    active_sounds.control_output_all = control_output_all;
    active_sounds.opto_output_all = opto_output_all;
    active_sounds.sound_only_all = sound_only_all;
    active_sounds.loc_trial = loc_trial;
end

% Save variables if a save path is provided.
if ~isempty(savepath)
    outdir = fullfile(savepath);
    if ~exist(outdir, 'dir')
        mkdir(outdir);
    end
%     save(fullfile(outdir, 'sound_onsets_all.mat'), 'sound_onsets_all');
%     save(fullfile(outdir, 'alignment_frames_all.mat'), 'alignment_frames_all');
%     save(fullfile(outdir, 'control_output_all.mat'), 'control_output_all');
%     save(fullfile(outdir, 'opto_output_all.mat'), 'opto_output_all');
%     save(fullfile(outdir, 'sound_only_all.mat'), 'sound_only_all');
%     save(fullfile(outdir,'loc_trial.mat'),'loc_trial');
    if strcmpi(context_type, 'passive')
        save(fullfile(outdir,'passive_sounds.mat'),'passive_sounds');
    else
        save(fullfile(outdir,'active_sounds.mat'),'active_sounds');
    end
end
end
