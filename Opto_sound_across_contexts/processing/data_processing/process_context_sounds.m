function [dff_st, deconv_st, deconv_st_interp, relative_sound_frames] = process_context_sounds(...
    neural_data, context_info, dataset_index, before_after_frames, context_type, sound_repeat,varargin)

% Process neural responses to sounds for a specific context
%
% sound_repeat:
%   1 = first sound/default
%   2 = second sound
%   3 = third sound

if nargin < 6 || isempty(sound_repeat)
    sound_repeat = 1;
end

% Define trial types
default_trial_types = {'stim', 'ctrl'};
alt_trial_types = {'left', 'right'};

%%% choose which sound onset set to use
if sound_repeat == 1

    sound_onsets_current = context_info.sound_onsets_all{1,dataset_index};
    alignment_frames_current = context_info.alignment_frames_all{1,dataset_index};

elseif sound_repeat == 2

    sound_onsets_current = context_info.sound_onsets_all_2{1,dataset_index};

    alignment_frames_current = context_info.alignment_frames_all{1,dataset_index};
    sound_frames = context_info.extra_sound_frames_all{1,dataset_index}(2,:);

    valid_trials = find(~isnan(sound_frames));
    alignment_frames_current(valid_trials,1) = sound_frames(valid_trials);
    alignment_frames_current(valid_trials,2) = sound_frames(valid_trials) + 3;

elseif sound_repeat == 3
    if dataset_index == 5 && strcmp(context_type,'active')
            context_info.sound_onsets_all_3{1,5}(70:126) = context_info.sound_onsets_all_3{1,5}(69:125);
            context_info.sound_onsets_all_3{1,5}(69) = 1157;
    end

    sound_onsets_current = context_info.sound_onsets_all_3{1,dataset_index};

    alignment_frames_current = context_info.alignment_frames_all{1,dataset_index};
    sound_frames = context_info.extra_sound_frames_all{1,dataset_index}(3,:);

    valid_trials = find(~isnan(sound_frames));
    alignment_frames_current(valid_trials,1) = sound_frames(valid_trials);
    alignment_frames_current(valid_trials,2) = sound_frames(valid_trials) + 3;

else
    error('sound_repeat must be 1, 2, or 3');
end

%%% figure out where other sounds occur
%%% relative neighboring sound timings
relative_sound_frames = struct();

all_sound_frames = context_info.extra_sound_frames_all{1,dataset_index};

if sound_repeat == 1

    current_frames = all_sound_frames(1,:);
    valid_trials = find(~isnan(current_frames));
    valid_trials2 = find(~isnan(all_sound_frames(2,:)));

    % sound 2 relative to sound 1
    relative_sound_frames.behind = ...
        all_sound_frames(2,valid_trials2) - current_frames(valid_trials);

elseif sound_repeat == 2

    current_frames = all_sound_frames(2,:);
    valid_trials = find(~isnan(all_sound_frames(1,:)));
    valid_trials2 = find(~isnan(all_sound_frames(2,:)));
    valid_trials3 = find(~isnan(all_sound_frames(3,:)));

    % sound 1 relative to sound 2
    relative_sound_frames.front = ...
        all_sound_frames(1,valid_trials) - current_frames(valid_trials2);

    % sound 3 relative to sound 2
    relative_sound_frames.behind = ...
        all_sound_frames(3,valid_trials3) - current_frames(valid_trials2);

elseif sound_repeat == 3

    current_frames = all_sound_frames(3,:);
    valid_trials = find(~isnan(all_sound_frames(1,:)));
    valid_trials2 = find(~isnan(all_sound_frames(2,:)));
    valid_trials3 = find(~isnan(all_sound_frames(3,:)));

    % sound 2 relative to sound 3
    relative_sound_frames.front = ...
        all_sound_frames(2,valid_trials2) - current_frames(valid_trials3);

end


%%% restrict opto/stim trials to trials with valid alignment for this repeat
if sound_repeat == 1
    opto_current = context_info.opto_output_all{1,dataset_index};
else
    opto_current = context_info.opto_output_all{1,dataset_index};
    opto_current = opto_current(~isnan(alignment_frames_current(opto_current,1)));
end

%%% location indices need to be relative to sound_onsets_current
if sound_repeat == 1

    left_trials = sound_onsets_current(context_info.loc_trial{dataset_index,1});
    right_trials = sound_onsets_current(context_info.loc_trial{dataset_index,2});

else

    first_sound_onsets = context_info.sound_onsets_all{1,dataset_index};

    left_first = first_sound_onsets(context_info.loc_trial{dataset_index,1});
    right_first = first_sound_onsets(context_info.loc_trial{dataset_index,2});

    if sound_repeat == 2
        left_trials = intersect(sound_onsets_current-1, left_first);
        right_trials = intersect(sound_onsets_current-1, right_first);
    elseif sound_repeat == 3
        left_trials = intersect(sound_onsets_current-2, left_first);
        right_trials = intersect(sound_onsets_current-2, right_first);
    end

end

%%% Build data structure for process_neural_data
data.left = left_trials';
data.right = right_trials';

data.nonexp = sound_onsets_current';
data.exp = opto_current';

data.bad_frames = alignment_frames_current;
data.dff = neural_data.dff;
data.deconv = neural_data.deconv;

%add padding if changing
if nargin > 6
    data.padding = varargin{1};
else
    data.padding = [1,2];
end

%%% Align stim/control
[~, dff_st_current, deconv_st_current, deconv_st_interp_current] = ...
    process_neural_data(data, before_after_frames);

for i = 1:length(default_trial_types)
    trial = default_trial_types{i};

    dff_st.(trial) = dff_st_current.(trial);
    dff_st.(['z_' trial]) = dff_st_current.(['z_' trial]);

    deconv_st.(trial) = deconv_st_current.(trial);
    deconv_st_interp.(trial) = deconv_st_interp_current.(trial);
end

%%% Align left/right
[~, dff_st_current, deconv_st_current, deconv_st_interp_current] = ...
    process_neural_data(data, before_after_frames, alt_trial_types);

for i = 1:length(alt_trial_types)
    trial = alt_trial_types{i};

    dff_st.(trial) = dff_st_current.(trial);
    dff_st.(['z_' trial]) = dff_st_current.(['z_' trial]);

    deconv_st.(trial) = deconv_st_current.(trial);
    deconv_st_interp.(trial) = deconv_st_interp_current.(trial);
end

end