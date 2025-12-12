function [sound,opto,sorted_cells,all_celltypes,context_data,ctrl_trials,stim_trials,context_data_sound] = load_processed_opto_sound_data(params,mode)
%LOAD_OPTO_SOUND_DATA Load optogenetics + sound experiment data.
%
%   data = load_opto_sound_data(params)
%
%   Inputs:
%       params.info - struct with directory paths, e.g.
%           params.info.base_dir = 'V:\Connie\results\opto_sound_2025\context\';
%       mod_type = 'prepost', 'ctrl', 'influence', 'prepost_sound'
% 
%       mode = 'separate'; %'pooled', 'separate', 'simple'- how the mod
%       index was computed pooled is pooling left and right sides and
%       balancing
%
%   Outputs:
%       data - struct with all loaded variables

    base_dir = params.info.base_dir;

    %% --- Opto ---
    opto.sig_mod_boot_thr = load(fullfile(base_dir, 'mod\prepost\',mode{1},'\sig_mod_boot_thr.mat'), 'sig_mod_boot_thr').sig_mod_boot_thr;
    opto.sig_mod_boot     = load(fullfile(base_dir, 'mod\prepost\',mode{1},'\sig_mod_boot.mat'), 'sig_mod_boot').sig_mod_boot;
    opto.sig_mod_boot_thr_ctrl = load(fullfile(base_dir, 'mod\ctrl\',mode{1},'\sig_mod_boot_thr.mat'), 'sig_mod_boot_thr').sig_mod_boot_thr;
    opto.sig_mod_boot_ctrl     = load(fullfile(base_dir, 'mod\ctrl\',mode{1},'\sig_mod_boot.mat'), 'sig_mod_boot').sig_mod_boot;
    opto.mod              = load(fullfile(base_dir, 'mod\ctrl\',mode{1},'\mod_indexm.mat'), 'mod_indexm').mod_indexm;
    opto.mod_prepost      = load(fullfile(base_dir, 'mod\prepost\',mode{1},'\mod_indexm.mat'), 'mod_indexm').mod_indexm;
    opto.results          = load(fullfile(base_dir, 'mod\ctrl\',mode{1},'\mod_index_results.mat'), 'results').results;
    opto.sig_cells        = opto.sig_mod_boot_thr(:,3); % from spontaneous context (3)
    opto.avg              = load(fullfile(base_dir, 'avg\trial_averaged_results.mat'), 'avg_results').avg_results;

    %% --- Sound ---
    sound.sig_mod_boot_thr = load(fullfile(base_dir, 'sounds\mod\prepost_sound\',mode{2},'\sig_mod_boot_thr.mat'), 'sig_mod_boot_thr').sig_mod_boot_thr;
    sound.sig_mod_boot     = load(fullfile(base_dir, 'sounds\mod\prepost_sound\',mode{2},'\sig_mod_boot.mat'), 'sig_mod_boot').sig_mod_boot;
    sound.mod              = load(fullfile(base_dir, 'sounds\mod\prepost_sound\',mode{2},'\mod_indexm.mat'), 'mod_indexm').mod_indexm;
    sound.results          = load(fullfile(base_dir, 'sounds\mod\prepost_sound\',mode{2},'\mod_index_results.mat'), 'results').results;
    sound.avg              = load(fullfile(base_dir, 'sounds\avg\trial_averaged_results_sounds.mat'),'avg_results_sounds').avg_results_sounds;
    sound.stim_avg              = load(fullfile(base_dir, 'sounds\avg\trial_averaged_results_sounds_stim.mat'), 'avg_results').avg_results;

    % sig cells taking the union of active (1) and passive (2)
    [sound.sig_cells, ~]   = union_sig_cells(...
                                    sound.sig_mod_boot_thr(:,1)', ...
                                    sound.sig_mod_boot_thr(:,2)', ...
                                    sound.mod);
    [sound.sig_cells_intersect, ~]   = intersect_sig_cells(...
                                    sound.sig_mod_boot_thr(:,1)', ...
                                    sound.sig_mod_boot_thr(:,2)', ...
                                    sound.mod);

    %% --- Shared Data ---
    shared_dir = fullfile(base_dir, 'data_info');
    sorted_cells   = load(fullfile(shared_dir, 'sorted_cells.mat')).sorted_cells;
    all_celltypes  = load(fullfile(shared_dir, 'all_celltypes.mat')).all_celltypes;
    context_data   = load(fullfile(shared_dir, 'context_data.mat')).context_data;
    context_data_sound = load(fullfile(base_dir,'sounds','data_info','context_data.mat')).context_data; %ctrl and sound only trials are concatenated together
    ctrl_trials    = load(fullfile(shared_dir, 'ctrl_trials_context.mat')).ctrl_trials_context;
    stim_trials    = load(fullfile(shared_dir, 'stim_trials_context.mat')).stim_trials_context;

end
