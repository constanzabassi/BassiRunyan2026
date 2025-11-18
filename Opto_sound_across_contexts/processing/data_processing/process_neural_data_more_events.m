function [alignment_frames, dff_struct, deconv_struct, deconv_struct_interp] = process_neural_data_more_events(data, before_after_frames,imaging,alignment_info, varargin)
    
    % Set default trial types
    if nargin < 5 || isempty(varargin{1})
        trial_types = {'stim', 'ctrl'};
        data.exp = data.exp;
        data.nonexp = data.nonexp;

    else %assuming it's sound locations
        trial_types = varargin{1};
        data.exp = data.left;
        data.nonexp = data.right;
    end

    %load trial info to make sure we have the correct ones
    load('V:\Connie\results\opto_sound_2025\context\sound_info\active_all_trial_info_sounds.mat');

    % Align frames and process data
    [allcells, allcells_nogap, alignment_frames] = optoalign_function(...
        data.exp, data.nonexp, data.bad_frames, data.dff, data.deconv, ...
        before_after_frames(1), before_after_frames(2));

    % Get alignment frames for other events!
    [align_info,alignment_frames_all,left_padding,right_padding] = find_align_info (imaging,30,3);
    %get trial frames
    updated_frames = get_alignment_frames_imaging_to_all(imaging,alignment_frames_all,alignment_info);

    valid_trials = find_relevant_frames(updated_frames,data.bad_frames);
    %find alignment frames
    frames = find_alignment_frames (updated_frames(:,valid_trials),[2:6],left_padding,right_padding);
    event_onsets = determine_onsets(left_padding,right_padding,[1:6]);

    % Process dF/F data
    [matrix1, matrix2, z_matrix1, z_matrix2] = ...
        make_tr_cel_time(allcells, 1); % Gives matrix of size: trials x cells x frames
    
    % Process deconvolution data
    [deconv_matrix1, deconv_matrix2] = make_tr_cel_time(allcells_nogap, 0); % No gap means no interpolation (useful for looking at artifact)
    [deconv_matrix1_interp, deconv_matrix2_interp] = make_tr_cel_time(allcells, 0);
    
    % Package results using dynamic field names based on trial_types
    dff_struct = struct(trial_types{1}, matrix1, trial_types{2}, matrix2, ...
                        ['z_', trial_types{1}], z_matrix1, ['z_', trial_types{2}], z_matrix2);
    
    deconv_struct = struct(trial_types{1}, deconv_matrix1, trial_types{2}, deconv_matrix2);
    
    deconv_struct_interp = struct(trial_types{1}, deconv_matrix1_interp, ...
                                  trial_types{2}, deconv_matrix2_interp);
end
