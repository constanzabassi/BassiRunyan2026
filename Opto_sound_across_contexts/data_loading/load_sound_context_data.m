function data = load_sound_context_data(context)
%loads sound trial information!

%load previously processed data using [sound_onsets_all, alignment_frames_all, control_output_all, opto_output_all,sound_only_all, loc_trial, all_trial_info_sounds] = compile_trial_data_stim_sound(params.info,{'active','passive'},params.info.savepath);

    base_path = 'V:\Connie\results\opto_sound_2025\context\sound_info'; %fullfile('V:', 'Connie', 'results', context, 'mod');
%     context_path = fullfile('V:', 'Connie', 'results', 'opto_2025', 'context', context);
    
    data = struct();
    if strcmpi(context,'passive')
        load(fullfile(base_path, 'passive_sounds.mat'));%
        data = passive_sounds;
    else
        load(fullfile(base_path, 'active_sounds.mat'));%
        data = active_sounds;
    end

%     data.resp = load(fullfile(base_path, 'resp_tr.mat')).resp_tr;%trials x cells x time dividided into loc 1 and loc 2 
%     data.loc_trial = load(fullfile(base_path, 'loc_trial.mat')).loc_trial;%trials from original structure that went into making resp_tr
%     data.right_output = load(fullfile(base_path, 'control_output_all.mat')).control_output_all;% sounds that happened during a control trial (meaning opto power set to 0mW)
%     data.sound_onsets_all = load(fullfile(base_path, 'sound_onsets_all.mat')).sound_onsets_all;% sound onsets including control AND sounds where there is no opto happening at all (but not sound+opto)
%     data.alignment_frames_all = load(fullfile(base_path, 'alignment_frames_all.mat')).alignment_frames_all; % similar to "bad_frames" but for ALL first sound onsets (including sound+opto)
%     data.opto_output_all = load(fullfile(context_path, 'opto_output_all.mat')).opto_output_all;% sounds that happened during a opto trial (meaning opto power set to 7mW-11mW)
end