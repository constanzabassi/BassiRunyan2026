function [all_celltypes, sound_data, context_data, context_data_2, context_data_3] = pool_activity_sounds(mouse_date, server, before_after_frames, multiple_sounds)
% This function pools neural activity data from multiple mice/datasets.
%%% IMPORTANT - EXP = SOUND LEFT // NONEXP = SOUND RIGHT

if nargin < 4 || isempty(multiple_sounds)
    multiple_sounds = false;
end

% Initialize outputs
sound_data = initialize_sound_data(length(mouse_date));
context_data_2 = [];
context_data_3 = [];

% Load context data
%previous defaul pathway: 'V:\Connie\results\opto_sound_2025\context\sound_info';
[passive_data, active_data] = load_sound_data('W:\Connie\results\Bassi2025\fig3\sound_info');

% Process each dataset
for dataset_index = 1:length(mouse_date)

    fprintf('Processing dataset %s...\n', mouse_date{dataset_index});

    % Load neural data
    neural_data = load_neural_data(server{dataset_index}, mouse_date{dataset_index});
    
    % Process active context
    
    if multiple_sounds
        [dff, deconv, deconv_interp] = process_context_sounds(...
        neural_data, active_data, dataset_index, before_after_frames, 'active',multiple_sounds);
    else
        [dff, deconv, deconv_interp] = process_context_sounds(...
        neural_data, active_data, dataset_index, before_after_frames, 'active');
    end
     
    sound_data.active.dff_st{1,dataset_index} = dff;
    sound_data.active.deconv_st{1,dataset_index} = deconv;
    sound_data.active.deconv_st_interp{1,dataset_index} = deconv_interp;

    clear dff deconv deconv_interp

    % Process passive context
    [dff, deconv, deconv_interp] = process_context_sounds(...
        neural_data, passive_data, dataset_index, before_after_frames, 'passive');
    
    sound_data.passive.dff_st{1,dataset_index} = dff;
    sound_data.passive.deconv_st{1,dataset_index} = deconv;
    sound_data.passive.deconv_st_interp{1,dataset_index} = deconv_interp;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ORIGINAL CONTEXT DATA
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % STIM AND CONTROL/SOUND ONLY
    context_data.active{dataset_index,1} = active_data.alignment_frames_all{1,dataset_index};
    context_data.active{dataset_index,2} = active_data.opto_output_all{1,dataset_index}';
    context_data.active{dataset_index,3} = active_data.sound_onsets_all{1,dataset_index}';

    context_data.passive{dataset_index,1} = passive_data.alignment_frames_all{1,dataset_index};
    context_data.passive{dataset_index,2} = passive_data.opto_output_all{1,dataset_index}';
    context_data.passive{dataset_index,3} = passive_data.sound_onsets_all{1,dataset_index}';
        
    % LEFT AND RIGHT AS CONDITIONS
    context_data.active_sounds{dataset_index,1} = active_data.alignment_frames_all{1,dataset_index};
    context_data.active_sounds{dataset_index,2} = active_data.sound_onsets_all{1,dataset_index}(active_data.loc_trial{dataset_index,1})';
    context_data.active_sounds{dataset_index,3} = active_data.sound_onsets_all{1,dataset_index}(active_data.loc_trial{dataset_index,2})';

    context_data.passive_sounds{dataset_index,1} = passive_data.alignment_frames_all{1,dataset_index};
    context_data.passive_sounds{dataset_index,2} = passive_data.sound_onsets_all{1,dataset_index}(passive_data.loc_trial{dataset_index,1})';
    context_data.passive_sounds{dataset_index,3} = passive_data.sound_onsets_all{1,dataset_index}(passive_data.loc_trial{dataset_index,2})';

    % Store sound+opto trials
    context_data.sound_opto_trials{dataset_index} = {
        active_data.opto_output_all{1,dataset_index}, ...
        passive_data.opto_output_all{1,dataset_index}
    };

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % OPTIONAL 2ND / 3RD SOUND DATA
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if multiple_sounds
        
        if dataset_index == 5
            active_data.sound_onsets_all_3{1,5}(70:126) = active_data.sound_onsets_all_3{1,5}(69:125);
            active_data.sound_onsets_all_3{1,5}(69) = 1157;
        end

        % SECOND SOUND
        context_data_2.active{dataset_index,1} = active_data.alignment_frames_all{1,dataset_index};
        context_data_2.active{dataset_index,2} = active_data.opto_output_all{1,dataset_index}';
        context_data_2.active{dataset_index,3} = active_data.sound_onsets_all_2{1,dataset_index}';

        context_data_2.passive{dataset_index,1} = passive_data.alignment_frames_all{1,dataset_index};
        context_data_2.passive{dataset_index,2} = passive_data.opto_output_all{1,dataset_index}';
        context_data_2.passive{dataset_index,3} = passive_data.sound_onsets_all_2{1,dataset_index}';

        % THIRD SOUND
        context_data_3.active{dataset_index,1} = active_data.alignment_frames_all{1,dataset_index};
        context_data_3.active{dataset_index,2} = active_data.opto_output_all{1,dataset_index}';
        context_data_3.active{dataset_index,3} = active_data.sound_onsets_all_3{1,dataset_index}';

        context_data_3.passive{dataset_index,1} = passive_data.alignment_frames_all{1,dataset_index};
        context_data_3.passive{dataset_index,2} = passive_data.opto_output_all{1,dataset_index}';
        context_data_3.passive{dataset_index,3} = passive_data.sound_onsets_all_3{1,dataset_index}';

        % SECOND SOUND LEFT/RIGHT
        context_data_2.active_sounds{dataset_index,1} = active_data.alignment_frames_all{1,dataset_index};
        context_data_2.active_sounds{dataset_index,2} = active_data.sound_onsets_all_2{1,dataset_index}(active_data.loc_trial{dataset_index,1})';
        context_data_2.active_sounds{dataset_index,3} = active_data.sound_onsets_all_2{1,dataset_index}(active_data.loc_trial{dataset_index,2})';

        context_data_2.passive_sounds{dataset_index,1} = passive_data.alignment_frames_all{1,dataset_index};
        context_data_2.passive_sounds{dataset_index,2} = passive_data.sound_onsets_all_2{1,dataset_index}(passive_data.loc_trial{dataset_index,1})';
        context_data_2.passive_sounds{dataset_index,3} = passive_data.sound_onsets_all_2{1,dataset_index}(passive_data.loc_trial{dataset_index,2})';

        % THIRD SOUND LEFT/RIGHT
        context_data_3.active_sounds{dataset_index,1} = active_data.alignment_frames_all{1,dataset_index};
        context_data_3.active_sounds{dataset_index,2} = active_data.sound_onsets_all_3{1,dataset_index}(active_data.loc_trial{dataset_index,1})';
        context_data_3.active_sounds{dataset_index,3} = active_data.sound_onsets_all_3{1,dataset_index}(active_data.loc_trial{dataset_index,2})';

        context_data_3.passive_sounds{dataset_index,1} = passive_data.alignment_frames_all{1,dataset_index};
        context_data_3.passive_sounds{dataset_index,2} = passive_data.sound_onsets_all_3{1,dataset_index}(passive_data.loc_trial{dataset_index,1})';
        context_data_3.passive_sounds{dataset_index,3} = passive_data.sound_onsets_all_3{1,dataset_index}(passive_data.loc_trial{dataset_index,2})';

        context_data_2.sound_opto_trials{dataset_index} = context_data.sound_opto_trials{dataset_index};
        context_data_3.sound_opto_trials{dataset_index} = context_data.sound_opto_trials{dataset_index};

    end
end

% Load cell type information
all_celltypes = load('V:\Connie\results\passive\data_info\all_celltypes.mat').all_celltypes;

end


function sound_data = initialize_sound_data(n_datasets)

for context = {'passive', 'active'}
    sound_data.(context{1}).dff_st = cell(1, n_datasets);
    sound_data.(context{1}).deconv_st = cell(1, n_datasets);
    sound_data.(context{1}).deconv_st_interp = cell(1, n_datasets);
end

end