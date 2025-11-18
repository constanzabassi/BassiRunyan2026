function [all_celltypes, sound_data, context_data] = pool_activity_sounds(mouse_date, server, before_after_frames)
% This function pools neural activity data from multiple mice/datasets.
% It loads various datasets, processes deconvolved and dF/F signals,
% aligns activity to experimental conditions, and categorizes cells
% based on types. It also ensures consistency in cell numbers across datasets.
%%%IMPORTANT - EXP = SOUND LEFT// NONEXP = SOUND RIGHT 

    % Initialize sound_data structure
    sound_data = initialize_sound_data(length(mouse_date));
    
    % Load context data (trial onset information about sounds)
    [passive_data, active_data] = load_sound_data();
    
    % Process each dataset
    for dataset_index = 1:length(mouse_date)
        fprintf('Processing dataset %s...\n', mouse_date{dataset_index});

        % Load neural data (dff/deconv)
        neural_data = load_neural_data(server{dataset_index}, mouse_date{dataset_index});
        
        % Process active context
        [dff, deconv, deconv_interp] = process_context_sounds(...
            neural_data, active_data, dataset_index, before_after_frames, 'active');
         
         sound_data.active.dff_st{1,dataset_index} = dff;
         sound_data.active.deconv_st{1,dataset_index} = deconv;
         sound_data.active.deconv_st_interp{1,dataset_index} = deconv_interp;

         clear dff deconv deconv_interp

        % Process passive context (calls process_neural_data - aligns and
        % organizes data)
        % Process passive context
        [dff, deconv, deconv_interp] = process_context_sounds(...
            neural_data, passive_data, dataset_index, before_after_frames, 'passive');
        
         sound_data.passive.dff_st{1,dataset_index} = dff;
         sound_data.passive.deconv_st{1,dataset_index} = deconv;
         sound_data.passive.deconv_st_interp{1,dataset_index} = deconv_interp;
        
        %save trial information (STIM AND CONTROL AS CONDITIONS)
        context_data.active{dataset_index,1} = active_data.alignment_frames_all{1,dataset_index}; %sound onset frames
        context_data.active{dataset_index,2} = active_data.opto_output_all{1,dataset_index}'; %STIM 
        context_data.active{dataset_index,3} = active_data.sound_onsets_all{1,dataset_index}'; %CONTROL AND SOUND ONLY

        context_data.passive{dataset_index,1} = passive_data.alignment_frames_all{1,dataset_index}; %sound onset frames
        context_data.passive{dataset_index,2} = passive_data.opto_output_all{1,dataset_index}'; %STIM 
        context_data.passive{dataset_index,3} = passive_data.sound_onsets_all{1,dataset_index}'; %CONTROL AND SOUND ONLY
            

        %save trial information (LEFT AND RIGHT AS CONDITIONS)
        context_data.active_sounds{dataset_index,1} = active_data.alignment_frames_all{1,dataset_index}; %sound onset frames
        context_data.active_sounds{dataset_index,2} = active_data.sound_onsets_all{1,dataset_index}(active_data.loc_trial{dataset_index,1})'; %LEFT
        context_data.active_sounds{dataset_index,3} = active_data.sound_onsets_all{1,dataset_index}(active_data.loc_trial{dataset_index,2})'; %RIGHT

        context_data.passive_sounds{dataset_index,1} = passive_data.alignment_frames_all{1,dataset_index}; %sound onset frames
        context_data.passive_sounds{dataset_index,2} = passive_data.sound_onsets_all{1,dataset_index}(passive_data.loc_trial{dataset_index,1})'; %LEFT
        context_data.passive_sounds{dataset_index,3} = passive_data.sound_onsets_all{1,dataset_index}(passive_data.loc_trial{dataset_index,2})'; %RIGHT

        % Store sound+opto trials (organized across contexts)
        context_data.sound_opto_trials{dataset_index} = {
            active_data.opto_output_all{1,dataset_index},   % active context
            passive_data.opto_output_all{1,dataset_index}   % passive context
        };
    end
    
    % Load cell type information
    all_celltypes = load('V:\Connie\results\passive\data_info\all_celltypes.mat').all_celltypes;
end

function sound_data = initialize_sound_data(n_datasets)
    % Initialize the sound_data structure with proper fields
    for context = {'passive', 'active'}
        sound_data.(context{1}).dff_st = cell(1, n_datasets);
        sound_data.(context{1}).deconv_st = cell(1, n_datasets);
        sound_data.(context{1}).deconv_st_interp = cell(1, n_datasets);
    end
end