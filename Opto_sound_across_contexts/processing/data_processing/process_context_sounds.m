function [dff_st,deconv_st,deconv_st_interp] = process_context_sounds(neural_data, context_info, dataset_index, before_after_frames, context_type)
    % Process neural responses to sounds for a specific context

    % Store results
    context_data = struct();

    % Define trial types
    default_trial_types = {'stim', 'ctrl'};
    alt_trial_types = {'left', 'right'};

    % sound onsets is this: sound_onsets = [control_output; sound_only_output];

    % Put sound trials into exp (sound 1 left) or nonexp (sound 2 right)
%     data.exp = context_info.sound_onsets_all{1,dataset_index}(context_info.loc_trial{dataset_index,1})'; %LEFT
%     data.nonexp = context_info.sound_onsets_all{1,dataset_index}(context_info.loc_trial{dataset_index,2})'; %RIGHT
    data.left = context_info.sound_onsets_all{1,dataset_index}(context_info.loc_trial{dataset_index,1})'; %LEFT
    data.right = context_info.sound_onsets_all{1,dataset_index}(context_info.loc_trial{dataset_index,2})'; %RIGHT
    data.nonexp = context_info.sound_onsets_all{1,dataset_index}'; % [control_output; sound_only_output]; (so only control trials no opto)]
    data.exp = context_info.opto_output_all{1,dataset_index}'; % stim trials
    data.bad_frames = context_info.alignment_frames_all{1,dataset_index}; %sound onset frames
    data.dff = neural_data.dff;
    data.deconv = neural_data.deconv;
            
    % Align to sound onsets across stim and control trials and process neural data (dff/deconv)
    [~, dff_st_current, deconv_st_current, deconv_st_interp_current] = process_neural_data(data, before_after_frames);

    % Store data dynamically using trial type names
    for i = 1:length(default_trial_types)
        trial = default_trial_types{i};
        dff_st.(trial) = dff_st_current.(trial);
        dff_st.(['z_' trial]) = dff_st_current.(['z_' trial]);
        deconv_st.(trial) = deconv_st_current.(trial);
        deconv_st_interp.(trial) = deconv_st_interp_current.(trial);
    end    

    % Align to sound onsets left and right trials (control and sound only trials!) and process neural data (dff/deconv)
    [~, dff_st_current, deconv_st_current, deconv_st_interp_current ]= process_neural_data(data, before_after_frames, alt_trial_types);

    % Store data dynamically for left/right
    for i = 1:length(alt_trial_types)
        trial = alt_trial_types{i};
        dff_st.(trial) = dff_st_current.(trial);
        dff_st.(['z_' trial]) = dff_st_current.(['z_' trial]);
        deconv_st.(trial) = deconv_st_current.(trial);
        deconv_st_interp.(trial) = deconv_st_interp_current.(trial);
    end
%     % Store processed data
%     dff_st = struct('left', dff_st_current_dataset.left, 'ctrl', dff_st_current_dataset.ctrl, 'z_stim', dff_st_current_dataset.z_stim, 'z_ctrl', dff_st_current_dataset.z_ctrl);
%     deconv_st = struct('stim', deconv_st_current_dataset.stim, 'ctrl', deconv_st_current_dataset.ctrl);
%     deconv_st_interp = struct('stim', deconv_st_interp_current_dataset.stim, 'ctrl', deconv_st_interp_current_dataset.ctrl);


end