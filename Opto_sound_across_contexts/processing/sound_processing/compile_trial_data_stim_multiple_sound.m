function [sound_onsets_all, alignment_frames_all, control_output_all, opto_output_all,sound_only_all, loc_trial, all_trial_info] = compile_trial_data_stim_multiple_sound(info,contexts_types,savepath)
% This function extracts, aligns, and processes trial data for sound and stimulation experiments. 
% It combines sound onset frames, alignment frames, and trial indices for control and opto conditions across multiple datasets. 
% Additionally, it computes trial information relative to alignment frames, ensuring accurate trial structure for further analysis.
% 
% Inputs:
% 
% info – Structure containing dataset details, including:
% .mouse_date: Cell array of dataset dates.
% .serverid: Cell array of server IDs.
% .savepath: Base directory for saving results.
% context_type – String specifying the experimental context (e.g., 'passive', 'active').
% savepath (Optional) – Directory to save output variables.


for current_context = 1:length(contexts_types)
    new_savepath = [savepath '\sound_info\'];
    
    %get virmen trial info relative to sound alignment frames
    all_trial_info = get_trial_info_contexts(info,contexts_types{current_context}, new_savepath); %this gets loaded in the next file to make sure indices of imaging structure trials match bad frames trials
    %save it?

    %get sound onsets/locs relative to stimulation (bad_frames)
    [sound_onsets_all, alignment_frames_all, control_output_all, opto_output_all,sound_only_all, loc_trial] = get_sound_and_stim_onsets_trials(info,contexts_types{current_context}, new_savepath,1 );

 end